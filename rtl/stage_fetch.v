//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    stage_fetch.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       stage_fetch
// Description: Calculate the address for the next intruction to be fetched from
//              instruction memory
//////////////////////////////////////////////////////////////////////////////

// `include "./next_pc/next_pc.v"

module stage_fetch #(
    parameter DATA_WIDTH = 32
) (
    clk,
    i_pc_target_EX,
    i_pc_src_EX,
    i_rst_IF,
    i_en_IF,
    o_pcplus4_IF,
    o_pc_IF
);
    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic clk;
    input logic [DATA_WIDTH-1:0] i_pc_target_EX;
    input logic i_pc_src_EX;
    input logic i_rst_IF;
    input logic i_en_IF;

    output  reg [DATA_WIDTH-1:0] o_pc_IF;
    output  reg [DATA_WIDTH-1:0] o_pcplus4_IF;


    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    next_pc U_NEXT_PC (
        .clk           (clk),
        .i_pc_target_EX(i_pc_target_EX),
        .i_pc_src_EX   (i_pc_src_EX),
        .i_rst_IF      (i_rst_IF),
        .i_en_IF       (i_en_IF),
        .o_pcplus4_IF  (o_pcplus4_IF),
        .o_pc_IF       (o_pc_IF)
    );

endmodule
