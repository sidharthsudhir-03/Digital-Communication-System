module deserializer (
    input logic clk,
    input logic reset,
    input logic deserializer_start,
    input logic serial_in,
    output logic signed [7:0] parallel_data,
    output logic data_valid);

    logic [7:0] shift_reg;
    logic [2:0] bit_counter;

    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            shift_reg <= 8'b0;
            bit_counter <= 3'd0;
            data_valid <= 1'b0;
        end else if (deserializer_start) begin
            shift_reg <= {shift_reg[6:0], serial_in};
            bit_counter <= bit_counter +1;
            if (bit_counter == 3'd7) begin
                parallel_data <= shift_reg;
                data_valid <= 1'b1;  // Data is valid when the entire byte has been received
                bit_counter <= 3'd0;
            end else begin
                data_valid <= 1'b0;
            end
        end
        else begin
            shift_reg <= 8'b0;
            bit_counter <= 3'd0;
            data_valid <= 1'b0;
        end
    end
endmodule