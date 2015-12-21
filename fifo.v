`timescale 1ns/100ps
module fifo (input clk, input rst, input pushin, input [31:0] datain, output reg [31:0] dataout, input rd_en, output reg empty);
reg [31:0] dataout0, dataout1;
reg _full, _empty;
reg [31:0] memory [0:31];
reg [5:0] write_pointer0, write_pointer1, read_pointer1, read_pointer0;

always @(posedge clk or posedge rst)
begin
  if(rst)
  begin
    empty <= #1 1;
    dataout <= #1 0;
  end
  else
  begin
    if(rd_en) begin
    empty <= #1 _empty;
    
    dataout <= #1 (!_empty)?memory[read_pointer0[4:0]]:32'b0;
    end
  end 
end

/* ----- read & write address counters ------*/
always @(posedge clk or posedge rst)           // read & write pointers of FIFO
  begin
    if(rst)
      begin
        read_pointer0  <= #1 0;
        write_pointer0 <= #1 0;
      end
    else 
      begin
        if(pushin)
          begin
          write_pointer0 <= #1 write_pointer0 + 1;
          //memory[write_pointer0[4:0]] =  (32'h7ffffffd)?datain:32'bx;//:datain;
          memory[write_pointer0[4:0]] =  datain;
          end
        else
          write_pointer0 <= #1 write_pointer0 + 0;
        if(rd_en)
          begin
            if(_empty)
              read_pointer0 <= #1 read_pointer0 + 0;
            else
              read_pointer0 <= #1 read_pointer0 + 1;
          end
        else 
          read_pointer0 <= #1 read_pointer0;
      end
end
      
always @(*)             // Empty flag generation
begin
  if ((read_pointer0[5] == write_pointer0[5]) && (read_pointer0 == write_pointer0))
    _empty = 1;
  else
    _empty  = 0;
end	 

endmodule
