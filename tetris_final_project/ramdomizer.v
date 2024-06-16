`include "global.v"




`timescale 1ns / 1ps

module randomizer (
  input clk,
  input [7:0] seed,
  input del_to_dro,
  output reg [2:0] tetris
);

reg [7:0] LFSR;

reg init = 1'b1;

assign LFSR_out = LFSR;

wire feedback = LFSR[7];

always @(posedge clk)
begin
  if (init) begin
    LFSR <= seed;
    init <= 1'b0;
  end
  else begin
    LFSR[0] <= feedback;
    LFSR[1] <= LFSR[0];
    LFSR[2] <= LFSR[1] ^ feedback;
    LFSR[3] <= LFSR[2] ^ feedback;
    LFSR[4] <= LFSR[3] ^ feedback;
    LFSR[5] <= LFSR[4];
    LFSR[6] <= LFSR[5];
    LFSR[7] <= LFSR[6];
  end
end

reg [2:0] rand_bits = 8'hFF;
wire [2:0] tetris_tmp;
always @(posedge clk) rand_bits <= {rand_bits[1:0], LFSR[3]};
assign tetris_tmp = (rand_bits[2:0] == 3'b000) ? `I_BLOCK : rand_bits[2:0];
always@(posedge del_to_dro)
    tetris <= tetris_tmp;
endmodule