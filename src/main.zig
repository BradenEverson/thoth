//! Sample Linux runtime for the scheduler

const std = @import("std");
const ThothScheduler = @import("thoth.zig");
const Task = @import("task.zig");

// 10ms per process for now, will tweak later
pub const TIME_QUANTUM_MS: isize = 10;
pub const NS_PER_MS: isize = 10_000;

var scheduler: ?ThothScheduler = null;

pub fn sigHandler(_: i32, _: *const std.os.linux.siginfo_t, ctx_ptr: ?*anyopaque) callconv(.c) void {
    const ctx: *std.os.linux.ucontext_t = @ptrCast(@alignCast(ctx_ptr.?));

    if (scheduler) |*sched| {
        sched.contextSwitch(&ctx.mcontext);
    }
}

pub fn wootWoot(t: *Task) noreturn {
    _ = t;
    while (true) {
        std.debug.print("Woot Woot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn dootDoot(t: *Task) noreturn {
    _ = t;
    while (true) {
        std.debug.print("Doot Doot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn bootBoot(t: *Task) noreturn {
    _ = t;
    while (true) {
        std.debug.print("Boot Boot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn scootScoot(t: *Task) noreturn {
    _ = t;
    while (true) {
        std.debug.print("Scoot Scoot\n", .{});
        std.time.sleep(100_000_000);
    }
}

pub fn main() noreturn {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();

    var action: std.os.linux.Sigaction = .{ .flags = std.os.linux.SA.SIGINFO | std.os.linux.SA.NODEFER, .mask = std.os.linux.empty_sigset, .handler = .{ .sigaction = sigHandler } };

    _ = std.os.linux.sigaction(std.os.linux.SIG.ALRM, &action, null);

    var spec: std.os.linux.itimerspec = .{
        .it_value = .{
            .sec = 0,
            .nsec = TIME_QUANTUM_MS * NS_PER_MS,
        },
        .it_interval = .{
            .sec = 0,
            .nsec = TIME_QUANTUM_MS * NS_PER_MS,
        },
    };

    const ret: i64 = @bitCast(std.os.linux.setitimer(@intFromEnum(std.os.linux.ITIMER.REAL), &spec, null));
    if (ret != 0) {
        std.debug.print("Failed :( {}\n", .{ret});
        @panic("OH NO\n");
    }

    scheduler.?.register(wootWoot) catch @panic("Failed to register a new task");
    scheduler.?.register(dootDoot) catch @panic("Failed to register a new task");
    scheduler.?.register(bootBoot) catch @panic("Failed to register a new task");
    scheduler.?.register(scootScoot) catch @panic("Failed to register a new task");

    scheduler.?.start();

    unreachable;
}
