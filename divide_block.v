`timescale 1ns/10ps

module divide_block (clk, rst, pushin, A_in, Q_in, M_in, M_out, pushout, A_out, Q_out);
input clk, rst, pushin;
input [71:0] A_in, Q_in;
input [9:0] M_in;
output reg [71:0] A_out, Q_out;
output reg [9:0] M_out;
output reg pushout;

reg signed [143:0] A_Q_temp, A_Q_out, A_Q_outd;
reg signed [71:0] A_temp;
always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
      A_out <= #1 0;
      Q_out <= #1 0;
      M_out <= #1 0;
      pushout <= #1 0;
      A_Q_outd <= #1 0;
    end
  else
    begin
        A_out <= #1 A_Q_out[143: 72];
        Q_out <= #1 A_Q_out[71:0];
        M_out <= #1 M_in;
        pushout <= #1 pushin;
end
end

always @(*)
begin
  A_Q_out = 0;
  A_Q_temp = {A_in, Q_in} << 1;
 // A_Q_temp = A_Q_temp << 1;
  A_temp = A_Q_temp[143:72] - M_in;
  if (A_temp[71] == 1)
    begin
      A_Q_out = {A_Q_temp[143:1],1'b0};
    end
  else
    begin
      A_Q_out = {A_temp,A_Q_temp[71:1],1'b1};
    end
end
endmodule
