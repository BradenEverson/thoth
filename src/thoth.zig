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
    for (self.queue.items) |*task| {
        task.deinit();
    }
    self.queue.deinit();
}

pub fn register(self: *Self, func: *const fn () noreturn) !void {
    const task = try Task.init(self.allocator, func, std.heap.pageSize());
    try self.queue.append(task);
}

pub fn start(self: *Self) void {
    if (self.queue.items.len != 0) {
        self.curr = 0;
        // TODO: Context switch into curr?
    }
}

pub fn contextSwitch(self: *Self) void {
    _ = self;
}
