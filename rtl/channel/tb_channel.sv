`timescale 1ns / 1ps  // Define the time scale for simulation

module tb_channel();

    // Testbench signals
    reg [15:0] channel_input;
    reg CLOCK_50, CLOCK_10, reset;
    wire [15:0] channel_output;

    // Instantiate the channel module
    channel uut (
        .channel_input(channel_input),
        .CLOCK_50(CLOCK_50),
        .CLOCK_10(CLOCK_10),
        .reset(reset),
        .channel_output(channel_output)
    );

    // Clock generation for CLOCK_50 (20ns period -> 50 MHz)
    always #10 CLOCK_50 = ~CLOCK_50;

    // Clock generation for CLOCK_10 (100000ns period -> 10 kHz)
    always #50000 CLOCK_10 = ~CLOCK_10;

    // Initial block to run the test
    initial begin
        // Initialize signals
        CLOCK_50 = 0;
        CLOCK_10 = 0;
        reset = 1;
        channel_input = 16'h0000;

        // Apply reset
        #100;
        reset = 0;

        // Test scenario 1: Low input signal
        channel_input = 16'h0001;
        #100000;  // Wait for some operations, longer due to slower clock_10

        // Test scenario 2: Medium input signal
        channel_input = 16'h7FFF;
        #100000;  // Wait for some operations

        // Test scenario 3: High input signal
        channel_input = 16'hFFFF;
        #100000;  // Wait for some operations
    //check for the data changing for the output 

        // End simulation
        $finish;
    end

    // Monitor output of the channel
    initial begin
        $monitor("At time %t, Output = %h", $time, channel_output);
    end

endmodule
