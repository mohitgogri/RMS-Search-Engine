`timescale 1ns/10ps
//`include "controller.v"
//`include "divide_block_main.v"
//`include "sqrt_block_main.v"
//`include "fifo.v"
module rms(clk,rst,pushin,cmdin,Xin,pullout,stopout,Xout); 
input clk,rst;
input pushin;
input [1:0] cmdin;
input [31:0] Xin;
input pullout;
output stopout;
output [31:0] Xout;

wire pushout1, pushout3;
reg pushout2;
wire [71:0] dataout;
wire [9:0] counter;
reg [63:0] square;
reg [31:0] root;

wire [71:0] A_in [70:0];
wire [71:0] Q_in [70:0];
wire [9:0] M [70:0];
wire _pushin [70: 0] ;
wire [71:0] A_in1, A_in5, _Quotient;
wire [9:0] M5;
wire [71:0] _divisor;

integer w, w0; 
reg [63:0] _datain, squared;
reg  _pushout, pushout;
reg [31:0] remainder;

reg [31:0] _guessfinal, _guessfinal1, _guessfinald, _guessfinal1d, _rootfinal, _guess;
wire [63:0] _data [0:32];
wire [31:0] _root [0:32];
wire [31:0] _remainder [0:32];
wire [63:0] _square [0:32];
wire _push [0:32];

reg signed [143:0] A_Q_temp, A_Q_out, A_Q_outd;
reg signed [71:0] A_temp;

genvar i,j;

reg [1:0] cmd0, cmd1;
reg signed [63:0] y, yd;
reg signed [71:0] acc;
reg [9:0] counter_d, _counter, _counter2, _counter2d;
reg pushout_d, push0, push1, _pushoutd;
reg signed [71:0] acc_d, acc_d2;
reg [71:0] dout, dout_d;

assign dataout = dout;
assign counter = _counter2d;
assign pushout1 = _pushoutd;

always @(posedge clk or posedge rst)
  begin
    if (rst)
     begin 
       w0    <= #1 0;
       cmd0  <= #1 0;
       push0 <= #1 0;
     end
    else
      begin
       w0    <= #1 Xin;
       cmd0  <= #1 cmdin;
       push0 <= #1 pushin;
      end
  end
  
DW02_mult #(32,32) m1 (w0,w0,{1'b1},y); 
/*always @(*)
begin
  y = 0;
  if(push0)
  y = w0*w0;
end
*/
always @(posedge clk or posedge rst)
  begin
    if (rst)
     begin 
       yd  <= #1 0;
       cmd1  <= #1 0;
       push1 <= #1 0;
     end
    else
      begin
       yd  <= #1 y;
       cmd1  <= #1 cmd0;
       push1 <= #1 push0;
      end
  end



always @(*)
begin

acc_d=acc;
dout_d=dout;
counter_d=_counter;
pushout_d= 0;
_counter2 = 0;
if(push1) begin	    
case (cmd1)
	0: begin
	   acc_d     = yd + acc;
	   counter_d = _counter+1;
	   end
	1: begin
	   acc_d      =acc-yd;
	   counter_d  =_counter -1;
	   end
	2: begin
	   acc_d     = (yd)+acc;
	   dout_d    = acc_d;
	   counter_d = _counter + 1;
	   _counter2 = _counter + 1;
	   pushout_d = 1;
	   end
	3: begin
	   acc_d     = 0;
	   counter_d = 0;
	   _counter2  = _counter + 1;
 	   dout_d    = (yd) + acc;
	   pushout_d = 1;
	   end
	   endcase
	   end
end


always @(posedge clk or posedge rst)
  begin
    if (rst)
      begin 
        acc        <= #1 0;
        dout       <= #1 0;
        _counter   <= #1 0;
        _pushoutd   <= #1 0;
        _counter2d <= #1 0;
      end
    else
      begin
        acc        <= #1 acc_d;
        dout       <= #1 dout_d;
        _pushoutd   <= #1 pushout_d;
        _counter   <= #1 counter_d;
        _counter2d <= #1 _counter2;

end
end


//controller a1 (clk, rst, pushin, Xin, cmdin, dataout, counter, pushout1);

/*---------------------------------------------------------------------------------------------------------------------*/

divide_block startblock (clk, rst, pushout1,  {72'b0}, dataout,  counter,  M[0],  _pushin[0],  A_in[0],  Q_in[0]);

generate
  for (i=0; i < 70; i = i + 1)
    begin:m
      divide_block U (clk, rst, _pushin[i], A_in[i], Q_in[i], M[i], M[i+1], _pushin[i+1], A_in[i+1], Q_in[i+1]);
    end
endgenerate

//divide_block endblock (clk, rst, _pushin[70],  A_in[70],  Q_in[70],  M[70],  M5,  pushout2,  A_in5, square);// _Quotient);

always @(*)
begin
  A_Q_out = 0;
  A_Q_temp = {A_in[70], Q_in[70]} << 1;
  A_temp = A_Q_temp[143:72] - M[70];
  if (A_temp[71] == 1)
    begin
      A_Q_out = {A_Q_temp[143:1],1'b0};
    end
  else
    begin
      A_Q_out = {A_temp,A_Q_temp[71:1],1'b1};
    end
end

always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
      square <= #1 0;
      pushout2 <= #1 0;
    end
  else
    begin
        square <= #1 A_Q_out[71:0];
        pushout2 <= #1 _pushin[70];
   end
end

/*---------------------------------------------------------------------------------------------------------------------*/

//sqrt_block_main a3 (clk, rst, square, root, pushout2, pushout3);


assign _data[0] = square;
assign _push[0] = pushout2;
assign _root[0] = 0;
assign _remainder[0] = 0;
assign _square[0] = square;


generate
   for (j = 0; j < 32 ; j = j + 1) 
   begin: n
     sqrt_block a (clk, rst, _push[j], _data[j], _square[j], _root[j], _remainder[j], _push[j+1], _root[j+1], _remainder[j+1], _data[j+1], _square[j+1]);
   end
endgenerate

always @(*)
begin
  _guessfinal = (_root[32]>>1);
  _guessfinal1 = _guessfinal + 1 ; //(_root[32]>>1) + 1;
end  

always @(posedge clk or posedge rst)
begin
 if(rst)
   begin
     _guessfinald <= #1 0;
    _pushout      <= #1 0;
    _guessfinal1d <= #1 0;
    squared        <= #1 0;
   end
  else
    begin
      _pushout      <= #1 _push[32];
      _guessfinald  <= #1 _guessfinal;
      _guessfinal1d <= #1 _guessfinal1;
      squared        <= #1 _square[32];
    end
end

always @(*)
begin
  _rootfinal = 0;
  if (squared > (_guessfinal1d * _guessfinal1d))
    begin
      _rootfinal = _guessfinal1d;// + 1;
    end
  else 
      _rootfinal = _guessfinald;
  //if(_rootfinal==32'h7ffffffd)
   // _rootfinal = 32'bx;
  end
  
always @(posedge clk or posedge rst)
begin
 if(rst)
   begin
     pushout <= #1 0;
     root    <= #1 0;
   end
  else
    begin
      pushout <= #1 _pushout;
      root    <= #1 _rootfinal;
    end
end

fifo a4 (clk, rst, pushout, root, Xout, pullout, stopout);

endmodule
