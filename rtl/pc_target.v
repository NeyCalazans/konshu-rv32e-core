//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    pc_target.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       pc_target
// Description: Verilog for PC Target block. It is reponsible for incrementing 
//              the PC target with the value from the Extended Unit (32bit).
//////////////////////////////////////////////////////////////////////////////

module pc_target #(
    parameter WIDTH = 32) 
(
    i_pc_EX,
    i_imm_ext_EX,
    o_pc_target_EX
);

// ------------------------------------------
// IO declaration
// ------------------------------------------
    input   logic   [WIDTH-1:0]   i_pc_EX;
    input   logic   [WIDTH-1:0]   i_imm_ext_EX;

    output  logic   [WIDTH-1:0]  o_pc_target_EX;
                            
// ------------------------------------------
// Signals deinitions
// ------------------------------------------

// ------------------------------------------
// Logic
// ------------------------------------------
    assign o_pc_target_EX = i_pc_EX + i_imm_ext_EX;

endmodule
