//! ARM32 specific context switching and state tracking
//! THIS IS UNTESTED!!! TODO: TEST THIS

const Task = @import("../task.zig").Task;

pub fn Context(comptime Scheduler: type) type {
    const TaskType = Scheduler.getTaskType();

    return struct {
        const Self = @This();

        pub extern fn context_switch(from_sp: *usize, from_ip: *usize, to_sp: usize, to_ip: usize) void;
        pub extern fn context_start(sp: usize, ip: usize) noreturn;

        pub inline fn swapCtx(_: *const Self, from: *TaskType, to: *TaskType) void {
            context_switch(&from.sp, &from.ip, to.sp, to.ip);
        }

        pub inline fn start(_: *const Self, t: *TaskType) noreturn {
            context_start(t.sp, t.ip);
        }
    };
}
