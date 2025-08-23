//! Sample Linux Runtime

const std = @import("std");
const ThothScheduler = @import("thoth").ThothScheduler;
const RoundRobin = @import("thoth").RoundRobin(max_tasks, stack_size);

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(RoundRobin) = undefined;

pub fn foo() noreturn {
    var i: u32 = 0;
    while (true) {
        std.debug.print("Foo: {}\n", .{i});
        i += 1;
        scheduler.yield();
    }
}

pub fn bar() noreturn {
    var i: u32 = 0;
    while (true) {
        std.debug.print("Bar: {}\n", .{i});
        i += 1;
        scheduler.yield();
    }
}

pub fn wootWoot() noreturn {
    var i: u32 = 0;
    while (true) {
        std.debug.print("Woot Woot: {}\n", .{i});
        i += 1;
        scheduler.yield();
    }
}

pub fn main() noreturn {
    const rr = RoundRobin.init();
    scheduler = ThothScheduler(RoundRobin).init(rr);

    scheduler.createTask(foo) catch @panic("Failed to register task");
    scheduler.createTask(bar) catch @panic("Failed to register task");
    scheduler.createTask(wootWoot) catch @panic("Failed to register task");

    scheduler.start() catch unreachable;
}
