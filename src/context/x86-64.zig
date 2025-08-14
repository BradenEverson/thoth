//! x86-64 Context Tracking and Switching
const std = @import("std");

rax: u64,

rip: u64,
rsp: u64,

stack_top: u64,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    return Self{
        .rip = entry,
        .stack_top = top,
        .rsp = top,
        .rax = 0,
    };
}

pub fn saveCtx(
    self: *Self,
    mcontext: *const std.os.linux.mcontext_t,
) void {
    self.rip = mcontext.gregs[std.os.linux.REG.RIP];
    self.rsp = mcontext.gregs[std.os.linux.REG.RSP];
    self.rax = mcontext.gregs[std.os.linux.REG.RAX];

    std.debug.print("PC: 0x{X}\nSP: 0x{X}\n", .{ self.rip, self.rsp });
}

pub fn restoreCtx(self: *const Self) noreturn {
    asm volatile (
        \\ mov %[rsp], %%rsp
        \\ mov %[rax], %%rax
        \\ jmp *%[rip]
        :
        : [rip] "r" (self.rip),
          [rax] "r" (self.rax),
          [rsp] "m" (self.rsp),
        : "memory", "rax", "rsp"
    );

    unreachable;
}

pub inline fn startFn(self: *const Self) noreturn {
    asm volatile (
        \\push %%rbp
        \\mov %%rsp, %%rbp
        \\sub $8, %%rsp
        \\push %%rax
        \\jmp *%[addr]
        :
        : [addr] "r" (self.rip),
        : "rax", "memory", "rsp"
    );

    unreachable;
}
