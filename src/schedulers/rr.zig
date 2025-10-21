//! Basic Round-Robin Scheduler Interface Implementation

const Task = @import("../task.zig").Task;
const thoth = @import("../thoth.zig");
const IoReq = @import("../io.zig").IoSimCall;
const SchedulerErrors = thoth.SchedulerErrors;
const TaskFn = thoth.TaskFn;

const std = @import("std");

pub fn RoundRobin(comptime max_tasks: u32, comptime stack_size: u32) type {
    return struct {
        tasks: [max_tasks]Task(stack_size),
        num_tasks: usize,
        curr_task: usize,

        const Self = @This();

        pub fn getTaskType() type {
            return Task(stack_size);
        }

        pub fn getIoType() type {
            return IoReq;
        }

        pub fn getTaskConstructor() type {
            return TaskFn;
        }

        pub fn init() Self {
            return Self{
                .tasks = std.mem.zeroes([max_tasks]Task(stack_size)),
                .num_tasks = 0,
                .curr_task = 0,
            };
        }

        pub inline fn start(self: *Self) SchedulerErrors!*Task(stack_size) {
            if (self.num_tasks == 0) {
                return error.NoTasksRegistered;
            }

            self.curr_task = 0;
            return &self.tasks[self.curr_task];
        }

        pub inline fn register(self: *Self, fun: TaskFn) !void {
            if (self.num_tasks == max_tasks) {
                return error.AllTasksRegistered;
            }

            const task = &self.tasks[self.num_tasks];
            task.initTask(fun);

            self.num_tasks += 1;
        }

        pub inline fn getNext(self: *Self) *Task(stack_size) {
            self.curr_task = @rem(self.curr_task + 1, self.num_tasks);
            while (self.tasks[self.curr_task].returned == 1) {
                self.curr_task = @rem(self.curr_task + 1, self.num_tasks);
            }

            return &self.tasks[self.curr_task];
        }

        pub inline fn ioYield(self: *Self, io: IoReq) *Task(stack_size) {
            _ = io;
            return self.getNext();
        }

        /// Called from the ThothScheduler when it has been requested to end,
        /// use this in simulation and data collection to log heuristics
        pub fn stop(self: *Self) void {
            std.debug.print("Time Reached, Scheduler Ended\n", .{});
            _ = self;
        }
    };
}
