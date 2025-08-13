//! Sample runtime usage

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

const c = @cImport({
    @cInclude("unistd.h");
});

pub fn timerHandler(_: i32) callconv(.C) void {
    std.debug.print("Signal received\n", .{});
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    var scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();

    var action: std.os.linux.Sigaction = undefined;
    action.flags = 0;
    action.mask = std.os.linux.empty_sigset;
    action.handler.sigaction = null;
    action.handler.handler = timerHandler;

    _ = std.os.linux.sigaction(std.os.linux.SIG.ALRM, &action, null);

    _ = c.ualarm(10000, 10000);
    while (true) {}
}
