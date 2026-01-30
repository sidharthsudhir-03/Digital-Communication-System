`timescale 1ps / 1ps

module tb_data_shifter_sampling;

    // Inputs
    reg clk, enn;
    reg signed [23:0] data_in;

    // Outputs
    wire [7:0] data_out;

    // Instantiate the Unit Under Test (UUT)
    data_shifter_sampling uut (
        .clk(clk),
        .enn(enn),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // Generates a 20kHz clock (50us period, 25us high, 25us low)
    end

    // Stimulus
    initial begin
        // Initialize Inputs
        enn =1;
        data_in = 0;

        // Wait for the global reset
        #10;

        // Apply input vectors
        data_in = 65536;  // Boundary condition near the top of the signed range
        #10;                     // Wait half a clock cycle

        data_in = 65536*2;  // Largest positive value
        #10;                     // Wait half a clock cycle

        data_in = 65536*4;  // Largest positive value
        #10;                     // Wait half a clock cycle

        data_in = -65536*3;  // A negative number
        #10;                     // Wait half a clock cycle

        // Additional test cases can be added here

        // Finish simulation
        #100;
  
    end

    // Optional: Monitor changes
    initial begin
        $monitor("At time %t, data_in = %h -> data_out = %h", $time, data_in, data_out);
    end

endmodule
