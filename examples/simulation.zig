//! Simulation Task Definitions

const std = @import("std");
const ThothScheduler = @import("thoth").ThothScheduler;
const RoundRobin = @import("thoth").RoundRobin(max_tasks, stack_size);

const stack_size = 16 * 1024;
const max_tasks = 10;

var scheduler: ThothScheduler(RoundRobin) = undefined;

var current_temp: u16 = 0;
var target_temp: u16 = 200;

pub fn temperatureMonitorTask() noreturn {
    while (true) {
        scheduler.ioYield(.{ .call_type = .adc_read, .time_out = 50 });

        if (current_temp < target_temp) {
            scheduler.ioYield(.{ .call_type = .gpio_interrupt, .time_out = 1 });
        }

        scheduler.ioYield(.{ .call_type = .uart_transmit, .time_out = 20 });

        scheduler.ioYield(.{ .call_type = .sleep, .time_out = 100_000 });
    }
}

var step_count: u32 = 0;
var target_steps: u32 = 1000;

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

        var i: u32 = 0;
        while (i < 1000) : (i += 1) {
            gcode_buffer[i % 64] += i;
        }

        scheduler.ioYield(.{ .call_type = .uart_transmit, .time_out = 50 });

        scheduler.ioYield(.{ .call_type = .sleep, .time_out = 50_000 });
    }
}

pub fn main() noreturn {
    const rr = RoundRobin.init();
    scheduler = ThothScheduler(RoundRobin).init(rr);

    scheduler.createTask(temperatureMonitorTask);
    scheduler.createTask(stepperMotorTask);
    scheduler.createTask(gcodeProcessorTask);

    scheduler.start() catch unreachable;
}
