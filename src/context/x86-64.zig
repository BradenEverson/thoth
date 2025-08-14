//! x86-64 Context Tracking and Switching

const std = @import("std");

stack_top: u64,
pc: u64,
sp: u64,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    return Self{
        .stack_top = top,
        .pc = entry,
        .sp = top,
    };
}

pub inline fn saveCtx(self: *Self, pc: u64, sp: u64) void {
    self.pc = pc;
    self.sp = sp;
}

pub inline fn restoreCtx(self: *const Self) noreturn {
    std.debug.print("Pc: 0x{X}\nSp: 0x{X}\n", .{ self.pc, self.sp });
    asm volatile (
        \\ mov %[sp], %%rsp
        \\ jmp *%[pc]
        :
        : [sp] "m" (self.sp),
          [pc] "r" (self.pc),
        : "memory", "rsp"
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
        : [addr] "r" (self.pc),
        : "rax", "memory", "rsp"
    );

    unreachable;
}
