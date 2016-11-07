/////////////////////////////////////////////////////////////////////////
// modified from the Terasic version:
//   eliminate all memory references
//   simplify interface to top-level module
//   add audio I/O from top-level modulem
// modifed by Bruce Land, Cornell University 2007
/////////////////////////////////////////////////////////////////////////

module AUDIO_DAC_ADC ( 
    oAUD_BCK,
    oAUD_DATA,
    oAUD_LRCK,

    iAUD_ADCDAT,

    // Control Signals
    iCLK_18_4,
    iRST_N
	//testing signal

);
////testing signal
//output     [17:0]LEDR;

parameter REF_CLK     = 12288000; // 18.432  MHz
parameter SAMPLE_RATE = 32000;    // 48      KHz
parameter DATA_WIDTH  = 16;       // 16      Bits
parameter CHANNEL_NUM = 2;        // Dual Channel


// Audio Side
output     oAUD_DATA;
output     oAUD_LRCK;
output reg oAUD_BCK;
input      iAUD_ADCDAT;
// Control Signals
input      iCLK_18_4;
input      iRST_N;
// Internal Registers and Wires
reg [3:0]  BCK_DIV;
reg [8:0]  LRCK_1X_DIV;

reg [3:0]  SEL_Cont;

// to DAC and from ADC
reg signed [DATA_WIDTH-1:0] AUD_outL, AUD_outR;
reg signed [DATA_WIDTH-1:0] AUD_inL, AUD_inR;

reg LRCK_1X;
reg LRCK_2X;
reg LRCK_4X;
wire [3:0] bit_in;

//////////////////////////////////////////////////
////////////    AUD_BCK Generator   //////////////
/////////////////////////////////////////////////
always @ (posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        BCK_DIV <= 0;
        oAUD_BCK <= 0;
    end
    else
    begin
        if (BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1)
        begin
            BCK_DIV <= 0;
            oAUD_BCK <= ~oAUD_BCK;
        end
        else
			BCK_DIV <= BCK_DIV + 4'd1;
    end
end

//////////////////////////////////////////////////
////////////    AUD_LRCK Generator  //////////////
//oAUD_LRCK is high for left and low for right////
//////////////////////////////////////////////////
always @ (posedge iCLK_18_4 or negedge iRST_N)
begin
    if(!iRST_N)
    begin
        LRCK_1X_DIV <= 0;
        LRCK_2X_DIV <= 0;
        LRCK_4X_DIV <= 0;
        LRCK_1X     <= 0;
        LRCK_2X     <= 0;
        LRCK_4X     <= 0;
    end
    else
    begin
        // LRCK 1X
        if (LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1)
        begin
            LRCK_1X_DIV <= 0;
            LRCK_1X <=  ~LRCK_1X;
        end
        else
			LRCK_1X_DIV <= LRCK_1X_DIV + 9'd1;

end

assign oAUD_LRCK = LRCK_1X;

//////////////////////////////////////////////////
//////////  16 Bits - MSB First //////////////////
/// Clocks in the ADC input
/// and sets up the output bit selector
/// and clocks out the DAC data
//////////////////////////////////////////////////
// first the ADC
always @ (negedge oAUD_BCK or negedge iRST_N)
begin
    if (!iRST_N) 
			SEL_Cont <= 0;
    else
    begin
        SEL_Cont <= SEL_Cont + 1; // 4 bit counter, so it wraps at 16
        if (LRCK_1X)
            AUD_inL[~(SEL_Cont)] <= iAUD_ADCDAT;
        else
            AUD_inR[~(SEL_Cont)] <= iAUD_ADCDAT;
    end
end
assign oAUD_inL = AUD_inL;
assign oAUD_inR = AUD_inR;

// now the DAC -- output the DAC bit-stream                 
assign oAUD_DATA = (LRCK_1X) ? AUD_outL[~SEL_Cont] : AUD_outR[~SEL_Cont];

//wire [15:0]data_ready;
//wire [5:0]address;
//assign data_ready = (SEL_Cont == 15)? AUD_outL[~SEL_Cont] : 0;
//assign address = (SEL_Cont == 15)? (address + 1): address;                                                                           
//ram audio_ram
//(LRCK_1X, WE, address, data_ready, Output);																									 

// register the inputs  
always @ (negedge LRCK_1X)
begin
    AUD_outL <= iAUD_extL; 
end 
always @ (posedge LRCK_1X)
begin
    AUD_outR <= iAUD_extR; 
end 

endmodule
