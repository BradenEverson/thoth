//! Basic Round-Robin Scheduler Interface Implementation

const Task = @import("../task.zig").Task;
const scheduler = @import("../scheduler.zig");
const Scheduler = scheduler.Scheduler;
const SchedulerErrors = scheduler.SchedulerErrors;
const TaskFn = scheduler.TaskFn;

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

        pub inline fn chooseNext(self: *Self) *Task(stack_size) {
            self.curr_task = @rem(self.curr_task + 1, self.num_tasks);
            return &self.tasks[self.curr_task];
        }

        pub inline fn scheduler(self: *Self) Scheduler(stack_size) {
            return .{
                .ctx = self,
                .registerFn = struct {
                    fn registerImpl(ctx: *anyopaque, task: TaskFn) SchedulerErrors!void {
                        const rr: *RoundRobin(max_tasks, stack_size) = @ptrCast(@alignCast(ctx));

                        try rr.register(task);
                    }
                }.registerImpl,

                .getNextFn = struct {
                    fn nextImpl(ctx: *anyopaque) *Task(stack_size) {
                        const rr: *RoundRobin(max_tasks, stack_size) = @ptrCast(@alignCast(ctx));

                        return rr.chooseNext();
                    }
                }.nextImpl,

                .startFn = struct {
                    fn startImpl(ctx: *anyopaque) SchedulerErrors!*Task(stack_size) {
                        const rr: *RoundRobin(max_tasks, stack_size) = @ptrCast(@alignCast(ctx));

                        return try rr.start();
                    }
                }.startImpl,
            };
        }
    };
}
