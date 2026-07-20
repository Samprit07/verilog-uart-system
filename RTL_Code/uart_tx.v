module uart_tx (
    input clk,
    input reset,
    input [7:0] data_in,
    input send,
    input baud_tick,
    output reg busy,
    output reg tx
);

// Register to store the byte being transmitted
reg [7:0] data_stored;

// Tracks which data bit is currently being transmitted
reg [2:0] bit_index;

// FSM state encoding
parameter IDLE  = 2'b00;
parameter START = 2'b01;
parameter DATA  = 2'b10;
parameter STOP  = 2'b11;

// Current FSM state
reg [1:0] state;

always @ (posedge clk or posedge reset)
begin
    // Asynchronous reset
    if (reset)
    begin
        state <= IDLE;
        bit_index <= 0;
        tx <= 1;               // UART line remains idle high
        busy <= 0;
        data_stored <= 8'b00;
    end

    else
    begin
        case (state)

        // Wait for transmission request
        IDLE:
        begin
            tx <= 1;           // Keep TX line high during idle
            bit_index <= 0;
            busy <= 0;

            if (send)
            begin
                state <= START;
            end
        end

        // Transmit start bit
        START:
        begin
            tx <= 0;           // Start bit is logic 0
            busy <= 1;
            data_stored <= data_in; // Latch input data
            state <= DATA;
        end

        // Transmit 8 data bits (LSB first)
        DATA:
        begin
            if (baud_tick)
            begin
                tx <= data_stored[bit_index];

                if (bit_index < 7)
                    bit_index <= bit_index + 1;
                else
                    state <= STOP;
            end
        end

        // Transmit stop bit
        STOP:
        begin
            tx <= 1;           // Stop bit is logic 1

            if (baud_tick)
                state <= IDLE;
        end

        endcase
    end
end

endmodule