// -------------------------------------------------------------
// Module: Delay Block
// Models the processing delay so that the deserializer is enabled
// at the appropriate time.
//
// Input  (1):  enable signal to start counting
// Output (2):  output signal to indicate to deserializer to start deserializing
//
// Module written based on logic from HDL Coder
// -------------------------------------------------------------

module delay (
    input logic clk, // to get 160kHz clock frequency
    input logic reset,
    input logic serializer_start, // enable signal from serializer
    output logic deserializer_start // signal for deserializer enable
);
    parameter DELAY = 47;
    reg [(DELAY-1):0] count_reg;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count_reg <= 0;
        end else if (serializer_start == 1'b1) begin
            count_reg <= {count_reg[(DELAY-2):0], 1'b1};
        end
        else begin
            count_reg <= 0;
        end
    end

    assign deserializer_start = count_reg[DELAY-1]; // once it reaches delay, it is always on

endmodule