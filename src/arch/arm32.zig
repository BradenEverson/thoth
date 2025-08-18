//! ARM32 specific context switching and state tracking
//! THIS IS UNTESTED!!! TODO: TEST THIS

const Task = @import("../task.zig").Task;

pub fn Context(comptime stack_size: u32) type {
    const TaskType = Task(stack_size);
    return struct {
        const Self = @This();

        pub inline fn swapCtx(_: *const Self, from: *TaskType, to: *TaskType) void {
            from.ip = asm volatile (
                \\adr %[value], 1f
                : [value] "=r" (-> u32),
            );

            from.sp = asm volatile (
                \\mov %[value], sp
                : [value] "=r" (-> u32),
            );

            asm volatile (
                \\mov sp, %[new_sp]
                \\bx %[addr]
                \\1:
                :
                : [new_sp] "r" (to.sp),
                  [addr] "r" (to.ip),
                : "memory"
            );
        }

        pub inline fn start(_: *const Self, t: *TaskType) noreturn {
            asm volatile (
                \\mov sp, %[stack]
                \\bx %[addr]
                :
                : [stack] "r" (t.sp),
                  [addr] "r" (t.ip),
                : "memory"
            );

            unreachable;
        }
    };
}
