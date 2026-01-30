module data_shifter_sampling (
    input wire clk,              // Clock signal with frequency 20KHz
    input wire signed [23:0] data_in,   // 24-bit signed input data
    input enn,
    output reg [7:0] data_out,    // 8-bit output data
    output reg ser_en
);

// On every positive edge of the clock, perform an arithmetic right shift by 16 bits
always @(posedge clk) begin
    if(enn) begin
        data_out <= data_in >> 16; // Arithmetic right shift by 16 bits
        ser_en <= 1'b1;
    end
    else begin data_out <= 0;
    ser_en <= 1'b0;
    end
   
end

endmodule

module data_resampling (
    input wire clk,              // Clock signal with frequency 20KHz
    input wire signed  [7:0] data_in,   // 8-bit signed input data
    input enn,
    output reg [23:0] data_out    // 24-bit output data
);

// On every positive edge of the clock, perform an arithmetic right shift by 16 bits
always @(posedge clk) begin
    if(enn) begin
        data_out <= data_in << 16; // Arithmetic right shift by 16 bits
    end
    else data_out <= 0;
end

endmodule



module data_shifter_sampling_wav (
    input wire clk,              // Clock signal with frequency 20KHz
    input wire signed [15:0] data_in,   // 16-bit signed input data
    input enn,
    output reg [7:0] data_out,    // 8-bit output data
    output reg ser_en
);

// On every positive edge of the clock, perform an arithmetic right shift by 16 bits
always @(posedge clk) begin
    if(enn) begin
        data_out <= data_in >> 8; // Arithmetic right shift by 16 bits
        ser_en <= 1'b1;
    end
    else begin data_out <= 0;
    ser_en <= 1'b0;
    end
end

endmodule


module data_resampling_wav (
    input wire clk,              // Clock signal with frequency 20KHz
    input wire signed  [7:0] data_in,   // 8-bit signed input data
    input enn,
    output reg [15:0] data_out    // 16-bit output data
);

// On every positive edge of the clock, perform an arithmetic right shift by 16 bits
always @(posedge clk) begin
    if(enn) begin
        data_out <= data_in << 8; // Arithmetic right shift by 16 bits
    end
    else data_out <= 0;
end

endmodule