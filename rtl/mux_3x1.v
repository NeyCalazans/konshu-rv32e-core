//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    mux_3x1.v
// Date:        02.11.2024
// Reviewer:    Luis Spader
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       mux_3x1
// Description: Verilog for a MUX 3x1
//////////////////////////////////////////////////////////////////////////////

module mux_3x1 #(
    parameter DATA_WIDTH = 32
) (
    i_sel,
    i_a,
    i_b,
    i_c,
    o_mux
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input [1:0] i_sel;
    input [DATA_WIDTH-1:0] i_a;
    input [DATA_WIDTH-1:0] i_b;
    input [DATA_WIDTH-1:0] i_c;

    output  reg [31:0] o_mux;

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------    
    always @(*) begin
        case (i_sel)
            2'b00:   o_mux = i_a;
            2'b01:   o_mux = i_b;
            2'b10:   o_mux = i_c;
            default: o_mux = i_a;
        endcase
    end

endmodule
