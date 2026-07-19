module baud_generator (
    input clk,
    input reset,
    input busy,
    output reg baud_tick
);

// System clock frequency (Hz)
parameter CLK_FREQ = 100000000;

// Desired UART baud rate (bits per second)
parameter BAUD_RATE = 9600;

// Number of clock cycles required for one baud period
localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

// Counter used to divide the system clock
reg [13:0] baud_counter;

always @ (posedge clk or posedge reset)
begin
    // Asynchronous reset
    if (reset)
    begin
        baud_tick <= 1'b0;
        baud_counter <= 13'd0;
    end

    // Baud generator runs only while UART is busy
    else if (busy)
    begin
        // Generate a one-clock-cycle baud tick after BAUD_COUNT cycles
        if (baud_counter == BAUD_COUNT-1)
        begin
            baud_tick <= 1'b1;
            baud_counter <= 13'd0;
        end
        else
        begin
            baud_counter <= baud_counter + 1;
            baud_tick <= 1'b0;
        end
    end

    // When UART is idle, stop counting and keep outputs cleared
    else
    begin
        baud_tick <= 1'b0;
        baud_counter <= 13'd0;
    end
end

endmodule