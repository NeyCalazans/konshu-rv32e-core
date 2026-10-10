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

module stage_fetch #(
    parameter DATA_WIDTH = 32
) (
    clk,
    rst,
    i_pc_target_EX,
    i_alu_result_EX,
    i_pc_src_EX,
    i_stall_IF,
    o_pcplus4_IF,
    o_pc_IF
);
    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire                  clk;
    input wire                  rst;
    input wire [DATA_WIDTH-1:0] i_pc_target_EX;
    input wire [DATA_WIDTH-1:0] i_alu_result_EX;
    input wire [1:0]            i_pc_src_EX;
    input wire                  i_stall_IF;

    output wire [DATA_WIDTH-1:0] o_pc_IF;
    output wire [DATA_WIDTH-1:0] o_pcplus4_IF;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    next_pc U_NEXT_PC (
        .clk             (clk),
        .rst             (rst),
        .i_pc_target_EX  (i_pc_target_EX),
        .i_pc_src_EX     (i_pc_src_EX),
        .i_alu_result_EX (i_alu_result_EX),
        .i_stall_IF      (i_stall_IF),
        .o_pcplus4_IF    (o_pcplus4_IF),
        .o_pc_IF         (o_pc_IF)
    );

endmodule
