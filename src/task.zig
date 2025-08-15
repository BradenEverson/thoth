//! A single task of execution, pretty much just a function pointer with context

const std = @import("std");
const builtin = @import("builtin");
const X86_64Context = @import("context/x86-64.zig");
const ThothScheduler = @import("thoth.zig");

stack: []align(16) u8,
context: Context,
entry_fn: *const fn () noreturn,

const Task = @This();

pub const Context = switch (builtin.cpu.arch) {
    .x86_64 => X86_64Context,
    else => @compileError("Unsupported CPU architecture"),
};

pub fn init(allocator: std.mem.Allocator, entry: *const fn () noreturn, stack_size: usize) !Task {
    const stack = try allocator.alignedAlloc(u8, 16, stack_size);

    const stack_top = @intFromPtr(stack.ptr) + stack.len;
    const aligned_top = stack_top & ~@as(usize, 0xF);

    const context = Context.init(aligned_top, @intFromPtr(entry));

    return Task{
        .stack = stack,
        .context = context,
        .entry_fn = entry,
    };
}

pub fn deinit(self: *Task, allocator: std.mem.Allocator) void {
    allocator.free(self.stack);
}
