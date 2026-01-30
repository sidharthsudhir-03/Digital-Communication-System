`timescale 1 ns / 1 ns
module tb_encode_decode;
// testbench to test the encoder and decoder
// ************************* VARIABLE DECLARATIONS ***********************//
  // General Inputs
  reg clk;
  reg clk_enable;
  reg reset;
  integer num_passes = 0;
  integer num_fails = 0;

  parameter trials = 200;
  parameter delay = 29;
  parameter ber_calc = trials - delay - 2;
  
  reg [trials:0] delay_check;

  // convolutional_encoder inputs
  reg audio_in;

  // convolutional_encoder outputs / viterbi_decoder inputs
  reg encoded_odd;
  reg encoded_even;
  reg encode_valid;

  // viterbi_decoder outputs
  wire decoded_out;
  reg decode_valid;

  // ***************** INSTANTIATE DEVICES UNDER TEST ******************//
  
  convolutional_encoder dut1 (
    .clk(clk),
    .reset(reset),
    .encode_en(clk_enable),
    .audio_in(audio_in),
    .encoded_out_odd(encoded_odd),
    .encoded_out_even(encoded_even),
    .encode_valid(encode_valid)
  );

  Viterbi_Decoder1 dut2 (
    .clk(clk),
    .reset(reset),
    .enb(clk_enable),
    .Viterbi_Decoder1_in_0(encoded_odd),  // boolean
    .Viterbi_Decoder1_in_1(encoded_even),  // boolean
    .decoded(decoded_out),
    .decode_valid(decode_valid)
  );
  
  // ******************************** TASKS ******************************//
      task check_encoded_odd;
        $display("odd-bit encoded value is %-d\n", encoded_odd);
    endtask

    task check_encoded_even;
        $display("even-bit encoded value is %-d\n", encoded_even);
    endtask

    task check_decoded_output(input exp_decode);
        assert (decoded_out === exp_decode) begin
            $display("[PASS]: decoded value is %-d (expected %-d)\n", decoded_out, exp_decode);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: decoded value is %-d (expected %-d)\n", decoded_out, exp_decode);
            num_fails = num_fails + 1;
        end
    endtask

  // ****************************** START TEST ******************************//
  // Clock generation
  initial begin
    clk = 1'b0;
    forever #10 clk = ~clk; 
  end

  // Test stimulus
  initial begin
    // Initialize inputs
    reset = 1'b1;
    clk_enable = 1'b0;
    audio_in = 1'b0;
    delay_check = 0;

    // Apply reset
    #20;
    reset = 1'b0; // Deassert reset

    #3;
    clk_enable = 1'b1;

    // Provide stimulus to the inputs
    for (int i = 0; i < delay; i = i + 1) begin
      #10;
      audio_in = {$random} % 2;
      delay_check[i] = audio_in;
      
      #10;
      check_encoded_odd;
      check_encoded_even;
    end

    for (int j = 0; j < ber_calc; j = j + 1) begin
      #10;
      audio_in = {$random} % 2;
      delay_check[(j + delay)] = audio_in;
      
      #10;
      check_encoded_odd;
      check_encoded_even;
      check_decoded_output(delay_check[j]);
    end

    for (int k = 0; k < delay; k = k + 1) begin
      #20;
      check_encoded_odd;
      check_encoded_even;
      check_decoded_output(delay_check[k + ber_calc]);
    end

    #10;
    //Test results, used same syntax as vending machine testbench from class
    $display("\n\n==== TEST SUMMARY ====");
    $display("  TEST COUNT: %-5d", num_passes + num_fails);
    $display("    - PASSED: %-5d", num_passes);
    $display("    - FAILED: %-5d", num_fails);
    $display("    -    BER: %-5d", num_fails/(num_passes + num_fails));
    $display("======================\n\n");
    $stop;
  end
endmodule
