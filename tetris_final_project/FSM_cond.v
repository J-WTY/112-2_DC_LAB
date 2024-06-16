`define PRE 2'b00
`define DRO 2'b01
`define DEL 2'b10
`define END 2'b11

module FSM_cond (
    input clk, rst,
    input start,
    input del_to_dro,
    input touch,
    input game_over,
    output reg [1:0] state
);

reg [1:0] next_state = 2'b00;

always@*
case (state)
    `PRE:
        if (start)           next_state = `DEL;
        else                 next_state = `PRE;
    `DRO:
        if (game_over)       next_state = `END;
        else if (start)      next_state = `PRE;
        else if (touch)      next_state = `DEL;
        else                 next_state = `DRO;
    `DEL:
        if (game_over)       next_state = `END;
        else if (start)      next_state = `PRE;
        else if (del_to_dro) next_state = `DRO;      
        else                 next_state = `DEL;
    `END:
        if (start)           next_state = `PRE;
        else                 next_state = `END;
endcase

always@(posedge clk)
    if (rst)    state <= 2'b00;
    else        state <= next_state;

endmodule