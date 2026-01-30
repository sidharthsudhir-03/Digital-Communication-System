module awgn_channel (
    input wire clk,
    input wire reset,
    input wire state,
    output reg [15:0] signal_out
);


logic [7:0] address;
logic [15:0] good_noise, bad_noise;

always_comb begin 
    if(state) begin
        signal_out = good_noise;
    end
    else begin
        signal_out = bad_noise;
    end
end

random_number_generator_8 address_GEN ( 
    .clk(clk), 
    .rst_n(reset), 
    .random_number(address));

good_channel noise_good(
	.address(address),
	.clock(clk),
	.data(),
	.wren(),
	.q(good_noise));

bad_channel noise_bad(
	.address(address),
	.clock(clk),
	.data(),
	.wren(),
	.q(bad_noise));
    
endmodule




module random_number_generator_8 (
    input logic clk,        // Clock input
    input logic reset,      // Asynchronous reset
    output reg [7:0] rnd_number // Output random number, 10 bits to cover up to 1023
);

    reg [9:0] lfsr;         // 10-bit Linear Feedback Shift Register
    wire feedback;          // Feedback tap for LFSR

    // Polynomial: x^10 + x^3 + 1, chosen for maximal LFSR length
    assign feedback = lfsr[9] ^ lfsr[2];

    // LFSR update logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 10'b1; // Initialize with a non-zero value to avoid getting stuck at 0
        end else begin
            lfsr <= {lfsr[8:0], feedback}; // Shift left and insert feedback
        end
    end

    // Assign the output, limiting the range to 0-999
    always_ff @(posedge clk) begin
        if (lfsr <= 999) begin
            rnd_number <= lfsr[7:0]; // Use the LFSR value if within range
        end else begin
            rnd_number <= (lfsr % 1000)>>2; // Wrap around if above 999
        end
    end

endmodule


