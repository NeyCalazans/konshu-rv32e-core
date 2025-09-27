//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    mux_4x1.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       mux_4x1
// Description: Verilog for a MUX 4x1
//////////////////////////////////////////////////////////////////////////////

module mux_4x1 ( 
    i_sel,
    i_a,
    i_b,
    i_c,
    i_d,
    o_mux
);

// ------------------------------------------
// IO declaration
// ------------------------------------------
    input   [1:0]       i_sel;
    input   [31:0]      i_a;
    input   [31:0]      i_b;
    input   [31:0]      i_c;
    input   [31:0]      i_d;
    
    output  reg     [31:0]      o_mux;
                                    
// ------------------------------------------
// Signals deinitions
// ------------------------------------------    
    always @(*) begin
        case (i_sel)
            2'b00: o_mux <= i_a;
            2'b01: o_mux <= i_b;
            2'b10: o_mux <= i_c;
            2'b11: o_mux <= i_d;
        endcase    
    end

endmodule
