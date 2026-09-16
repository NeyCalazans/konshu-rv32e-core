module mux_2x1 #(
    parameter DATA_WIDTH = 32
) (
    i_sel,  
    i_a,    
    i_b,   
    o_mux  
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input  wire                    i_sel;   
    input  wire [DATA_WIDTH-1:0]   i_a;     
    input  wire [DATA_WIDTH-1:0]   i_b;  
    
    output wire [DATA_WIDTH-1:0]   o_mux; 

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign o_mux = (i_sel) ? i_b : i_a;

endmodule
