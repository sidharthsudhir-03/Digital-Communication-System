// -------------------------------------------------------------
// QPSK Modulation Block
// Takes in 2 encoded bits at a time to output the real and imaginary parts of the outputted symbol
// Inputs  (2): odd-positioned bit from encoder (1-bit)
//              even-positioned bit from encoder (1-bit)
// Outputs (2): real part of symbol (16-bit signed fixed point integer)
//              imaginary part of symbol (16-bit signed fixed point integer)
// Written based on logic from HDL Coder
// -------------------------------------------------------------

module qpsk_modulator (input logic in_odd, // boolean. Input of odd-positioned encoded bits (to become real part of symbol)
                       input logic in_even, // boolean. Input of even-positioned encoded bits (to become imaginary part of symbol)
                       output signed [15:0] out_re, // signed fixed point value, [15] is signed bit, [14:0] is fractional part (decimal between bit [15] and [14])
                       output signed [15:0] out_im // signed fixed point value, [15] is signed bit, [14:0] is fractional part 
                       ); 

  /* LUT Logic Setup */
  logic [1:0] addressBit;  // boolean [2]
  wire [1:0] constellationLUTaddress;  // unsigned integer, takes 2-bit binary and converts to 0, 1, 2, or 3 (2-bits to represent integer)
  wire signed [15:0] constellationLUT_re [0:3];  // signed fixed point value, [15] is signed bit, [14:0] is fractional part. Array of [4] columns
  wire signed [15:0] constellationLUT_im [0:3];  // signed fixed point value, [15] is signed bit, [14:0] is fractional part. Array of [4] columns

  /* Assign odd and even bits to address bits, and combine for LUT address */
  assign addressBit[0] = in_odd;
  assign addressBit[1] = in_even;
  assign constellationLUTaddress = {addressBit[0], addressBit[1]};

  /* LUT Values */
  /* Values are signed fixed point values. Bit [15] is the signed bit, bits [14:0] are the fractional part after the decimal. */
  assign constellationLUT_re[0] = 16'sb1000100101011111; // -0.707092285156 (decimal representation of -sqrt(2)/2)
  assign constellationLUT_re[1] = 16'sb1000100101011111; // -0.707092285156 (decimal representation of -sqrt(2)/2)
  assign constellationLUT_re[2] = 16'sb0001011010100000; // 0.707092285156 (decimal representation of sqrt(2)/2)
  assign constellationLUT_re[3] = 16'sb0001011010100000; // 0.707092285156 (decimal representation of sqrt(2)/2)
  assign constellationLUT_im[0] = 16'sb1000100101011111; // -0.707092285156 (decimal representation of -sqrt(2)/2)
  assign constellationLUT_im[1] = 16'sb0001011010100000; // 0.707092285156 (decimal representation of sqrt(2)/2)
  assign constellationLUT_im[2] = 16'sb1000100101011111; // -0.707092285156 (decimal representation of -sqrt(2)/2)
  assign constellationLUT_im[3] = 16'sb0001011010100000; // 0.707092285156 (decimal representation of sqrt(2)/2)

  /* Assign the LUT value to the real and imaginary parts of the output symbol */
  assign out_re = constellationLUT_re[constellationLUTaddress];
  assign out_im = constellationLUT_im[constellationLUTaddress];

endmodule