//! Task definition

const std = @import("std");
const TaskFn = @import("thoth.zig").TaskFn;

pub fn Task(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 = undefined,
        sp: usize,
        ip: usize,
        returned: usize,
        padding: usize,

        rbx: usize,
        rbp: usize,
        r12: usize,
        r13: usize,
        r14: usize,
        r15: usize,

        const Self = @This();

        pub fn initTask(task: *Self, fun: TaskFn) void {
            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - @sizeOf(usize)]),
                .stack = undefined,
                .returned = 0,
                .padding = undefined,
                .rbx = 0,
                .rbp = 0,
                .r12 = 0,
                .r13 = 0,
                .r14 = 0,
                .r15 = 0,
            };
        }
    };
}
