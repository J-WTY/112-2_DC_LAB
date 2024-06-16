`include "global.v"
`timescale 1ns / 1ps

module voice_gen(
    clk, clk_25MHz, rst, mclk, lrclk, sclk, audio_sdin, get, state, addr_copy_tmp
    );
    input clk, rst, clk_25MHz;
    input [2:0] get;
    input [1:0] state;
    input [9:0] addr_copy_tmp;
    output mclk, lrclk, sclk, audio_sdin;
    wire [15:0] audio_left, audio_right;
    reg [21:0] note_div;
    reg new_line_clear;
    reg [3:0] count;
    reg [3:0] count_temp;
    reg load;
    wire clk_1HZ;
    
    buzzercontrol Ubuz( .clk(clk), .rst(rst), .audio_left(audio_left), .audio_right(audio_right), .note_div(note_div));
    speakercontrol Uspeaker(.clk(clk), .rst_n(rst), .audio_left(audio_left), .audio_right(audio_right),
    .audio_sdin(audio_sdin), .mclk(mclk), .lrclk(lrclk), .sclk(sclk));
    clock_1HZ U2 (.clk(clk), .rst(rst), .clk_out(clk_1HZ));
             
    always@*
        if ((state == `DEL) && (addr_copy_tmp == 100))
            load = 1;
        else
            load = 0;
    always@*
        if (rst)
            count_temp = 0;
        else if (get != 0)
            count_temp = count + 1;
        else if ((state == `DEL) && (addr_copy_tmp == 100))
            count_temp = 0;
        else
            count_temp = count;
    always@(posedge clk_25MHz or posedge rst) // 1HZ
        if (rst)
            count <= 0;
        else
            count <= count_temp;     
    always@(posedge clk_1HZ or posedge load) // 1 HZ
    if (load)
    case(count)
        4'b0: note_div <= 0;
        4'd1: note_div <= (100000000/261/2);
        4'd2: note_div <= (100000000/294/2);
        4'd3: note_div <= (100000000/330/2);
        4'd4: note_div <= (100000000/349/2);
        4'd5: note_div <= (100000000/392/2);
        4'd6: note_div <= (100000000/440/2);
        4'd7: note_div <= (100000000/494/2);
        4'd8: note_div <= (100000000/524/2);
        4'd9: note_div <= (100000000/588/2);
        4'd10: note_div <= (100000000/660/2);
        default: note_div <= (100000000/698/2); endcase
    else     
        note_div <= 0;
            
endmodule