// -------------------------------------------------------------
// Module: Top Level Module
// Top level module for the communication system 
//
// -------------------------------------------------------------

module Top_module (CLOCK_50, CLOCK2_50, KEY,SW, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	input [9:0] SW;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
    wire reset = ~KEY[0];
/************************ AUDIO CODEC DECLARATIONS ************************/
    wire read_ready, write_ready;
    wire read, write, read_s, write_s;
    wire [23:0] readdata_left, readdata_right;  
    reg [23:0] writedata_left, writedata_right;

/************************** ADC / DAC DECLARATIONS ************************/
    wire signed [7:0] mic_8_in,sum_in, wav_system;
	wire signed [7:0] decoded_8_out;
	wire signed [23:0] left_24_mic, right_24_mic;

	//address counting;
	reg [9:0] address_mif,address_save, count;
	parameter words = 1024;
    // Clock generators
    wire CLOCK_16,CLOCK_160, CLOCK_960, CLOCK_20, CLOCK_8,CLOCK_10;

    // State variables
    reg [5:0] state_mic = 0, state_wav = 0;

	//mic state
    reg [5:0] normal_mic = 1;

	//wav state
	reg [5:0] count_wav = 1;

	//wav part
	logic save_en;
	wire [15:0] wav_input, wav_out;
	wire signed [7:0] e_wav;
	wire signed [24:0] t_wav;

/****************** SERIALIZER / DESERIALIZER DECLARATIONS ****************/
	// control signals //
	logic serial_en, ser_en, ser_en_wav; // enables serializer with first ADC output
	logic serial_start; // initializes delay counter
    logic deserial_start; // enables deserializer
	logic deserial_valid;

/********************** ENCODER / DECODER DECLARATIONS ********************/
	// encoder declarations //
	logic ecc_en; // enable signal for encoder and decoder
	logic audio; 
	logic in_odd; 
	logic in_even; 
	logic encode_valid; 

	// decoder declarations //
	logic out_odd; 
	logic out_even; 
	logic decoded;
	logic decode_valid;

/******************** MODULATOR / DEMODULATOR DECLARATIONS ****************/
	// modulator declarations //
	logic [15:0] re_symbol;
	logic [15:0] im_symbol;

/******************* TRANSMITTER / RECEIVER DECLARATIONS ******************/
	// transmitter declarations //
	logic [15:0] tx_re_out; 
	logic [15:0] tx_im_out;

	// receiver declarations //
	logic [15:0] rx_re_out;
	logic [15:0] rx_im_out;

/*************************** CHANNEL DECLARATIONS *************************/
	logic [15:0] noise;
	logic state_C;

// ******************************* READ MIC ***************************** //
	assign read  = read_ready;
	assign write  = write_ready;


	always @(posedge CLOCK_50 or posedge reset) begin
		if(reset) begin
			// disable encoder / decoder
            ecc_en <= 0;
			writedata_left <= 0;
			writedata_right <= 0;
		end
		else begin
			writedata_left <= left_24_mic;
			writedata_right <= right_24_mic;
			if(SW[1])begin
				writedata_left <= left_24_mic;
				writedata_right <= right_24_mic;
				// enable encoder and decoder
				ecc_en <= 1'b1;
				sum_in <= mic_8_in;
				ser_en <= serial_en;
			end
		else begin
				writedata_left <= left_24_mic;
				writedata_right <= right_24_mic;
				// enable encoder and decoder
				ecc_en <= 1'b1;
				sum_in <= wav_system;
				ser_en <= ser_en_wav;
		end
		end
		
	end
//mif controll
always_ff @( posedge CLOCK_20 ) begin 
	if (reset)begin
	address_mif <= 0;
	end
	else if (address_mif < words) begin
				address_mif <= address_mif +1;
	end
	else address_mif <= 0;

end	
always_ff @( posedge CLOCK_20 ) begin
	if (reset)begin
		address_save <=0;
		save_en <=0;
		count <=0;
	end
	else if (deserial_valid && count != 1) begin
		address_save <= 0;
		save_en <= 1;
		count <= 1;
	end
	else if( address_save < words && count == 1) begin
		address_save <= address_save + 1;
		save_en <= 1;
	end
	else ;
end

// ************************** CLOCK GENERATORS ************************** //

new_pll_0002 top_pll_inst (
		.refclk   (CLOCK_50),   //  refclk.clk
		.rst      (reset),      //   reset.reset
		.outclk_0 (CLOCK_16), // outclk0.clk
		.outclk_1 (CLOCK_960), // outclk1.clk
		.outclk_2 (CLOCK_8), // outclk2.clk
		.locked   ()    //  locked.export
	);

kHz_clock_generator #(20) TT_CLK (
        .input_clk(CLOCK_8), 
        .reset(reset), 
        .output_clk(CLOCK_20) // 20kHz clock
    );
kHz_clock_generator #(5)Td_CLK(
    .input_clk(CLOCK_16),   
    .reset(reset),       
    .output_clk(CLOCK_160) // 160kHz clock
);
kHz_clock_generator #(40) Tk_CLK (
        .input_clk(CLOCK_8), 
        .reset(reset), 
        .output_clk(CLOCK_10) // 10kHz clock
    );

// ***************** INSTANTIATE LOWER LEVEL MODULES ******************** //

data_shifter_sampling ADC_inst(
    .clk(CLOCK_20),              // Clock signal with frequency 20KHz
    .data_in(readdata_left),   // 24-bit signed input data
	.enn(1),
    .data_out(mic_8_in),    // 8-bit output data
	.ser_en(serial_en)
);

data_shifter_sampling_wav ADC_wav(
    .clk(CLOCK_50),              // Clock signal with frequency 20KHz
    .data_in(wav_input),   // 24-bit signed input data
	.enn(1),
    .data_out(wav_system),    // 8-bit output data
	.ser_en(ser_en_wav)
);

serializer serializer_inst(
	.clk(CLOCK_160),
	.reset(reset),
	.enable(ser_en),
	.parallel_data(sum_in),
	.serial_out(audio),
	.serializer_start(serial_start)
);


delay delay_inst(
    .clk(CLOCK_160),
    .reset(reset),
    .serializer_start(serial_start),
    .deserializer_start(deserial_start)
);


convolutional_encoder convolutional_encoder_inst(
    .clk(CLOCK_160),
    .reset(reset),
    .encode_en(ecc_en),
    .audio_in(audio),
    .encoded_out_odd(in_odd),
    .encoded_out_even(in_even),
	.encode_valid(encode_valid)
  );


qpsk_modulator qpsk_modulator_inst(
    .in_odd(in_odd),
    .in_even(in_even),
    .out_re (re_symbol),
    .out_im (im_symbol)
  );

tx_lite transmit_re_inst(
    .data_in(re_symbol),
    .data_out(tx_re_out),
    .clk(CLOCK_960),
    .reset(reset),
    .read_ready(encode_valid));

tx_lite transmit_im_inst(
    .data_in(im_symbol),
    .data_out(tx_im_out),
    .clk(CLOCK_960),
    .reset(reset),
    .read_ready(encode_valid));

 Gilbert GI(
    .clk(CLOCK_10),
    .reset(reset),
    .channel_state(state_C)  // Output: 1 for Good, 0 for Bad
);
awgn_channel awgn(
    .clk(CLOCK_50),
    .reset(reset),
    .state(state_C),
    .signal_out(noise)
);

rx_lite receive_re_inst(
    .data_in(tx_re_out+noise),
    .data_out(rx_re_out),
    .clk(CLOCK_960),
    .reset(reset),
    );

rx_lite receive_im_inst(
    .data_in(tx_im_out),
    .data_out(rx_im_out),
    .clk(CLOCK_960),
    .reset(reset),
    );

qpsk_demodulator qpsk_demodulator_inst(
    .in_re(rx_re_out),
    .in_im(rx_im_out),
    .out_odd(out_odd),
    .out_even(out_even)
  );


Viterbi_Decoder1 viterbi_decoder_inst(
    .clk(CLOCK_160),
    .reset(reset),
    .enb(ecc_en),
    .Viterbi_Decoder1_in_0(out_odd), 
    .Viterbi_Decoder1_in_1(out_even), 
    .decoded(decoded),
	.decode_valid(decode_valid)
  );

deserializer deserializer_inst(
	.clk(CLOCK_160),
	.reset(reset),
	.deserializer_start(deserial_start),
	.serial_in(decoded),
	.parallel_data(decoded_8_out),
	.data_valid(deserial_valid)
	);
	
data_resampling DAC_L(
    .clk(CLOCK_20),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_out),   // 8-bit signed input data
    .enn(1),
    .data_out(left_24_mic)    // 24-bit output data
);

data_resampling DAC_R(
    .clk(CLOCK_20),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_out),   // 8-bit signed input data
    .enn(1),
    .data_out(right_24_mic)    // 24-bit output data
);

data_resampling_wav DAC_wav(
    .clk(CLOCK_50),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_out),   // 8-bit signed input data
    .enn(1),
    .data_out(wav_out)    // 24-bit output data
);

//WAV type
mono_mem mif_mem(
	.address(address_mif),
	.clock(CLOCK_20),
	.data(),
	.wren(0),
	.q(wav_input));

save_mem save_mem(
	.address(address_save),
	.clock(CLOCK_20),
	.data(wav_out),
	.wren(save_en),
	.q());
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface.
// The following code is copied from the FPGA starter assignment files 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule


