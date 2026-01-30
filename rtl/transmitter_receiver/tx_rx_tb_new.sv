//`timescale 1ps/1ps

module tx_rx_lite_tb;

	 reg clk;
    reg reset;
    reg signed [15:0] tx_data_in;
    reg read_ready;
    wire signed [15:0] rx_data_out;
    wire signed [15:0] tx_data_out;
    integer i;


    // Parameters for clock periods
    parameter CLK_PERIOD_960KHZ = 1042; // in ns
    parameter CLK_PERIOD_160KHZ = 6250; // in ns

    // Instantiate the tx_lite module
    tx_lite tx (
        .clk(clk),
        .reset(reset),
        .read_ready(read_ready),
        .data_in(tx_data_in),
        .data_out(tx_data_out)
    );

    // Instantiate the rx_lite module
    rx_lite rx (
        .clk(clk),
        .reset(reset),
        .data_in(tx_data_out),
        .data_out(rx_data_out)
    );

    // Clock generation for 960kHz
    always begin
        #(CLK_PERIOD_960KHZ/2) clk = ~clk;
    end

    // Random QPSK value generation
    task random_qpsk_value(output reg [15:0] qpsk_val);
        begin
            if ($random % 2 == 0) begin
                qpsk_val = 16'sb1000100101011111;
            end else begin
                qpsk_val = 16'sb0001011010100000;
            end
        end
    endtask

    // Test sequence generation
    initial begin
        
		  clk = 1'b0;
        tx_data_in = 16'b0;
        read_ready = 1'b0;
		  reset = 1; #(2*CLK_PERIOD_960KHZ);
		  
        reset = 0;

        // Generating input at 160kHz mimicing qpsk modulator symbol rate
        for (i = 0; i < 100; i = i + 1) begin
            random_qpsk_value(tx_data_in);
            read_ready = 1; #(6*CLK_PERIOD_960KHZ);// Total 6 clock cycles per input
        end
        $stop;
    end

    // Display input and output values
    always @(posedge clk) begin
        if (reset) begin
            $display("Time: %0t, TX Input: %h, TX Output: %h, RX Output: %h", $time, tx_data_in, tx_data_out, rx_data_out);
        end
    end

endmodule
