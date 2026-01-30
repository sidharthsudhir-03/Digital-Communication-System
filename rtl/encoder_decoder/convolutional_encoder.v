// -------------------------------------------------------------
// Module: Convolutional Encoder Block
// Rate: 1/2 
// Constraint Length: 4
// Gen0 polynomial: 12_o
// Gen1 polynomial: 15_o
//
// Inputs (4):  - clock (160kHz frequency)
//              - reset
//              - enable signal
//              - single bit audio input
// Output (2):  output split into 2 bit streams:
//              - odd-position output bit
//              - even-position output bit
//
// Module written based on logic from HDL Coder
// -------------------------------------------------------------

module convolutional_encoder
          (input clk,
           input reset,
           input encode_en,
           input audio_in, // single bit input
           output encoded_out_odd, // single bit odd-position output
           output encoded_out_even,
           output reg encode_valid); // single bit even-position output

  reg  [2:0] shift_reg_in;  
  wire [3:0] shift_reg_out; 
  wire wire_out_0;
  wire wire_out_1;
  wire wire_out_2;
  wire wire_out_3;
  wire encoded_entry1;
  wire encoded_entry2;

  // Shift Register for Constraint Length 4 //
  always @(posedge clk or posedge reset)
    begin : shift1_process
      if (reset == 1'b1) begin
        shift_reg_in <= {3{1'b0}};
        encode_valid <= 1'b0;
      end
      else begin
        if (encode_en) begin
          shift_reg_in[0] <= audio_in; // new input bit sent to LSB (index 0) of shift_reg_in
          shift_reg_in[2:1] <= shift_reg_in[1:0]; // moves the 2 LSBs currently in the register up one index. The MSB is discarded
          encode_valid <= 1'b1;
        end
      end
    end

  // Update the 4 output registers to get ready for convolution //
  assign shift_reg_out[0] = audio_in; // update index 0 of the output register with newest incoming bit
  assign shift_reg_out[3:1] = shift_reg_in[2:0]; // update the remaining indices of the output register with the newly shifted bits 

  // Load up the output wires out of the output register's indices with the values stored in the register's indices //
  assign wire_out_0 = shift_reg_out[0];
  assign wire_out_1 = shift_reg_out[1];
  assign wire_out_2 = shift_reg_out[2];
  assign wire_out_3 = shift_reg_out[3];

  // Generator Polynomial: [12_o] = 1010 //
  assign encoded_entry1 = wire_out_0 ^ wire_out_2; // calculate odd bit output
  assign encoded_out_odd = encoded_entry1;

  // Generator Polynomial: [15_o] = 1101 //
  assign encoded_entry2 = wire_out_3 ^ (wire_out_0 ^ wire_out_1); // calculate even bit output
  assign encoded_out_even = encoded_entry2;

endmodule

