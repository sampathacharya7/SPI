module spi_master (
    input wire clk,           // System Clock
    input wire rst,           // Reset
    input wire start,         // Start transmission
    input wire [7:0] data_in, // Data to send
    output reg [7:0] data_out,// Data received
    output reg busy,          // Busy flag
    output reg sclk,          // SPI Clock
    output reg mosi,          // Master Out
    input wire miso,          // Master In
    output reg ss             // Slave Select
);
    reg [2:0] bit_cnt;
    reg [7:0] shift_reg;
    reg [2:0] state;
    parameter IDLE = 3'd0, LOAD = 3'd1, TRANSFER = 3'd2, DONE = 3'd3;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            sclk <= 1;
            mosi <= 0;
            busy <= 0;
            ss <= 1;
        end else begin
            case (state)
                IDLE: begin
                    busy <= 0;
                    ss <= 1;
                    sclk <= 1;
                    if (start) begin
                        shift_reg <= data_in;
                        bit_cnt <= 3'd7;
                        ss <= 0;
                        busy <= 1;
                        state <= LOAD;
                    end
                end
                LOAD: begin
                    mosi <= shift_reg[7];
                    sclk <= 0; // Falling edge for data capture
                    state <= TRANSFER;
                end

                TRANSFER: begin
                    sclk <= 1; // Rising edge
                    shift_reg <= {shift_reg[6:0], miso};
                    if (bit_cnt == 0) begin
                        state <= DONE;
                    end else begin
                        bit_cnt <= bit_cnt - 1;
                        state <= LOAD;
                    end
                end
                DONE: begin
                    sclk <= 1;
                    mosi <= 0;
                    data_out <= shift_reg;
                    ss <= 1;
                    busy <= 0;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

