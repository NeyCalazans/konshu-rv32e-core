module mux_2x1 #(parameter DATA_WIDTH = 32) (
    input  wire                    i_sel,   // Select signal
    input  wire [DATA_WIDTH-1:0]   i_a,     // Input A
    input  wire [DATA_WIDTH-1:0]   i_b,     // Input B
    output wire [DATA_WIDTH-1:0]   o_mux    // Output
);

    // Multiplexer logic
    assign o_mux = (i_sel) ? i_b : i_a;

endmodule
