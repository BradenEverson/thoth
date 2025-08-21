//! Basic Round-Robin Scheduler Interface Implementation

const Task = @import("../task.zig").Task;
const thoth = @import("../thoth.zig");
const SchedulerErrors = thoth.SchedulerErrors;
const TaskFn = thoth.TaskFn;

const std = @import("std");

pub fn RoundRobin(comptime max_tasks: u32, comptime stack_size: u32) type {
    return struct {
        tasks: [max_tasks]Task(stack_size),
        num_tasks: usize,
        curr_task: usize,

        const Self = @This();

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

            task.* = .{
                .ip = @intFromPtr(fun),
                .sp = @intFromPtr(&task.stack[task.stack.len - 8]),
                .stack = undefined,
            };

            self.num_tasks += 1;
        }

        pub inline fn getNext(self: *Self) *Task(stack_size) {
            self.curr_task = @rem(self.curr_task + 1, self.num_tasks);
            return &self.tasks[self.curr_task];
        }
    };
}
