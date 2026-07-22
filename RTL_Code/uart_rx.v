module uart_rx (
    input rx,
    input clk,
    input reset,
    output reg [7:0] data_out,
    output reg data_valid
);

// System clock frequency (Hz)
parameter CLK_FREQ = 100000000;

// Desired UART baud rate (bits per second)
parameter BAUD_RATE = 9600;

// Number of clock cycles per UART bit
localparam BAUD_COUNT = CLK_FREQ / BAUD_RATE;

// Half-bit delay used to sample the start bit at its center
localparam N_BAUD_COUNT = BAUD_COUNT / 2;

// Counter width automatically calculated from BAUD_COUNT
localparam CNT_W = $clog2(BAUD_COUNT);

// Current FSM state
reg [1:0] state;

// Register used to store the received byte
reg [7:0] received_data;

// FSM state encoding
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

// Tracks which data bit is currently being received
reg [2:0] bit_index;

// Baud timing counter
reg [CNT_W-1:0] cnt;

always @ (posedge clk or posedge reset)
begin
    // Asynchronous reset
    if (reset)
    begin
        state <= IDLE;
        bit_index <= 0;
        received_data <= 8'b0;
        data_valid <= 0;
        cnt <= 0;
        data_out <= 0;
    end
    else
    begin
        case (state)

        // Wait for the start bit
        IDLE:
        begin
            bit_index <= 0;
            data_valid <= 0;
            cnt <= 0;

            // Detect falling edge of start bit
            if (!rx)
                state <= START;
        end

        // Verify the start bit by sampling at its center
        START:
        begin
            if (cnt == N_BAUD_COUNT-1)
            begin
                cnt <= 0;

                // Valid start bit detected
                if (!rx)
                    state <= DATA;
                else
                    state <= IDLE;
            end
            else
                cnt <= cnt + 1;
        end

        // Receive 8 data bits (LSB first)
        DATA:
        begin
            if (cnt == BAUD_COUNT-1)
            begin
                cnt <= 0;

                if (bit_index == 7)
                begin
                    received_data[7] <= rx;
                    state <= STOP;
                end
                else
                begin
                    received_data[bit_index] <= rx;
                    bit_index <= bit_index + 1;
                end
            end
            else
                cnt <= cnt + 1;
        end

        // Verify the stop bit and output received byte
        STOP:
        begin
            if (cnt == BAUD_COUNT-1)
            begin
                cnt <= 0;

                // Valid stop bit received
                if (rx)
                begin
                    data_valid <= 1;
                    data_out <= received_data;
                end
                else
                    data_valid <= 0;

                state <= IDLE;
            end
            else
                cnt <= cnt + 1;
        end

        // Recover safely from an invalid state
        default:
            state <= IDLE;

        endcase
    end
end

endmodule