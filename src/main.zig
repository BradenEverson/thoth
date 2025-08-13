//! Sample Linux runtime for the scheduler

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

// 10ms per process for now, will tweak later
const TIME_QUANTUM: comptime_int = 10_000;
const US_PER_S: comptime_int = 1_000_000;

var scheduler: ?ThothScheduler = null;
var i: u128 = 0;

pub fn timerHandler(_: i32) callconv(.C) void {
    i += 1;
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();

    var action: std.os.linux.Sigaction = undefined;
    action.flags = 0;
    action.mask = std.os.linux.empty_sigset;
    action.handler.sigaction = null;
    action.handler.handler = timerHandler;

    _ = std.os.linux.sigaction(std.os.linux.SIG.ALRM, &action, null);

    var spec: std.os.linux.itimerspec = .{
        .it_value = .{
            .sec = TIME_QUANTUM / US_PER_S,
            .nsec = TIME_QUANTUM % US_PER_S,
        },
        .it_interval = .{
            .sec = TIME_QUANTUM / US_PER_S,
            .nsec = TIME_QUANTUM % US_PER_S,
        },
    };

    _ = std.os.linux.setitimer(@intFromEnum(std.os.linux.ITIMER.REAL), &spec, null);

    while (true) {
        std.debug.print("{}\n", .{i});
    }
}
