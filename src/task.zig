//! Task definition

const std = @import("std");
const TaskFn = @import("thoth.zig").TaskFn;

pub fn Task(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 = undefined,
        sp: usize,
        ip: usize,

        const Self = @This();

        pub fn initTask(task: *Self, fun: TaskFn) void {
            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - @sizeOf(usize)]),
                .stack = undefined,
            };
        }
    };
}
