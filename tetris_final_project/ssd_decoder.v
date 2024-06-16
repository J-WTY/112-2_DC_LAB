`define SS_0  8'b00000011
`define SS_1  8'b10011111
`define SS_2  8'b00100101
`define SS_3  8'b00001101
`define SS_4  8'b10011001
`define SS_5  8'b01001001
`define SS_6  8'b01000001
`define SS_7  8'b00011111
`define SS_8  8'b00000001
`define SS_9  8'b00001001

module ssd_decoder (
    input [3:0] out,
    output reg [7:0] ssd_out
);
    
always @*
    case(out)
      4'd0: ssd_out = `SS_0;
      4'd1: ssd_out = `SS_1;
      4'd2: ssd_out = `SS_2;
      4'd3: ssd_out = `SS_3;
      4'd4: ssd_out = `SS_4;
      4'd5: ssd_out = `SS_5;
      4'd6: ssd_out = `SS_6;
      4'd7: ssd_out = `SS_7;
      4'd8: ssd_out = `SS_8;
      4'd9: ssd_out = `SS_9;
      default: ssd_out = 8'b11111111;
    endcase
endmodule    