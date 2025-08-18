//! Sample Thoth Runtime that uses preemption instead

const std = @import("std");
const ThothScheduler = @import("thoth.zig").ThothScheduler;

// 10ms per process for now, will tweak later
const TIME_QUANTUM: comptime_int = 10_000;
const US_PER_S: comptime_int = 1_000_000;

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(max_tasks, stack_size) = undefined;

pub fn sigHandler(_: i32) callconv(.c) void {
    scheduler.yield();
}

pub fn wootWoot() noreturn {
    while (true) {
        std.debug.print("Woot Woot\n", .{});
        std.time.sleep(10_000_000);
    }
}

pub fn dootDoot() noreturn {
    while (true) {
        std.debug.print("Doot Doot\n", .{});
        std.time.sleep(10_000_000);
    }
}

pub fn main() void {
    scheduler = ThothScheduler(max_tasks, stack_size).init();

    var action: std.os.linux.Sigaction = .{ .flags = std.os.linux.SA.SIGINFO | std.os.linux.SA.NODEFER, .mask = std.os.linux.empty_sigset, .handler = .{ .handler = sigHandler } };

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

    scheduler.createTask(wootWoot) catch @panic("Failed to register a wootWoot");
    scheduler.createTask(dootDoot) catch @panic("Failed to register a dootDoot");

    scheduler.start() catch unreachable;
}
