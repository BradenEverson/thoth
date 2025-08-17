//! Generic Process Scheduler Struct!
//! All instruction specific stuff is handled downstream

const std = @import("std");
const builtin = @import("builtin");
const X86_64Context = @import("arch/x86-64.zig").Context;

const Task = @import("task.zig").Task;

const TaskFn = *const fn () noreturn;

const SchedulerErrors = error{ AllTasksRegistered, NoTasksRegistered };

pub fn ThothScheduler(comptime max_tasks: u32, comptime stack_size: u32) type {
    return struct {
        tasks: [max_tasks]Task(stack_size),
        num_tasks: usize,
        curr_task: usize,

        ctx: Context,

        pub const Context = switch (builtin.cpu.arch) {
            .x86_64 => X86_64Context(stack_size),
            else => @compileError("Unsupported CPU architecture"),
        };

        const Self = @This();

        pub fn init() Self {
            return Self{
                .tasks = std.mem.zeroes([max_tasks]Task(stack_size)),
                .num_tasks = 0,
                .curr_task = 0,
                .ctx = Context{},
            };
        }

        pub fn createTask(self: *Self, fun: TaskFn) !void {
            if (self.num_tasks == max_tasks) {
                return error.AllTasksRegistered;
            }
            const task = &self.tasks[self.num_tasks];

            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - 8]),
                .stack = std.mem.zeroes(@TypeOf(task.stack)),
            };

            self.num_tasks += 1;
        }

        pub inline fn yield(self: *Self) void {
            const curr = &self.tasks[self.curr_task];
            const next = self.choseNext();
            _ = curr;
            _ = next;
        }

        pub inline fn choseNext(self: *const Self) *Task(stack_size) {
            _ = self;
        }

        pub fn start(self: *Self) !noreturn {
            if (self.num_tasks == 0) {
                return error.NoTasksRegistered;
            }

            self.ctx.start(&self.tasks[self.curr_task]);

            while (true) {}
        }
    };
}
