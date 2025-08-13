//! Sample runtime usage

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

pub fn timerHandler(_: i32) callconv(.C) void {
    std.debug.print("Signal received\n", .{});
    _ = alarm(1);
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

    _ = alarm(1);
    while (true) {}
}

fn alarm(seconds: usize) usize {
    return std.os.linux.syscall1(
        .alarm,
        seconds,
    );
}
