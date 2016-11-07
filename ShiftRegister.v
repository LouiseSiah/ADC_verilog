module ShiftRegister
(
	//input 
	clock,
	reset,
	data_in,
	//output reg[15:0]
	data_out
);

parameter data_size = 16;

input clock;
input reset;
input data_in;
output reg[data_size-1:0]data_out;

always@(posedge clock or negedge reset)
if(!reset)
  data_out <= 0;
else
  data_out <= {data_in, data_out[data_size-1:1]};

endmodule
