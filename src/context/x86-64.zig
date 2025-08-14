//! x86-64 Context Tracking and Switching

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
