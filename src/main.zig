//! Sample Linux runtime for the scheduler

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

// 10ms per process for now, will tweak later
const TIME_QUANTUM: comptime_int = 10_000;
const US_PER_S: comptime_int = 1_000_000;

var scheduler: ?ThothScheduler = null;

pub fn sigHandler(_: i32, _: *const std.os.linux.siginfo_t, ctx_ptr: ?*anyopaque) callconv(.c) void {
    const ctx: *std.os.linux.ucontext_t = @ptrCast(@alignCast(ctx_ptr.?));
    const pc = ctx.mcontext.gregs[std.os.linux.REG.RIP];

    if (scheduler) |*sched| {
        sched.contextSwitch(pc);
    }
}

pub fn wootWoot() noreturn {
    while (true) {
        std.debug.print("Woot Woot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn dootDoot() noreturn {
    while (true) {
        std.debug.print("Doot Doot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn main() void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();

    var action: std.os.linux.Sigaction = .{ .flags = std.os.linux.SA.SIGINFO, .mask = std.os.linux.empty_sigset, .handler = .{ .sigaction = sigHandler } };

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

    scheduler.?.register(wootWoot) catch @panic("Failed to register a new task");
    scheduler.?.register(dootDoot) catch @panic("Failed to register a new task");

    scheduler.?.start();

    while (true) {
        std.time.sleep(100_000_000);
    }
}
