//! IO Bound 'Syscall' enums. This is for simulation use currently but
//! will be fully implemented for baremetal runtimes

pub const IoCall = enum(u8) {
    uart_transmit,
    uart_receive,
    i2c_read,
    i2c_write,
    spi_transfer,

    gpio_interrupt,

    adc_read,

    sleep,
};

pub const IoSimCall = struct {
    call_type: IoCall,
    time_out: u32,
};
