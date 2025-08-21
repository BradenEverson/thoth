//! Sample Linux Runtime that uses a dynamic round robin scheduler

const std = @import("std");
const ThothScheduler = @import("thoth").ThothScheduler;
const RoundRobin = @import("thoth").RoundRobinDynamic(stack_size);

const stack_size = 16 * 1024;

var scheduler: ThothScheduler(RoundRobin, stack_size) = undefined;

pub fn foo() noreturn {
    while (true) {
        std.debug.print("This task was dynamically allocated :O\n", .{});
        scheduler.yield();
    }
}

pub fn bar() noreturn {
    while (true) {
        std.debug.print("This task too\n", .{});
        scheduler.yield();
    }
}

pub fn wootWoot() noreturn {
    while (true) {
        std.debug.print("Also this one\n", .{});
        scheduler.yield();
    }
}

pub fn main() noreturn {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    const rr = RoundRobin.init(alloc);
    scheduler = ThothScheduler(RoundRobin, stack_size).init(rr);

    scheduler.createTask(foo) catch @panic("Failed to register task");
    scheduler.createTask(bar) catch @panic("Failed to register task");
    scheduler.createTask(wootWoot) catch @panic("Failed to register task");

    scheduler.start() catch unreachable;
}
