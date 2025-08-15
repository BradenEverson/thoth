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

        self.curr.?.context.restoreCtx();
    }
}

pub inline fn contextSwitch(self: *Self, ctx: *const anyopaque) noreturn {
    self.curr.?.context.saveCtx(@ptrCast(@alignCast(ctx)));
    self.switchToNextTask();
    self.curr.?.context.restoreCtx();
}

inline fn switchToNextTask(self: *Self) void {
    self.curr_idx = (self.curr_idx + 1) % self.queue.items.len;
    self.curr = &self.queue.items[self.curr_idx];
}

pub inline fn yield(self: *Self) void {
    var ctx: std.os.linux.ucontext_t = undefined;
    _ = std.os.linux.getcontext(&ctx);

    self.contextSwitch(&ctx.mcontext);
}
