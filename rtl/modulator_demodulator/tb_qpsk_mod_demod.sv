`timescale 1 ps / 1 ps
module tb_qpsk_mod_demod;
// testbench to test the modulator and demodulator
// ************************* VARIABLE DECLARATIONS ***********************//
  // General Inputs
  reg clk;
  reg reset;
  integer num_passes = 0;
  integer num_fails = 0;

  // qpsk_modulator inputs
  reg in_odd;
  reg in_even;

  // qpsk_modulator outputs / qpsk_demodulator inputs
  reg signed [15:0] re_symbol;
  reg signed [15:0] im_symbol;

  // qpsk_demodulator outputs
  wire out_odd;
  wire out_even;

  // ***************** INSTANTIATE DEVICES UNDER TEST ******************//
  qpsk_modulator dut1 (
    .in_odd(in_odd),
    .in_even(in_even),
    .out_re (re_symbol),
    .out_im (im_symbol)
  );

  qpsk_demodulator dut2 (
    .in_re(re_symbol),
    .in_im(im_symbol),
    .out_odd(out_odd),
    .out_even(out_even)
  );
  
  // ******************************** TASKS ******************************//
    task check_re_symbol(input signed [15:0] exp_re);
        assert (re_symbol === exp_re) begin
            $display("[PASS]: real symbol value is %-d (expected %-d)\n", re_symbol, exp_re);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: real symbol value is %-d (expected %-d)\n", re_symbol, exp_re);
            num_fails = num_fails + 1;
        end
    endtask

    task check_im_symbol(input signed [15:0] exp_im);
        assert (im_symbol === exp_im) begin
            $display("[PASS]: imaginary symbol value is %-d (expected %-d)\n", im_symbol, exp_im);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: imaginary symbol value is %-d (expected %-d)\n", im_symbol, exp_im);
            num_fails = num_fails + 1;
        end
    endtask

    task check_out_odd(input exp_odd);
        assert (out_odd === exp_odd) begin
            $display("[PASS]: odd bit value is %-d (expected %-d)\n", out_odd, exp_odd);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: odd bit value is %-d (expected %-d)\n", out_odd, exp_odd);
            num_fails = num_fails + 1;
        end
    endtask

    task check_out_even(input exp_even);
        assert (out_even === exp_even) begin
            $display("[PASS]: even bit value is %-d (expected %-d)\n", out_even, exp_even);
            num_passes = num_passes + 1;
        end else begin
            $error("[FAIL]: even bit value is %-d (expected %-d)\n", out_even, exp_even);
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
    reset = 1;
    in_odd = 1'b0;
    in_even = 1'b0;

    // Apply reset
    #20;
    reset = 0; // Deassert reset

    // Provide stimulus to the inputs
    #20;
    in_odd = 1'b0;
    in_even = 1'b0;

    #10;
    check_re_symbol(16'sb1000100101011111); // negative
    check_im_symbol(16'sb1000100101011111); // negative
    check_out_odd(in_odd);
    check_out_even(in_even);

    #20;
    in_odd = 1'b0;
    in_even = 1'b1;

    #10;
    check_re_symbol(16'sb1000100101011111); // negative
    check_im_symbol(16'sb0001011010100000); // positive
    check_out_odd(in_odd);
    check_out_even(in_even);

    #20;
    in_odd = 1'b1;
    in_even = 1'b0;

    #10;
    check_re_symbol(16'sb0001011010100000); // positive
    check_im_symbol(16'sb1000100101011111); // negative
    check_out_odd(in_odd);
    check_out_even(in_even);

    #20;
    in_odd = 1'b1;
    in_even = 1'b1;

    #10;
    check_re_symbol(16'sb0001011010100000); // positive
    check_im_symbol(16'sb0001011010100000); // positive
    check_out_odd(in_odd);
    check_out_even(in_even);

    #20;
    in_odd = $urandom%1;
    in_even = $urandom%1;

    #10;
    check_out_odd(in_odd);
    check_out_even(in_even);

    #20;
    in_odd = $urandom%1;
    in_even = $urandom%1;

    #10;
    check_out_odd(in_odd);
    check_out_even(in_even);

        #20;
    in_odd = $urandom%1;
    in_even = $urandom%1;

    #10;
    check_out_odd(in_odd);
    check_out_even(in_even);

    #10
    //Test results, used same syntax as vending machine testbench from class
    $display("\n\n==== TEST SUMMARY ====");
    $display("  TEST COUNT: %-5d", num_passes + num_fails);
    $display("    - PASSED: %-5d", num_passes);
    $display("    - FAILED: %-5d", num_fails);
    $display("======================\n\n");
    $stop;
  end
endmodule
