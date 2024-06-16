module debounce(
    clk,
    rst,
    pb_in,
    pb_debounced
    );
    input clk;
    input rst;
    input pb_in;  // push button pause/start
    output pb_debounced;  // debounced signal
    
    reg [3:0] db_window; // debounce window
    reg pb_debounced;
    reg pb_debounced_next;
 
    always@(posedge clk)    
        if (rst) db_window <= 4'b0000;
        else     db_window <= {db_window[2:0], pb_in};
        
// value of pb_debounced_next    
    always@*
        if (db_window == 4'b1111)
            pb_debounced_next <= 1;
        else
            pb_debounced_next <= 0; 
                
//
    always@(posedge clk)
        if (rst) pb_debounced <= 1'b0;
        else     pb_debounced <= pb_debounced_next;
    
    
endmodule