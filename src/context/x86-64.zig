//! x86-64 Context Tracking and Switching
const std = @import("std");

rip: u64,
rsp: u64,

stack_top: u64,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    return Self{
        .rip = entry,
        .stack_top = top,
        .rsp = top,
    };
}

pub inline fn saveCtx(
    self: *Self,
    mcontext: *const std.os.linux.mcontext_t,
) void {
    self.rip = mcontext.gregs[std.os.linux.REG.RIP];
    self.rsp = mcontext.gregs[std.os.linux.REG.RSP];
}

pub inline fn restoreCtx(self: *const Self) noreturn {
    asm volatile (
        \\ mov %[rsp], %%rsp
        \\ jmp *%[rip]
        :
        : [rip] "r" (self.rip),
          [rsp] "m" (self.rsp),
        : "memory", "rsp"
    );

    unreachable;
}
