//! Generic Process Scheduler Struct!
//! All instruction specific stuff is handled downstream

const std = @import("std");
const builtin = @import("builtin");

const X86_64Context = @import("arch/x86-64.zig").Context;
const ARMContext = @import("arch/arm32.zig").Context;
const ThumbContext = @import("arch/thumb.zig").Context;
const Task = @import("task.zig").Task;

pub const RoundRobin = @import("schedulers/rr.zig").RoundRobin;
pub const RoundRobinDynamic = @import("schedulers/rr-dyn.zig").RoundRobinDynamic;

pub const TaskFn = *const fn () noreturn;
pub const SchedulerErrors = error{ AllTasksRegistered, NoTasksRegistered };

pub fn ThothScheduler(comptime Scheduler: type, comptime stack_size: u32) type {
    return struct {
        scheduler: Scheduler,

        curr: *Task(stack_size),
        ctx: Context,

        pub const Context = switch (builtin.cpu.arch) {
            .x86_64 => X86_64Context(stack_size),
            .arm => ARMContext(stack_size),
            .thumb => ThumbContext(stack_size),
            else => @compileError("Unsupported CPU architecture: " ++ @tagName(builtin.cpu.arch)),
        };

        const Self = @This();

        pub fn init(scheduler: Scheduler) Self {
            return Self{ .curr = undefined, .scheduler = scheduler, .ctx = Context{} };
        }

        pub fn createTask(self: *Self, fun: TaskFn) !void {
            try self.scheduler.register(fun);
        }

        pub fn yield(self: *Self) void {
            const curr = self.curr;
            const next = self.scheduler.getNext();

            self.curr = next;

            self.ctx.swapCtx(curr, next);
        }

        pub fn start(self: *Self) !noreturn {
            self.curr = try self.scheduler.start();
            self.ctx.start(self.curr);
        }
    };
}
