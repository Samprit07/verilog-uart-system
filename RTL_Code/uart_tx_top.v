module uart_tx_top #(
    // System clock frequency (Hz)
    parameter CLK_FREQ = 100000000,
    // Desired UART baud rate (bits per second)
     parameter BAUD_RATE = 9600) 
     (input clk,
    input reset, 
    input send, 
    input [7:0] data_in, 
    output tx, 
    output busy);
// Internal wire to carry the pulse signal from the baud generator
wire baud_tick;
// Baud Generator instantiation
baud_generator #(.CLK_FREQ(CLK_FREQ),
                 .BAUD_RATE(BAUD_RATE))
                  BG (.clk(clk),
                  .reset(reset),
                  .busy(busy),
                  .baud_tick(baud_tick));
// UART Transmitter Logic Instantiation
uart_tx UTX (.clk(clk),
            .reset(reset),
            .send(send),
            .busy(busy),
            .data_in(data_in),
            .tx(tx),
            .baud_tick(baud_tick));
endmodule
