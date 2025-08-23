//! x86-64 specific context switching and state tracking

const Task = @import("../task.zig").Task;

pub fn Context(comptime Scheduler: type) type {
    const TaskType = Scheduler.getTaskType();

    return struct {
        const Self = @This();
        pub inline fn swapCtx(_: *const Self, from: *TaskType, to: *TaskType) void {
            from.ip = asm volatile ("leaq 1f(%%rip), %[value]"
                : [value] "=r" (-> u64),
            );
            from.sp = asm volatile ("movq %%rsp, %[value]"
                : [value] "=r" (-> u64),
            );

            asm volatile (
                \\movq %[new_sp], %%rsp
                \\jmp *%[addr]
                \\1:
                :
                : [new_sp] "r" (to.sp),
                  [addr] "r" (to.ip),
                : "memory"
            );
        }

        pub inline fn start(_: *const Self, t: *TaskType) noreturn {
            asm volatile (
                \\movq %[stack], %%rsp
                \\jmp *%[addr]
                :
                : [stack] "r" (t.sp),
                  [addr] "r" (t.ip),
                : "memory"
            );

            unreachable;
        }
    };
}
