//! Sample Thoth Runtime that uses preemption instead

const std = @import("std");
const ThothScheduler = @import("thoth").ThothScheduler;
const RoundRobin = @import("thoth").RoundRobin(max_tasks, stack_size);

// 10ms per process for now, will tweak later
const TIME_QUANTUM: isize = 10_000;
const US_PER_S: isize = 1_000_000;

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(RoundRobin) = undefined;

var current_temp: u16 = 0;
var target_temp: u16 = 0;
var step_count: u32 = 0;
var target_steps: u32 = 1000;

var ms_target: isize = 1000 * 1000;

pub fn sigHandler(_: i32) callconv(.c) void {
    scheduler.stop();
}

pub fn temperatureMonitorTask() noreturn {
    while (true) {
        scheduler.ioYield(.{ .call_type = .adc_read, .time_out = 50 });

        if (current_temp < target_temp) {
            scheduler.ioYield(.{ .call_type = .gpio_interrupt, .time_out = 1 });
        }

        scheduler.ioYield(.{ .call_type = .uart_transmit, .time_out = 20 });

        scheduler.ioYield(.{ .call_type = .sleep, .time_out = 100_000 });
    }

    scheduler.ret();
}

pub fn stepperMotorTask() noreturn {
    while (step_count < target_steps) {
        scheduler.ioYield(.{ .call_type = .gpio_interrupt, .time_out = 2 });

        scheduler.ioYield(.{ .call_type = .gpio_interrupt, .time_out = 1 });

        step_count += 1;
        scheduler.ioYield(.{ .call_type = .sleep, .time_out = 2_000 });
    }

    scheduler.ret();
}

pub fn gcodeProcessorTask() noreturn {
    var gcode_buffer: [64]u8 = undefined;

    while (true) {
        scheduler.ioYield(.{ .call_type = .uart_receive, .time_out = 100 });

        var i: u8 = 0;
        while (i < 255) : (i += 1) {
            gcode_buffer[i % 64] +%= i;
        }

        scheduler.ioYield(.{ .call_type = .uart_transmit, .time_out = 50 });

        scheduler.ioYield(.{ .call_type = .sleep, .time_out = 50_000 });
    }

    scheduler.ret();
}

pub fn main() void {
    var args_iter = std.process.args();

    _ = args_iter.next();

    const arg_slice = args_iter.next();

    if (arg_slice) |arg| {
        const parsed: isize = std.fmt.parseInt(isize, arg, 10) catch @panic("Please provide an int for simulation runtime ms");
        ms_target = parsed * 1000;
    }

    const rr = RoundRobin.init();
    scheduler = ThothScheduler(RoundRobin).init(rr);

    var action: std.os.linux.Sigaction = .{ .flags = std.os.linux.SA.SIGINFO | std.os.linux.SA.NODEFER, .mask = std.os.linux.empty_sigset, .handler = .{ .handler = sigHandler } };

    _ = std.os.linux.sigaction(std.os.linux.SIG.ALRM, &action, null);

    var spec: std.os.linux.itimerspec = .{
        .it_value = .{
            .sec = @divTrunc(ms_target, US_PER_S),
            .nsec = @rem(ms_target, US_PER_S),
        },

        .it_interval = .{
            .sec = @divTrunc(ms_target, US_PER_S),
            .nsec = @rem(ms_target, US_PER_S),
        },
    };

    _ = std.os.linux.setitimer(@intFromEnum(std.os.linux.ITIMER.REAL), &spec, null);

    target_temp = 250;

    scheduler.createTask(temperatureMonitorTask) catch @panic("Failed to register");
    scheduler.createTask(stepperMotorTask) catch @panic("Failed to register");
    scheduler.createTask(gcodeProcessorTask) catch @panic("Failed to register");

    scheduler.start() catch unreachable;
}
