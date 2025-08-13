//! Sample runtime usage

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    var scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();
}
