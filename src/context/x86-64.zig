//! x86-64 Context Tracking and Switching

const std = @import("std");

const c = @cImport(@cInclude("ucontext.h"));

mcontext: std.os.linux.mcontext_t,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    var mcontext: std.os.linux.mcontext_t = undefined;
    @memset(std.mem.asBytes(&mcontext), 0);
    mcontext.gregs[std.os.linux.REG.RIP] = entry;
    mcontext.gregs[std.os.linux.REG.RSP] = top;
    return Self{ .mcontext = mcontext };
}

pub inline fn saveCtx(self: *Self, ctx: *const anyopaque) void {
    const mctx = @as(*const std.os.linux.mcontext_t, @ptrCast(@alignCast(ctx)));
    self.mcontext = mctx.*;
}

pub inline fn restoreCtx(self: *const Self) noreturn {
    var uctx: c.ucontext_t = undefined;
    _ = c.getcontext(&uctx);

    uctx.uc_mcontext = self.mcontext;

    _ = c.setcontext(@ptrCast(&uctx));
    unreachable;
}
