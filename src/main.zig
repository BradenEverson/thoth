//! Sample Linux runtime for the scheduler

const std = @import("std");
const ThothScheduler = @import("thoth.zig");
const Task = @import("task.zig");

var scheduler: ThothScheduler = undefined;

// 10ms per process for now, will tweak later
pub const TIME_QUANTUM_MS: isize = 10;
pub const NS_PER_MS: isize = 10_000;

pub fn wootWoot() noreturn {
    while (true) {
        std.debug.print("Woot Woot\n", .{});
        scheduler.yield();
    }
}

pub fn dootDoot() noreturn {
    while (true) {
        std.debug.print("Doot Doot\n", .{});
        scheduler.yield();
    }
}

pub fn bootBoot() noreturn {
    while (true) {
        std.debug.print("Boot Boot\n", .{});
        scheduler.yield();
    }
}

pub fn scootScoot() noreturn {
    while (true) {
        std.debug.print("Scoot Scoot\n", .{});
        scheduler.yield();
    }
}

pub fn main() noreturn {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    scheduler = ThothScheduler.init(alloc);
    defer scheduler.deinit();

    scheduler.register(wootWoot) catch @panic("Failed to register a new task");
    scheduler.register(dootDoot) catch @panic("Failed to register a new task");
    scheduler.register(bootBoot) catch @panic("Failed to register a new task");
    scheduler.register(scootScoot) catch @panic("Failed to register a new task");

    scheduler.start();

    unreachable;
}
