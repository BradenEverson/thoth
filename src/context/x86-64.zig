//! x86-64 Context Tracking and Switching

const std = @import("std");

const c = @cImport(@cInclude("ucontext.h"));

ucontext: c.ucontext_t,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    var ucontext: c.ucontext_t = undefined;
    @memset(std.mem.asBytes(&ucontext), 0);

    ucontext.uc_mcontext.gregs[std.os.linux.REG.RIP] = @bitCast(entry);
    ucontext.uc_mcontext.gregs[std.os.linux.REG.RSP] = @bitCast(top);

    ucontext.uc_stack.ss_sp = @ptrFromInt(top);
    ucontext.uc_stack.ss_size = @bitCast(std.heap.pageSize());
    ucontext.uc_stack.ss_flags = 0;

    return Self{ .ucontext = ucontext };
}

pub inline fn saveCtx(self: *Self, ctx: *const anyopaque) void {
    _ = self;
    _ = ctx;
}

pub inline fn restoreCtx(self: *Self) noreturn {
    std.debug.print("{any}\n", .{self.ucontext});
    _ = c.setcontext(&self.ucontext);

    unreachable;
}
