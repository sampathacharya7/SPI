module SPI_tb;
    reg clk = 0, rst = 0, start = 0, miso = 0;
    reg [7:0] data_in = 8'hA5;
    wire [7:0] data_out;
    wire busy, sclk, mosi, ss;

    spi_master uut (
        .clk(clk),
        .rst(rst),
        .start(start),
        .data_in(data_in),
        .data_out(data_out),
        .busy(busy),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .ss(ss)
    );

    always #5 clk = ~clk; // 100MHz clock

    initial begin
        rst = 1; #10; rst = 0;
        start = 1; #10; start = 0;

        wait (!busy);
        $display("Received: %h", data_out);
        $finish;
    end
endmodule
