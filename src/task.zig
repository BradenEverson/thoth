//! A single task of execution, pretty much just a function pointer with context

const std = @import("std");
const builtin = @import("builtin");
const X86_64Context = @import("context/x86-64.zig");

stack: []align(std.heap.pageSize()) u8,
context: Context,
entry_fn: *const fn () noreturn,
running: bool,

const Task = @This();

pub const Context = switch (builtin.cpu.arch) {
    .x86_64 => X86_64Context,
    else => @compileError("Unsupported CPU architecture"),
};

pub fn init(allocator: std.mem.Allocator, entry: *const fn () noreturn, stack_size: usize) !Task {
    const stack = try allocator.alignedAlloc(u8, std.heap.pageSize(), stack_size);

    const stack_top = @intFromPtr(stack.ptr) + stack.len;
    const context = Context.init(stack_top, @intFromPtr(entry));

    return Task{
        .stack = stack,
        .context = context,
        .entry_fn = entry,
        .running = false,
    };
}

pub fn deinit(self: *Task, allocator: std.mem.Allocator) void {
    allocator.free(self.stack);
}
