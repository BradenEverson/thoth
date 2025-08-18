# Thoth - The Blind Idiot Scheduler

<img alt="What I think process schedulers probably look like" src="./thoth.png" />
I'm a great artist.
<hr/>

# Overview

Named after the Lovecraftian Monster who runs the whole universe without knowing, `thoth` is a fitting name for a process scheduler in my opinion :)

`Thoth` is a very simple, cooperation based scheduler runtime for userland concurrency/"green threads". The goal for the future is to further create a form of preemptive scheduling as well that can be used for toy RTOSes.

# Usage

The root of `Thoth` is the `ThothScheduler` struct. A configurable scheduler that allows specification of each Task's heap size. It performs no allocations and uses a super simple round robin scheduling algorithm, therefore making it deterministic. 

## Cooperative Scheduling

```zig
const ThothScheduler = @import("thoth.zig").ThothScheduler;

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(max_tasks, stack_size) = undefined;

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
    scheduler = ThothScheduler(max_tasks, stack_size).init();

    scheduler.createTask(foo) catch @panic("Failed to register `foo`");
    scheduler.createTask(bar) catch @panic("Failed to register `bar`");

    scheduler.start() catch unreachable;
}
```

## Preemptive Scheduling (using linux timers + signals to give the illusion of an interrupt driven time quantum)

```zig
const ThothScheduler = @import("thoth.zig").ThothScheduler;

var scheduler: ThothScheduler(max_tasks, stack_size) = undefined;

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
```


# Future Work
- [ ] So far only IP and SP are maintained as a part of a Task's context, support for storing many additional registers is necessary.
- [ ] The only backend supported right now is x86-64, I personally want to use this as an RTOS on ST boards so that for sure needs to exist.
- [X] As another part of the whole RTOS goal, preemption or time-delta based rescheduling needs to be implemented. I'll need to look into how this can be pulled off.
- [ ] I'm still not sure if I want to support an `Allocator` because I like the idea of it being deterministic and as far as I can think of you would always know how many Tasks you want before run-time, but maybe that's worth looking into.
- [ ] Currently all tasks must be `noreturn`, supporting tasks that may not live forever could be beneficial

I hope you enjoy my first dive into userland scheduling :D

