module decimation #(
    parameter DECIMATION_FACTOR = 6 // also the downsampling factor
)(
    input wire [15:0] in,
    input wire clk,
    input wire reset,
    output reg [15:0] out
);

    reg [2:0] counter;

    // Sequential logic that uses a counter to take a sample after 6 clock cycles 
	 always @(posedge clk) begin
        if (reset) begin
            counter <= 3'd0;
            out <= 0;
        end else if (counter == 3'd0) begin
            out <= in;
            counter <= 3'd5;
        end else begin
            out <= out;
            counter <= counter - 1;
        end
    end

endmodule
