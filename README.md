# Thoth - Tiny Preemptive Scheduler

<img alt="What I think process schedulers probably look like" src="./thoth.png" />
I'm a great artist.
<hr/>

# Overview

`Thoth` is a very simple task registration and scheduling runtime. It supports both cooperative concurrency through tasks choosing to yield their control, or the potential for preemptive scheduling by forcing a yield through a timer or interrupt.

# Usage

The root of `Thoth` is the `ThothScheduler` struct. A configurable scheduler that allows specification of each Task's heap size. It performs no allocations and uses a super simple round robin scheduling algorithm, therefore making it deterministic. It currently supports x86-64, ARM32(UNTESTED, but thumb works so it probably does) and Thumb architectures.

In the same style that many Zig functions require an `Allocator` to be passed, Thoth requires a `Scheduler` to be specified at compile time, any struct that provides access to `start() *Task`, `getNext() *Task`, `getTaskType() type` and `register(TaskFn) !void` methods. This allows fully customizable scheduling algorithms, dynamic or static task storage, priority queues and anything else you can think of.

## Cooperative Scheduling

```zig
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

pub fn main() noreturn {
    const rr = RoundRobin.init();
    scheduler = ThothScheduler(RoundRobin).init(rr);

    scheduler.createTask(foo) catch @panic("Failed to register task");
    scheduler.createTask(bar) catch @panic("Failed to register task");

    scheduler.start() catch unreachable;
}
```

## Preemptive Scheduling (using linux timers + signals to give the illusion of an interrupt driven time quantum)

```zig
const ThothScheduler = @import("thoth").ThothScheduler;
const RoundRobin = @import("thoth").RoundRobin(max_tasks, stack_size);

var scheduler: ThothScheduler(RoundRobin) = undefined;

pub fn sigHandler(_: i32) callconv(.c) void {
    scheduler.yield();
}

pub fn wootWoot() noreturn {
    while (true) {
        std.debug.print("Woot Woot\n", .{});
    }
}

pub fn dootDoot() noreturn {
    while (true) {
        std.debug.print("Doot Doot\n", .{});
    }
}

pub fn main() void {
    const rr = RoundRobin.init();
    scheduler = ThothScheduler(RoundRobin).init(rr);

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
```

I hope you enjoy my first dive into RTOS scheduling :D

