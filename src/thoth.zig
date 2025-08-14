//! Async runtime struct

const std = @import("std");
const Task = @import("task.zig");
const Allocator = std.mem.Allocator;

allocator: Allocator,
curr: ?*Task,
curr_idx: usize,

queue: std.ArrayList(Task),

const Self = @This();

pub fn init(allocator: Allocator) Self {
    return Self{ .allocator = allocator, .curr = null, .curr_idx = 0, .queue = std.ArrayList(Task).init(allocator) };
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
        self.curr_idx = 0;
        self.curr = &self.queue.items[self.curr_idx];

        self.curr.?.running = true;
        // TODO: We should do this some other way
        self.curr.?.entry_fn();
    }
}

pub fn contextSwitch(self: *Self, pc: u64, pc_targ: *u64) void {
    self.curr.?.context.saveCtx(pc);

    self.curr_idx = (self.curr_idx + 1) % self.queue.items.len;
    self.curr = &self.queue.items[self.curr_idx];

    if (self.curr.?.running) {
        pc_targ.* = self.curr.?.context.pc;
    } else {
        self.curr.?.running = true;
        self.curr.?.entry_fn();
    }
}
