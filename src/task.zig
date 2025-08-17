//! Task definition

const std = @import("std");

pub fn Task(comptime stack_size: u32) type {
    return struct {
        stack: [stack_size]u8 align(16),
        sp: u64,
        ip: u64,
    };
}
