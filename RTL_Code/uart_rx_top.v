module uart_rx_top #(parameter CLK_FREQ = 100000000, parameter BAUD_RATE = 9600)(input clk, input reset, input rx, output [7:0] data_out, output data_valid);
    localparam BAUD_COUNT = CLK_FREQ/BAUD_RATE;
    uart_rx #(.CLK_FREQ(CLK_FREQ), .BAUD_RATE(BAUD_RATE)) URX(.clk(clk), .reset(reset), .rx(rx), .data_out(data_out), .data_valid(data_valid));
endmodule