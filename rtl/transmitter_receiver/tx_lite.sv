module tx_lite(
    data_in,
    data_out,
    clk,
    reset,
    read_ready);
	 
	 parameter N = 97;         	// Number of filter coefficients
    parameter DATA_WIDTH = 16; 	// Width of the data
    parameter COEFF_WIDTH = 16; 	// Width of the filter coefficients

    input clk;
    input reset;
    input read_ready; 				// Signal to trigger transmitter to reading input data from modulator
    input [DATA_WIDTH-1:0] data_in;

    
    output reg [DATA_WIDTH-1:0] data_out;

    reg [DATA_WIDTH-1:0] sample_buffer [0:N-1]; // The data that gets passed into the shift registers of the filter
    wire [COEFF_WIDTH-1:0] coeffs [0:N-1]; 		// Exported coefficients from MATLAB
    reg [2:0] count;

    integer i; // Iteration purposes

    // Converting coefficients from MATLAB to Q2.13 format(including rounding to nearest integer) via excel, 
    assign coeffs[0]  = 16'sd0;
	assign coeffs[1]  = 16'sd5;
	assign coeffs[2]  = 16'sd9;
	assign coeffs[3]  = 16'sd10;
	assign coeffs[4]  = 16'sd9;
	assign coeffs[5]  = 16'sd5;
	assign coeffs[6]  = 16'sd0;
	assign coeffs[7]  = -16'sd5;
	assign coeffs[8]  = -16'sd7;
	assign coeffs[9]  = -16'sd7;
	assign coeffs[10] = -16'sd4;
	assign coeffs[11] = -16'sd1;
	assign coeffs[12] = 16'sd0;
	assign coeffs[13] = -16'sd2;
	assign coeffs[14] = -16'sd6;
	assign coeffs[15] = -16'sd12;
	assign coeffs[16] = -16'sd15;
	assign coeffs[17] = -16'sd11;
	assign coeffs[18] = 16'sd0;
	assign coeffs[19] = 16'sd19;
	assign coeffs[20] = 16'sd40;
	assign coeffs[21] = 16'sd56;
	assign coeffs[22] = 16'sd57;
	assign coeffs[23] = 16'sd39;
	assign coeffs[24] = 16'sd0;
	assign coeffs[25] = -16'sd53;
	assign coeffs[26] = -16'sd106;
	assign coeffs[27] = -16'sd141;
	assign coeffs[28] = -16'sd139;
	assign coeffs[29] = -16'sd91;
	assign coeffs[30] = 16'sd0;
	assign coeffs[31] = 16'sd117;
	assign coeffs[32] = 16'sd230;
	assign coeffs[33] = 16'sd299;
	assign coeffs[34] = 16'sd292;
	assign coeffs[35] = 16'sd191;
	assign coeffs[36] = 16'sd0;
	assign coeffs[37] = -16'sd245;
	assign coeffs[38] = -16'sd484;
	assign coeffs[39] = -16'sd641;
	assign coeffs[40] = -16'sd643;
	assign coeffs[41] = -16'sd435;
	assign coeffs[42] = 16'sd0;
	assign coeffs[43] = 16'sd633;
	assign coeffs[44] = 16'sd1392;
	assign coeffs[45] = 16'sd2167;
	assign coeffs[46] = 16'sd2838;
	assign coeffs[47] = 16'sd3293;
	assign coeffs[48] = 16'sd3454;
	assign coeffs[49] = 16'sd3293;
	assign coeffs[50] = 16'sd2838;
	assign coeffs[51] = 16'sd2167;
	assign coeffs[52] = 16'sd1392;
	assign coeffs[53] = 16'sd633;
	assign coeffs[54] = 16'sd0;
	assign coeffs[55] = -16'sd435;
	assign coeffs[56] = -16'sd643;
	assign coeffs[57] = -16'sd641;
	assign coeffs[58] = -16'sd484;
	assign coeffs[59] = -16'sd245;
	assign coeffs[60] = 16'sd0;
	assign coeffs[61] = 16'sd191;
	assign coeffs[62] = 16'sd292;
	assign coeffs[63] = 16'sd299;
	assign coeffs[64] = 16'sd230;
	assign coeffs[65] = 16'sd117;
	assign coeffs[66] = 16'sd0;
	assign coeffs[67] = -16'sd91;
	assign coeffs[68] = -16'sd139;
	assign coeffs[69] = -16'sd141;
	assign coeffs[70] = -16'sd106;
	assign coeffs[71] = -16'sd53;
	assign coeffs[72] = 16'sd0;
	assign coeffs[73] = 16'sd39;
	assign coeffs[74] = 16'sd57;
	assign coeffs[75] = 16'sd56;
	assign coeffs[76] = 16'sd40;
	assign coeffs[77] = 16'sd19;
	assign coeffs[78] = 16'sd0;
	assign coeffs[79] = -16'sd11;
	assign coeffs[80] = -16'sd15;
	assign coeffs[81] = -16'sd12;
	assign coeffs[82] = -16'sd6;
	assign coeffs[83] = -16'sd2;
	assign coeffs[84] = 16'sd0;
	assign coeffs[85] = -16'sd1;
	assign coeffs[86] = -16'sd4;
	assign coeffs[87] = -16'sd7;
	assign coeffs[88] = -16'sd7;
	assign coeffs[89] = -16'sd5;
	assign coeffs[90] = 16'sd0;
	assign coeffs[91] = 16'sd5;
	assign coeffs[92] = 16'sd9;
	assign coeffs[93] = 16'sd10;
	assign coeffs[94] = 16'sd9;
	assign coeffs[95] = 16'sd5;
	assign coeffs[96] = 16'sd0;



    wire [DATA_WIDTH-1:0] multiplied [0:N-1]; //16 bit reg, 97 of them to store multiplied results


    //instantiate the multiply module to calculate the taps
    multiply m1(sample_buffer[0], coeffs[0], multiplied[0]);
    multiply m2(sample_buffer[1], coeffs[1], multiplied[1]);
    multiply m3(sample_buffer[2], coeffs[2], multiplied[2]);
    multiply m4(sample_buffer[3], coeffs[3], multiplied[3]);
    multiply m5(sample_buffer[4], coeffs[4], multiplied[4]);

    multiply m6(sample_buffer[5], coeffs[5], multiplied[5]);
    multiply m7(sample_buffer[6], coeffs[6], multiplied[6]);
    multiply m8(sample_buffer[7], coeffs[7], multiplied[7]);
    multiply m9(sample_buffer[8], coeffs[8], multiplied[8]);
    multiply m10(sample_buffer[9], coeffs[9], multiplied[9]);

    multiply m11(sample_buffer[10], coeffs[10], multiplied[10]);
    multiply m12(sample_buffer[11], coeffs[11], multiplied[11]);
    multiply m13(sample_buffer[12], coeffs[12], multiplied[12]);
    multiply m14(sample_buffer[13], coeffs[13], multiplied[13]);
    multiply m15(sample_buffer[14], coeffs[14], multiplied[14]);

    multiply m16(sample_buffer[15], coeffs[15], multiplied[15]);
    multiply m17(sample_buffer[16], coeffs[16], multiplied[16]);
    multiply m18(sample_buffer[17], coeffs[17], multiplied[17]);
    multiply m19(sample_buffer[18], coeffs[18], multiplied[18]);
    multiply m20(sample_buffer[19], coeffs[19], multiplied[19]);

    multiply m21(sample_buffer[20], coeffs[20], multiplied[20]);
    multiply m22(sample_buffer[21], coeffs[21], multiplied[21]);
    multiply m23(sample_buffer[22], coeffs[22], multiplied[22]);
    multiply m24(sample_buffer[23], coeffs[23], multiplied[23]);
    multiply m25(sample_buffer[24], coeffs[24], multiplied[24]);

    multiply m26(sample_buffer[25], coeffs[25], multiplied[25]);
    multiply m27(sample_buffer[26], coeffs[26], multiplied[26]);
    multiply m28(sample_buffer[27], coeffs[27], multiplied[27]);
    multiply m29(sample_buffer[28], coeffs[28], multiplied[28]);
    multiply m30(sample_buffer[29], coeffs[29], multiplied[29]);

    multiply m31(sample_buffer[30], coeffs[30], multiplied[30]);
    multiply m32(sample_buffer[31], coeffs[31], multiplied[31]);
    multiply m33(sample_buffer[32], coeffs[32], multiplied[32]);
	 
	 multiply m34(sample_buffer[33], coeffs[33], multiplied[33]);
    multiply m35(sample_buffer[34], coeffs[34], multiplied[34]);
    multiply m36(sample_buffer[35], coeffs[35], multiplied[35]);
    multiply m37(sample_buffer[36], coeffs[36], multiplied[36]);
    multiply m38(sample_buffer[37], coeffs[37], multiplied[37]);

    multiply m39(sample_buffer[38], coeffs[38], multiplied[38]);
    multiply m40(sample_buffer[39], coeffs[39], multiplied[39]);
    multiply m41(sample_buffer[40], coeffs[40], multiplied[40]);
    multiply m42(sample_buffer[41], coeffs[41], multiplied[41]);
    multiply m43(sample_buffer[42], coeffs[42], multiplied[42]);

    multiply m44(sample_buffer[43], coeffs[43], multiplied[43]);
    multiply m45(sample_buffer[44], coeffs[44], multiplied[44]);
    multiply m46(sample_buffer[45], coeffs[45], multiplied[45]);
    multiply m47(sample_buffer[46], coeffs[46], multiplied[46]);
    multiply m48(sample_buffer[47], coeffs[47], multiplied[47]);

    multiply m49(sample_buffer[48], coeffs[48], multiplied[48]);
    multiply m50(sample_buffer[49], coeffs[49], multiplied[49]);
    multiply m51(sample_buffer[50], coeffs[50], multiplied[50]);
    multiply m52(sample_buffer[51], coeffs[51], multiplied[51]);
    multiply m53(sample_buffer[52], coeffs[52], multiplied[52]);

    multiply m54(sample_buffer[53], coeffs[53], multiplied[53]);
    multiply m55(sample_buffer[54], coeffs[54], multiplied[54]);
    multiply m56(sample_buffer[55], coeffs[55], multiplied[55]);
    multiply m57(sample_buffer[56], coeffs[56], multiplied[56]);
    multiply m58(sample_buffer[57], coeffs[57], multiplied[57]);

    multiply m59(sample_buffer[58], coeffs[58], multiplied[58]);
    multiply m60(sample_buffer[59], coeffs[59], multiplied[59]);
    multiply m61(sample_buffer[60], coeffs[60], multiplied[60]);
    multiply m62(sample_buffer[61], coeffs[61], multiplied[61]);
    multiply m63(sample_buffer[62], coeffs[62], multiplied[62]);

    multiply m64(sample_buffer[63], coeffs[63], multiplied[63]);
    multiply m65(sample_buffer[64], coeffs[64], multiplied[64]);
    multiply m66(sample_buffer[65], coeffs[65], multiplied[65]);
    multiply m67(sample_buffer[66], coeffs[66], multiplied[66]);
    multiply m68(sample_buffer[67], coeffs[67], multiplied[67]);

    multiply m69(sample_buffer[68], coeffs[68], multiplied[68]);
    multiply m70(sample_buffer[69], coeffs[69], multiplied[69]);
    multiply m71(sample_buffer[70], coeffs[70], multiplied[70]);
    multiply m72(sample_buffer[71], coeffs[71], multiplied[71]);
    multiply m73(sample_buffer[72], coeffs[72], multiplied[72]);

    multiply m74(sample_buffer[73], coeffs[73], multiplied[73]);
    multiply m75(sample_buffer[74], coeffs[74], multiplied[74]);
    multiply m76(sample_buffer[75], coeffs[75], multiplied[75]);
    multiply m77(sample_buffer[76], coeffs[76], multiplied[76]);
    multiply m78(sample_buffer[77], coeffs[77], multiplied[77]);

    multiply m79(sample_buffer[78], coeffs[78], multiplied[78]);
    multiply m80(sample_buffer[79], coeffs[79], multiplied[79]);
    multiply m81(sample_buffer[80], coeffs[80], multiplied[80]);
    multiply m82(sample_buffer[81], coeffs[81], multiplied[81]);
    multiply m83(sample_buffer[82], coeffs[82], multiplied[82]);

    multiply m84(sample_buffer[83], coeffs[83], multiplied[83]);
    multiply m85(sample_buffer[84], coeffs[84], multiplied[84]);
    multiply m86(sample_buffer[85], coeffs[85], multiplied[85]);
    multiply m87(sample_buffer[86], coeffs[86], multiplied[86]);
    multiply m88(sample_buffer[87], coeffs[87], multiplied[87]);

    multiply m89(sample_buffer[88], coeffs[88], multiplied[88]);
    multiply m90(sample_buffer[89], coeffs[89], multiplied[89]);
    multiply m91(sample_buffer[90], coeffs[90], multiplied[90]);
    multiply m92(sample_buffer[91], coeffs[91], multiplied[91]);
    multiply m93(sample_buffer[92], coeffs[92], multiplied[92]);

    multiply m94(sample_buffer[93], coeffs[93], multiplied[93]);
    multiply m95(sample_buffer[94], coeffs[94], multiplied[94]);
    multiply m96(sample_buffer[95], coeffs[95], multiplied[95]);
    multiply m97(sample_buffer[96], coeffs[96], multiplied[96]);


    
    // Sequential logic to process the data and output the sum of the multiplied data
    always @(posedge clk) begin
	 
        if (reset) begin
            data_out = 16'd0;
            for (i = 0; i < N; i = i + 1) begin //clearing the 97 sized input sample buffer
                sample_buffer[i] <= 16'd0;
            end
            count <= 3'b0;
        end 
		else if (read_ready) begin
            if (count == 3'd0) begin
                sample_buffer[0] <= data_in;  //take in the input data at start of buffer
                count <= 3'd5; // counter of 6 to accept input evey 6th period of the tx clock
            end else begin
                sample_buffer[0] <= 0;
                count <= count - 1;
            end

            // Shifting input samples in the buffer 
            for (i = N-1; i > 0; i = i - 1) begin
                sample_buffer[i] <= sample_buffer[i-1];
            end

            //output data is basically sum of multiplied data
				data_out <= multiplied[0] + multiplied[1] + multiplied[2] + multiplied[3] + multiplied[4] + 
             multiplied[5] + multiplied[6] + multiplied[7] + multiplied[8] + multiplied[9] + 
             multiplied[10] + multiplied[11] + multiplied[12] + multiplied[13] + multiplied[14] + 
             multiplied[15] + multiplied[16] + multiplied[17] + multiplied[18] + multiplied[19] + 
             multiplied[20] + multiplied[21] + multiplied[22] + multiplied[23] + multiplied[24] + 
             multiplied[25] + multiplied[26] + multiplied[27] + multiplied[28] + multiplied[29] + 
             multiplied[30] + multiplied[31] + multiplied[32] + multiplied[33] + multiplied[34] + 
             multiplied[35] + multiplied[36] + multiplied[37] + multiplied[38] + multiplied[39] + 
             multiplied[40] + multiplied[41] + multiplied[42] + multiplied[43] + multiplied[44] + 
             multiplied[45] + multiplied[46] + multiplied[47] + multiplied[48] + multiplied[49] + 
             multiplied[50] + multiplied[51] + multiplied[52] + multiplied[53] + multiplied[54] + 
             multiplied[55] + multiplied[56] + multiplied[57] + multiplied[58] + multiplied[59] + 
             multiplied[60] + multiplied[61] + multiplied[62] + multiplied[63] + multiplied[64] + 
             multiplied[65] + multiplied[66] + multiplied[67] + multiplied[68] + multiplied[69] + 
             multiplied[70] + multiplied[71] + multiplied[72] + multiplied[73] + multiplied[74] + 
             multiplied[75] + multiplied[76] + multiplied[77] + multiplied[78] + multiplied[79] + 
             multiplied[80] + multiplied[81] + multiplied[82] + multiplied[83] + multiplied[84] + 
             multiplied[85] + multiplied[86] + multiplied[87] + multiplied[88] + multiplied[89] + 
             multiplied[90] + multiplied[91] + multiplied[92] + multiplied[93] + multiplied[94] + 
             multiplied[95] + multiplied[96];

        end
        else begin
            data_out = 16'd0;
            sample_buffer[0] <= 0;
            count <= 3'd0;
        end
    end


endmodule

