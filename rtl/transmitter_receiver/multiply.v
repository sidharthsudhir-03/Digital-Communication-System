module multiply(in1,in2, out);

    input signed [15:0] in1;
    input signed [15:0] in2;

    reg signed [31:0] temp;// temp reg to hold the output of the 16 bit multiplication
    output reg signed [15:0] out; 

    always @(*) begin
        temp = in1*in2 >>> 13; // multiply the inputs and right shift by 13 bits, to meet channel quantization requirements of 2**(-13)

        out = temp[15:0]; //take the lower 16 bits of temp and put them into out
    end

endmodule 