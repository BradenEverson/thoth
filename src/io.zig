//! IO Bound 'Syscall' enums. This is for simulation use currently but
//! will be fully implemented for baremetal runtimes

pub const IoCall = enum(u8) {
    uart_transmit = 0,
    uart_receive = 1,
    i2c_read = 2,
    i2c_write = 3,
    spi_transfer = 4,

    gpio_interrupt = 5,

    adc_read = 6,

    sleep = 7,
};

pub const IoSimCall = struct {
    call_type: IoCall,
    time_out: u32,
};
