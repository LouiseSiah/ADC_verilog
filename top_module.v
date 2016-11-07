module top_module(
	input CLOCK_50,
	input CLOCK_27,


	//////////// LED //////////
	output		  [7:0]		LEDG,
	output		  [17:0]		LEDR,

	//////////// KEY //////////
	input		     [3:0]		KEY,

	//////////// SW //////////
	input		     [17:0]		SW,

 
	//////////// Audio //////////
	input		          		AUD_ADCDAT,
	input		          		AUD_ADCLRCK,
	input		          		AUD_BCLK,
	output		        		AUD_DACDAT,
	input		          		AUD_DACLRCK,
	output		        		AUD_XCK,
	
	//////////// I2C for Audio and Tv-Decode //////////
	output		        		I2C_SCLK,
	inout		          		I2C_SDAT
);

wire CLOCK_500;
wire [23:0]DATA;
wire endI2C, goI2C;
wire XCK;

parameter audio_data_size = 16;

CLOCK_500 i2c_and_XClock
(	              
	.CLOCK(CLOCK_50), //i
	.CLOCK_500(CLOCK_500), //o
	.DATA(DATA), //o 24b
	.END(endI2C), //i
	.RESET(KEY[0]), //i
	.GO(goI2C), //o
	.CLOCK_2(XCK) //o
);

assign AUD_XCK = XCK;
assign AUD_DACDAT = AUD_ADCDAT;
assign LEDR[15:0] = adc_data;
wire [audio_data_size-1:0] adc_data;

ShiftRegister #(.data_size(audio_data_size))SR1(
	.clock(AUD_BCLK),
	.reset(KEY[0]),
	.data_in(AUD_ADCDAT),
	.data_out(adc_data)
);
				
i2c adc_configure
(
			 .CLOCK(CLOCK_500),
			 .I2C_SCLK(I2C_SCLK),		//I2C CLOCK
			 .I2C_SDAT(I2C_SDAT),		//I2C DATA
			 .I2C_DATA(DATA),		//DATA:[SLAVE_ADDR,SUB_ADDR,DATA]
			 .GO(goI2C),      		//GO transfor
			 .END(endI2C),    	    //END transfor 
			 .W_R(),     		//W_R
			 .ACK(),     	    //ACK
			 .RESET(KEY[0]),
			 //TEST
			 .SD_COUNTER(),
			 .SDO()
		   	);
				
//keytr debounce(
//				.key(KEY[0]),
//				.key1(KEY[1]),
//				.ON(),
//				.clock(CLOCK_500),
//				.KEYON(LEDG[7:7]),
//				.counter()	
//			 );
			 

endmodule
