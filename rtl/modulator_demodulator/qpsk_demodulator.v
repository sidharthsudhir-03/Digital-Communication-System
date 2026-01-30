// -------------------------------------------------------------
// Module: QPSK Demodulator
// Takes in one im and re part of symbol. Output is symbol mapped to 2 bits
// Input  (2): real part of symbol (16-bit signed fixed point integer)
//             imaginary part of symbol (16-bit signed fixed point integer)
// Output (2): odd-positioned bit from encoder (1-bit)
//             even-positioned bit from encoder (1-bit)
// Written based on logic from HDL Coder
// -------------------------------------------------------------

module qpsk_demodulator (input signed [15:0] in_re, // signed 16-bit fixed En13
                         input signed [15:0] in_im, // signed 16-bit fixed En13
                         output out_odd, // odd-positioned bits
                         output out_even); // even-positioned bits

  wire real_lt_zero; // less than zero for real
  wire real_eq_zero; // equals zero for real
  wire im_lt_zero; // less than zero for imaginary
  wire im_eq_zero; // equals zero for imaginary

  wire [3:0] decisionLUTaddr;  // 4 address options
  wire [1:0] DirectLUT [0:15];  // 2 columns of signed 16-bit fixed En13
  wire [1:0] hardDecision;  // stores mapped LUT values

  wire swap_bit0;
  wire swap_bit1;

  wire [1:0] output_vector;  // boolean [2]
  reg  [1:0] out;  // boolean [2]

  reg signed [31:0] i;  // int32
  reg  intermediate;  // ufix1

  // Check if input is equal to or less than zero
  assign real_lt_zero = in_re < 16'sb0000000000000000;
  assign real_eq_zero = in_re == 16'sb0000000000000000;

  assign im_lt_zero = in_im < 16'sb0000000000000000;
  assign im_eq_zero = in_im == 16'sb0000000000000000;

  // concatenate above comparators to make LUT address
  assign decisionLUTaddr = {real_lt_zero, real_eq_zero, im_lt_zero, im_eq_zero};

  /* LUT Values */
  assign DirectLUT[0] = 2'b11; // 0000 = re: pos, im: pos
  assign DirectLUT[1] = 2'b11; // 0001 = re: pos, im: 0
  assign DirectLUT[2] = 2'b10; // 0010 = re: pos, im: neg
  assign DirectLUT[3] = 2'b00; // 0011 = re: pos, im: neg and 0 (invalid)
  assign DirectLUT[4] = 2'b01; // 0100 = re: 0, im: pos 
  assign DirectLUT[5] = 2'b00; // 0101 = re: 0, im: 0 (invalid or signal lost)
  assign DirectLUT[6] = 2'b10; // 0110 = re: 0, im: neg
  assign DirectLUT[7] = 2'b00; // 0111 = re: 0, im: neg and 0 (invalid)
  assign DirectLUT[8] = 2'b01; // 1000 = re: neg, im: pos
  assign DirectLUT[9] = 2'b00; // 1001 = re: neg, im: 0
  assign DirectLUT[10] = 2'b00; // 1010 = re: neg, im: neg
  assign DirectLUT[11] = 2'b00; // 1011 = re: neg, im: neg and 0 (invalid)
  assign DirectLUT[12] = 2'b00; // 1100 = re: neg and 0, im: pos (invalid)
  assign DirectLUT[13] = 2'b00; // 1101 = re: neg and 0, im: 0 (invalid)
  assign DirectLUT[14] = 2'b00; // 1110 = re: neg and 0, im: neg (invalid)
  assign DirectLUT[15] = 2'b00; // 1111 = re: neg and 0, im: neg and 0 (invalid)
  
  /* Map symbol approximation back to 2-bit binary representation */
  assign hardDecision = DirectLUT[decisionLUTaddr];

  /* separate mapped 2-bit binary to odd and even bits */
  assign swap_bit0 = hardDecision[1]; // re --> odd bit
  assign swap_bit1 = hardDecision[0]; // im --> even bit

  /* bit positions swapped to match modulator input order */
  assign output_vector[0] = swap_bit0; // contains odd bit
  assign output_vector[1] = swap_bit1; // contains even bit

  // Always block buffers output so that bits are sent sequentially rather than together
  // This cycles through all 16 symbol representations to extract the bits
  always @* begin // this should be clocked at 160kHz
    intermediate = 1'b0;

    for(i = 32'sd0; i <= 32'sd1; i = i + 32'sd1) begin
      if (output_vector[i] != 1'b0) begin
        intermediate = 1'b1;
      end
      else begin
        intermediate = 1'b0;
      end
      out[i] = intermediate; // bit values obtained in each round added to out
    end
  end

  assign out_odd = out[0]; // odd-position bits outputted sequentially (goes first)
  assign out_even = out[1]; // even-position bits outputted sequentially (goes second)

endmodule

