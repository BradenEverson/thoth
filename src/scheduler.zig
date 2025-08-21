//! Generic Scheduler API

const Task = @import("task.zig").Task;

pub const SchedulerErrors = error{ AllTasksRegistered, NoTasksRegistered };

pub const TaskFn = *const fn () noreturn;

/// Generic Scheduler VTable struct that other types should coerce into
pub fn Scheduler(comptime stack_size: u32) type {
    return struct {
        const TaskType = Task(stack_size);
        ctx: *anyopaque,

        registerFn: *const fn (ctx: *anyopaque, task: TaskFn) SchedulerErrors!void,
        getNextFn: *const fn (ctx: *anyopaque) *TaskType,
        startFn: *const fn (ctx: *anyopaque) SchedulerErrors!*TaskType,

        const Self = @This();

        pub inline fn register(self: *Self, task: TaskFn) SchedulerErrors!void {
            try self.registerFn(self.ctx, task);
        }

        pub inline fn getNext(self: *Self) *TaskType {
            return self.getNextFn(self.ctx);
        }

        pub inline fn start(self: *Self) SchedulerErrors!*TaskType {
            return try self.startFn(self.ctx);
        }
    };
}
