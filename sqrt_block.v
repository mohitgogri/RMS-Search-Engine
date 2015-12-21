`timescale 1ns/10ps

module sqrt_block (clk, rst, pushin, datain, squarein, rootin, remainderin, pushout, rootout, remainderout, dataout, squareout);

input clk, rst, pushin;
input [63:0] datain, squarein;
input [31:0] rootin, remainderin;
output reg pushout;
output reg [63:0] dataout, squareout;
output reg [31:0] rootout, remainderout;

reg [31:0] _root, _remainder;
reg [63:0] _datain;
always @(*)
  begin
    _root = rootin;
    _root = _root << 1;
    _remainder = ((remainderin<<2)+(datain>>62));
    _datain  = datain << 2;
    _root = _root + 1;
    if(_root <= _remainder)
      begin
        _remainder = _remainder - _root;
        _root = _root + 1;
      end
    else
      begin
        _root = _root - 1;
      end
  end
  
  always @(posedge clk or posedge rst)
begin
  if(rst)
    begin
      dataout      <= #1 0;
      rootout      <= #1 0; 
      pushout      <= #1 0;
      remainderout <= #1 0;
      squareout    <= #1 0;
    end
  else
    begin
      dataout      <= #1 _datain;
      rootout      <= #1 _root;
      pushout      <= #1 pushin;
      remainderout <= #1 _remainder;
      squareout    <= #1 squarein;
      end
end

endmodule
  