//! x86-64 Context Tracking and Switching
//! TODO

stack_top: u64,
entry: u64,

const Self = @This();

pub fn init(top: u64, entry: u64) Self {
    return Self{
        .stack_top = top,
        .entry = entry,
    };
}
