//! Sample Linux Runtime

const std = @import("std");
const ThothScheduler = @import("thoth.zig").ThothScheduler;

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(max_tasks, stack_size) = undefined;

pub fn foo() noreturn {
    var i: u64 = 0;
    while (true) {
        std.debug.print("Foo: {} at {X}\n", .{ i & 0xFFFFFFFF, &i });
        i += 1;
        scheduler.yield();
    }
}

pub fn bar() noreturn {
    var i: u64 = 0;
    while (true) {
        std.debug.print("Bar: {} at {X}\n", .{ i >> 32, &i });
        i += 1 << 32;
        scheduler.yield();
    }
}

pub fn main() noreturn {
    scheduler = ThothScheduler(max_tasks, stack_size).init();

    scheduler.createTask(foo) catch @panic("Failed to register task");
    scheduler.createTask(bar) catch @panic("Failed to register task");

    scheduler.start() catch unreachable;
}
