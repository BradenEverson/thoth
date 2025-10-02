//! Task definition

const std = @import("std");
const builtin = @import("builtin");
const TaskFn = @import("thoth.zig").TaskFn;

pub fn Task(comptime stack_size: u32) type {
    switch (builtin.cpu.arch) {
        .x86_64 => return x86Task(stack_size),
        .arm => return Arm32Task(stack_size),
        .thumb => return ThumbTask(stack_size),
        .xtensa => return XtensaTask(stack_size),
        else => @compileError("Unsupported CPU architecture: " ++ @tagName(builtin.cpu.arch)),
    }
}

pub fn x86Task(comptime stack_size: u32) type {
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
pub fn Arm32Task(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 = undefined,
        sp: usize,
        ip: usize,
        returned: usize,

        r4: usize,
        r5: usize,
        r6: usize,
        r7: usize,
        r8: usize,
        r9: usize,
        r10: usize,
        r11: usize,
        r14: usize,

        const Self = @This();

        pub fn initTask(task: *Self, fun: TaskFn) void {
            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - @sizeOf(usize)]),
                .stack = undefined,
                .returned = 0,
                .padding = undefined,
                .r4 = 0,
                .r5 = 0,
                .r6 = 0,
                .r7 = 0,
                .r8 = 0,
                .r9 = 0,
                .r10 = 0,
                .r11 = 0,
                .r14 = 0,
            };
        }
    };
}

pub fn ThumbTask(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 = undefined,
        sp: usize,
        ip: usize,
        returned: usize,

        r4: usize,
        r5: usize,
        r6: usize,
        r7: usize,
        r8: usize,
        r9: usize,
        r10: usize,
        r11: usize,
        r14: usize,

        const Self = @This();

        pub fn initTask(task: *Self, fun: TaskFn) void {
            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - @sizeOf(usize)]),
                .stack = undefined,
                .returned = 0,
                .padding = undefined,
                .r4 = 0,
                .r5 = 0,
                .r6 = 0,
                .r7 = 0,
                .r8 = 0,
                .r9 = 0,
                .r10 = 0,
                .r11 = 0,
                .r14 = 0,
            };
        }
    };
}

pub fn XtensaTask(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 = undefined,
        sp: usize,
        ip: usize,
        returned: usize,

        a12: usize,
        a13: usize,
        a14: usize,
        a15: usize,
        a8: usize,
        a9: usize,
        a10: usize,
        a11: usize,

        const Self = @This();

        pub fn initTask(task: *Self, fun: TaskFn) void {
            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - @sizeOf(usize)]),
                .stack = undefined,
                .returned = 0,
                .a12 = 0,
                .a13 = 0,
                .a14 = 0,
                .a15 = 0,
                .a8 = 0,
                .a9 = 0,
                .a10 = 0,
                .a11 = 0,
            };
        }
    };
}
