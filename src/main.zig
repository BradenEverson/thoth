//! Sample Linux Runtime

const std = @import("std");
const ThothScheduler = @import("thoth.zig");

var scheduler: ThothScheduler = undefined;

const stack_size = 16 * 1024;
const max_tasks = 16;

pub fn foo() noreturn {
    var i: u32 = 0;
    while (true) {
        std.debug.print("Foo: {}\n", .{i});
        i += 1;
    }
}

pub fn bar() noreturn {
    var i: u32 = 0;
    while (true) {
        std.debug.print("Bar: {}\n", .{i});
        i += 1;
    }
}

pub fn main() noreturn {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const alloc = gpa.allocator();

    scheduler = ThothScheduler(max_tasks, stack_size).init(alloc);

    scheduler.createTask(foo);
    scheduler.createTask(bar);

    scheduler.run();
}
