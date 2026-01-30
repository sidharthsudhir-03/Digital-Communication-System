module Top_module_test (
    input clk_50m,
    input clk_20,
    input clk_160,
    input clk_960, 
    input reset,
	input enn, 
    input signed [23:0] audio_in_L,
    // input signed [23:0] audio_in_R,
    output signed [23:0] audio_out_L,
    output signed [23:0] audio_out_R
    );

/************************** ADC / DAC DECLARATIONS ************************/
    wire signed [7:0] left_8_mic, right_8_mic, sum_in, wav_system;
	wire signed [7:0] decoded_8_left, decoded_8_right;
	wire signed [23:0] left_24_mic, right_24_mic;
	/*
	//address counting;
	reg [9:0] address_mif,address_save, count;

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
*/
/****************** SERIALIZER / DESERIALIZER DECLARATIONS ****************/
	// control signals //
	logic ser_en_L, ser_en_R,ser_en,ser_en_wav; // enables serializer with first ADC output
	logic serializer_start_L, serializer_start_R; // initializes delay counter
    logic deserializer_start_L, deserializer_start_R; // enables deserializer
	logic deser_valid_L, deser_valid_R; // may not need to use

/********************** ENCODER / DECODER DECLARATIONS ********************/
	// encoder declarations //
	logic ecc_en_L, ecc_en_R; // enable signal for encoder and decoder
	logic audio_L, audio_R; // inputs
	logic in_odd_L, in_odd_R; // outputs
	logic in_even_L, in_even_R; // outputs
	logic encode_valid_L, encode_valid_R; // indicates valid output from encoder

	// decoder declarations //
	logic out_odd_L, out_odd_R; // inputs
	logic out_even_L, out_even_R; // inputs
	logic decoded_left, decoded_right; // outputs
	logic decode_valid_L, decode_valid_R;

/******************** MODULATOR / DEMODULATOR DECLARATIONS ****************/
	// modulator declarations //
	logic [15:0] re_symbol_L, re_symbol_R;
	logic [15:0] im_symbol_L, im_symbol_R;

/******************* TRANSMITTER / RECEIVER DECLARATIONS ******************/
	// transmitter declarations //
	logic [15:0] tx_re_out_L, tx_re_out_R; 
	logic [15:0] tx_im_out_L, tx_im_out_R;

	// receiver declarations //
	logic [15:0] rx_re_out_L, rx_re_out_R;
	logic [15:0] rx_im_out_L, rx_im_out_R;

/*************************** CHANNEL DECLARATIONS *************************/


// ******************************* READ MIC ***************************** //
	/*assign read  = read_ready;
	assign write  = write_ready;
	*/


	always @(posedge clk_50m) begin
		if(reset) begin
			// disable encoder / decoder
            ecc_en_L <= 0;
            ecc_en_R <= 0;
			//audio_out_L <= 0;
			//audio_out_R <= 0;
		end
		else begin
			//audio_out_L <= left_24_mic;
			//audio_out_R <= right_24_mic;
			if(1)begin
				//audio_out_L <= left_24_mic;
				//audio_out_R <= right_24_mic;
				// enable encoder and decoder
				ecc_en_L <= 1'b1;
				ecc_en_R <= 1'b1;
				//sum_in <= left_8_mic;
				//ser_en <= ser_en_L;
			end
		else begin
				//audio_out_L <= left_24_mic;
				//audio_out_R <= right_24_mic;
				// enable encoder and decoder
				ecc_en_L <= 1'b1;
				ecc_en_R <= 1'b1;
				//sum_in <= wav_system;
				//ser_en <= ser_en_wav;
		end
		end
		
	end
/*mif controll
always_ff @( posedge clk_20 ) begin 
	if (reset)begin
	address_mif <= 0;
	end
	else if (address_mif < 1024) begin
				address_mif <= address_mif +1;
	end
	else address_mif <= 0;

end	
always_ff @( posedge clk_20 ) begin
	if (reset)begin
		address_save <=0;
		save_en <=0;
		count <=0;
	end
	else if (wav_out == 16'h7F00 && count != 1)begin
		address_save <= 1;
		save_en <= 1;
		count <= 1;
	end
	else if( address_save < 1024 && count == 1) begin
		address_save <= address_save + 1;
		save_en <= 1;
	end
	else ;
end
*/

// ***************** INSTANTIATE LOWER LEVEL MODULES ******************** //

data_shifter_sampling ADC_L(
    .clk(clk_20),              // Clock signal with frequency 20KHz
    .data_in(audio_in_L),   // 24-bit signed input data
	.enn(1),
    .data_out(left_8_mic),    // 8-bit output data
	.ser_en(ser_en_L)
);
/*
data_shifter_sampling_wav ADC_wav(
    .clk(clk_50m),              // Clock signal with frequency 20KHz
    .data_in(wav_input),   // 24-bit signed input data
	.enn(1),
    .data_out(wav_system),    // 8-bit output data
	.ser_en(ser_en_wav)
);
*/
serializer serializer_L(
	.clk(clk_160),
	.reset(reset),
	.enable(ser_en),
	.parallel_data(sum_in),
	.serial_out(audio_L),
	.serializer_start(serializer_start_L)
);


delay delay_L(
    .clk(clk_160),
    .reset(reset),
    .serializer_start(serializer_start_L),
    .deserializer_start(deserializer_start_L)
);


convolutional_encoder convolutional_encoder_L(
    .clk(clk_160),
    .reset(reset),
    .encode_en(ecc_en_L),
    .audio_in(audio_L),
    .encoded_out_odd(in_odd_L),
    .encoded_out_even(in_even_L),
	.encode_valid(encode_valid_L)
  );


qpsk_modulator qpsk_modulator_L(
    .in_odd(in_odd_L),
    .in_even(in_even_L),
    .out_re (re_symbol_L),
    .out_im (im_symbol_L)
  );

tx_lite transmit_re_L(
    .data_in(re_symbol_L),
    .data_out(tx_re_out_L),
    .clk(clk_960),
    .reset(reset),
    .read_ready(encode_valid_L));

tx_lite transmit_im_L(
    .data_in(im_symbol_L),
    .data_out(tx_im_out_L),
    .clk(clk_960),
    .reset(reset),
    .read_ready(encode_valid_L));

rx_lite receive_re_L(
    .data_in(tx_re_out_L),
    .data_out(rx_re_out_L),
    .clk(clk_960),
    .reset(reset)
    );

rx_lite receive_im_L(
    .data_in(tx_im_out_L),
    .data_out(rx_im_out_L),
    .clk(clk_960),
    .reset(reset)
    );

qpsk_demodulator qpsk_demodulator_L(
    .in_re(rx_re_out_L),
    .in_im(rx_im_out_L),
    .out_odd(out_odd_L),
    .out_even(out_even_L)
  );


Viterbi_Decoder1 viterbi_decoder_L(
    .clk(clk_160),
    .reset(reset),
    .enb(ecc_en_R),
    .Viterbi_Decoder1_in_0(out_odd_L), 
    .Viterbi_Decoder1_in_1(out_even_L), 
    .decoded(decoded_left),
	.decode_valid(decode_valid_L)
  );

deserializer deserializer_L(
	.clk(clk_160),
	.reset(reset),
	.deserializer_start(deserializer_start_L),
	.serial_in(decoded_left),
	.parallel_data(decoded_8_left),
	.data_valid(deser_valid_L)
);


data_resampling DAC_L(
    .clk(clk_20),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_left),   // 8-bit signed input data
    .enn(1),
    .data_out(audio_out_L)    // 24-bit output data
);

data_resampling DAC_R(
    .clk(clk_20),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_left),   // 8-bit signed input data
    .enn(1),
    .data_out(audio_out_R)    // 24-bit output data
);

/*data_resampling_wav DAC_wav(
    .clk(clk_50m),              // Clock signal with frequency 20KHz
    .data_in(decoded_8_left),   // 8-bit signed input data
    .enn(1),
    .data_out(wav_out)    // 24-bit output data
);

//WAV type
mono_mem mif_mem(
	.address(address_mif),
	.clock(clk_20),
	.data(),
	.wren(0),
	.q(wav_input));

save_mem save_mem(
	.address(address_save),
	.clock(clk_20),
	.data(wav_out),
	.wren(save_en),
	.q());
*/

endmodule


