//! Async runtime struct

const std = @import("std");
const Task = @import("task.zig");
const Allocator = std.mem.Allocator;

allocator: Allocator,
curr: usize,
queue: std.ArrayList(Task),

const Self = @This();

pub fn init(allocator: Allocator) Self {
    return Self{ .allocator = allocator, .curr = 0, .queue = std.ArrayList(Task).init(allocator) };
}

pub fn deinit(self: *Self) void {
    self.queue.deinit();
}
