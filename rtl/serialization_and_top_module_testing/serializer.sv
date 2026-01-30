module serializer (
    input  logic clk, // clock frequency is 160kHz for bitstream
    input  logic reset,
    input  logic enable, // get signal from ADC output
    input  logic signed [7:0] parallel_data,
    output logic serial_out,
    output logic serializer_start
    );

    logic [7:0] shift_reg;
    logic [2:0] bit_index;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_index <= 3'd0;
            serial_out <= 1'b0;
            serializer_start <= 1'b0;
        end else if (enable == 1'b1) begin
            if (bit_index == 3'd0) begin
                shift_reg <= parallel_data;
                bit_index <= 3'd7;
                serializer_start <= 1'b1;
            end else begin
                bit_index <= bit_index - 1;
            end
            serial_out <= shift_reg[bit_index];
        end
        else begin
            shift_reg <= 8'b0;
            bit_index <= 3'd0;
            serial_out <= 1'b0;
            serializer_start <= 1'b0;
        end
    end
endmodule