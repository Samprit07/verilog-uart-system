module uart_rx_top #(
    // System clock frequency (Hz)
    parameter CLK_FREQ = 100000000,

    // Desired UART baud rate (bits per second)
    parameter BAUD_RATE = 9600
)(
    input clk,
    input reset,
    input rx,
    output [7:0] data_out,
    output data_valid
);

    // Baud count derived from clock frequency and baud rate
    localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

    // UART Receiver instance
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) URX (
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .data_valid(data_valid)
    );

endmodule