`timescale 1 ps / 1 ps
// -------------------------------------------------------------
// Module: Top module testbench
// Tests the instantiated modules in top module. Checks inputs/outputs
//
// -------------------------------------------------------------

module tb_top_module;

// ************************* VARIABLE DECLARATIONS ***********************//
  // General Inputs
  reg clk_50m;
  parameter CLK_50M = 60;
  reg clk_960;
  parameter CLK_960 = 3125;
  reg clk_160;
  parameter CLK_160 = 18750;
  reg clk_20;
  parameter CLK_20 = 150000;
  reg reset;

  integer num_passes = 0;
  integer num_fails = 0;
  
  parameter trials = 200;
  parameter delay = 7; // accounts for delay in the system using a 20kHz clock
  parameter ber_calc = trials - delay - 2;
  reg signed [23:0] delay_check [0:trials];

  // top_module inputs
  reg signed [23:0] audio_in;
  reg signed [7:0] testing;
  reg enn;

/******************************* DECLARATIONS ******************************/
    // ADC / DAC declarations //
    wire signed [7:0] mic_8_in;
	wire signed [7:0] decoded_8_out;

	// serializer / deserializer declarations
	logic serial_en; // enables serializer with first ADC output
	logic serializer_start; // initializes delay counter
    logic deserializer_start; // enables deserializer
	logic deserial_valid; // may not need to use

	// encoder declarations //
	logic audio; // inputs
	logic in_odd; // outputs
	logic in_even; // outputs

	// decoder declarations //
	logic out_odd; // inputs
	logic out_even; // inputs
	logic decoded; // outputs

	// modulator declarations //
	logic signed [15:0] re_symbol;
	logic signed [15:0] im_symbol;

    // transmitter declarations //
	logic [15:0] tx_re_out; 
	logic [15:0] tx_im_out;

	// receiver declarations //
	logic [15:0] rx_re_out;
	logic [15:0] rx_im_out;

    // top_module outputs
    wire signed [23:0] audio_out_L;
    wire signed [23:0] audio_out_R;

  // ***************** INSTANTIATE DEVICES UNDER TEST ******************//

  data_shifter_sampling dut1(
    .clk(clk_20),              // Clock signal with frequency 20KHz
    .data_in(audio_in),   // 24-bit signed input data
	.enn(enn),
    .data_out(mic_8_in),    // 8-bit output data
	.ser_en(serial_en)
);

serializer dut2(
	.clk(clk_160),
	.reset(reset),
	.enable(serial_en),
	.parallel_data(mic_8_in),
	.serial_out(audio),
	.serializer_start(serializer_start)
);

delay dut3(
    .clk(clk_160),
    .reset(reset),
    .serializer_start(serializer_start),
    .deserializer_start(deserializer_start)
);

convolutional_encoder dut4(
    .clk(clk_160),
    .reset(reset),
    .encode_en(serializer_start),
    .audio_in(audio),
    .encoded_out_odd(in_odd),
    .encoded_out_even(in_even),
    .encode_valid(encode_valid_L)
  );

qpsk_modulator dut5(
    .in_odd(in_odd),
    .in_even(in_even),
    .out_re (re_symbol),
    .out_im (im_symbol)
  );

tx_lite dut6(
    .data_in(re_symbol),
    .data_out(tx_re_out),
    .clk(clk_960),
    .reset(reset),
    .read_ready(encode_valid_L)
    );

tx_lite dut7(
    .data_in(im_symbol),
    .data_out(tx_im_out),
    .clk(clk_960),
    .reset(reset),
    .read_ready(encode_valid_L)
    );

rx_lite dut8(
    .data_in(tx_re_out),
    .data_out(rx_re_out),
    .clk(clk_960),
    .reset(reset)
    );

rx_lite dut9(
    .data_in(tx_im_out),
    .data_out(rx_im_out),
    .clk(clk_960),
    .reset(reset)
    );

qpsk_demodulator dut10(
    .in_re(rx_re_out),
    .in_im(rx_im_out),
    .out_odd(out_odd),
    .out_even(out_even)
  );

Viterbi_Decoder1 dut11(
    .clk(clk_160),
    .reset(reset),
    .enb(serializer_start),
    .Viterbi_Decoder1_in_0(out_odd), 
    .Viterbi_Decoder1_in_1(out_even), 
    .decoded(decoded),
    .decode_valid(decode_valid_L)
  );

deserializer dut12(
	.clk(clk_160),
	.reset(reset),
	.deserializer_start(deserializer_start),
	.serial_in(decoded),
	.parallel_data(decoded_8_out),
	.data_valid(deserial_valid)
);

data_resampling dut13(
    .clk(clk_50m),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_out),   // 8-bit signed input data
    .enn(enn),
    .data_out(audio_out_L)    // 24-bit output data
);

data_resampling dut14(
    .clk(clk_50m),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_out),   // 8-bit signed input data
    .enn(enn),
    .data_out(audio_out_R)    // 24-bit output data
);

  // ******************************** TASKS ******************************//
      
    task check_output(input [23:0] exp_output_L);
        assert (audio_out_L === exp_output_L) begin
            $display("[PASS]: left output value is %-b (expected %-b)\n", audio_out_L, exp_output_L);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: left output value is %-b (expected %-b)\n", audio_out_L, exp_output_L);
            num_fails = num_fails + 1;
        end
    endtask

  // ****************************** START TEST ******************************//
  // Clock generation
  initial begin
    clk_50m = 1'b0; // period of 120 ps
    forever #CLK_50M clk_50m = ~clk_50m; 
  end

  initial begin
    clk_960 = 1'b0; // period of 6,250 ps
    forever #CLK_960 clk_960 = ~clk_960;
  end

  initial begin 
    clk_160 = 1'b0; // period of 37,500 ps
    forever #CLK_160 clk_160 = ~clk_160;
  end

  initial begin
    clk_20 = 1'b0; // period of 300,000 ps
    forever #CLK_20 clk_20 = ~clk_20;
  end

  // Test stimulus
  initial begin
    // Initialize inputs
    reset = 1'b1;
    enn = 1'b0;
    audio_in = 24'd0;
    testing = 8'd0;
    for (int i = 0; i <= trials; i = i + 1) begin
        delay_check[i] = 24'd0;
    end

    // Apply reset
    #(4*CLK_20);
    reset = 1'b0; // Deassert reset
    enn = 1'b1;
    #(CLK_20 - 10);

    //Provide stimulus to the inputs
    for (int i = 0; i < delay; i = i + 1) begin
      audio_in = {$random} % 8000000;
      delay_check[i] = {audio_in[23:16],16'd0};
      #(CLK_50M*2);
      for (int m = 1; m < 2500; m = m + 1) begin
        //testing = testing + 8'd1;
        audio_in = {$random} % 16000000; //{testing, 16'd0};
        #(CLK_50M*2);
      end
    end

    for (int j = 0; j < ber_calc; j = j + 1) begin
      audio_in = {$random} % 14000000;
      delay_check[(j + delay)] = {audio_in[23:16],16'd0};
      check_output(delay_check[j]);
      #(CLK_50M*2);
      for (int n = 1; n < 2500; n = n + 1) begin
        audio_in = {$random} % 12000000;
        #(CLK_50M*2);
      end
    end

    for (int k = 0; k < delay - 6; k = k + 1) begin
      check_output(delay_check[k + ber_calc]);
      #CLK_20;
    end

    #CLK_20;
    //Test results, used same syntax as vending machine testbench from class
    $display("\n\n========= TEST SUMMARY =========");
    $display("     TEST COUNT: %-5d", num_passes + num_fails);
    $display("  -      PASSED: %-5d", num_passes);
    $display("  -      FAILED: %-5d", num_fails);
    $display("  - PERCENT BER: %-5d", (num_fails * 100) / (num_passes + num_fails));
    $display("================================\n\n");
    $stop;
  end
endmodule