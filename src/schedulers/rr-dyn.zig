//! Round Robin Scheduler Implementation that uses an allocator to store it's tasks

const Task = @import("../task.zig").Task;
const thoth = @import("../thoth.zig");
const SchedulerErrors = thoth.SchedulerErrors;
const TaskFn = thoth.TaskFn;

const std = @import("std");

pub fn RoundRobinDynamic(comptime stack_size: u32) type {
    return struct {
        tasks: []Task(stack_size),
        allocator: std.mem.Allocator,

        capacity: usize,
        num_tasks: usize,
        curr_task: usize,

        const Self = @This();

        pub fn init(allocator: std.mem.Allocator) Self {
            return Self{
                .allocator = allocator,
                .tasks = undefined,

                .num_tasks = 0,
                .curr_task = 0,
                .capacity = 0,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.tasks);
        }

        pub inline fn start(self: *Self) SchedulerErrors!*Task(stack_size) {
            if (self.num_tasks == 0) {
                return error.NoTasksRegistered;
            }

            self.curr_task = 0;
            return &self.tasks[self.curr_task];
        }

        fn realloc(self: *Self) !void {
            if (self.num_tasks == 0) {
                self.capacity = 4;
                self.tasks = try self.allocator.alloc(Task(stack_size), self.capacity);
            } else {
                self.capacity *= 2;
                self.tasks = try self.allocator.realloc(self.tasks, self.capacity);
            }
        }

        pub inline fn register(self: *Self, fun: TaskFn) !void {
            if (self.num_tasks == self.capacity) {
                try self.realloc();
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
