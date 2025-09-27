//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2024 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    stage_execute.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       stage_execute
// Description: This file describes the Decoder stage which is composed by the 
//              extend_unit and the register_file.
//////////////////////////////////////////////////////////////////////////////

module stage_execute #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 4
) (
    i_rd1_EX,
    i_rd2_EX,
    i_pc_EX,
    i_imm_ext_EX,
    i_alu_src_EX,
    i_result_WB,
    i_alu_result_M,
    i_forward_rs1_EX,
    i_forward_rs2_EX,
    i_alu_ctrl_EX,
    o_equal_EX,
    o_alu_result_EX,
    o_write_data_EX,
    o_pc_target_EX
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input i_alu_src_EX;
    input [DATA_WIDTH-1:0] i_rd1_EX;
    input [DATA_WIDTH-1:0] i_rd2_EX;
    input [DATA_WIDTH-1:0] i_pc_EX;
    input [DATA_WIDTH-1:0] i_imm_ext_EX;
    input [DATA_WIDTH-1:0] i_result_WB;
    input [DATA_WIDTH-1:0] i_alu_result_M;
    input [1:0] i_forward_rs1_EX;
    input [1:0] i_forward_rs2_EX;
    input [4:0] i_alu_ctrl_EX;

    output o_equal_EX;
    output [DATA_WIDTH-1:0] o_alu_result_EX;
    output [DATA_WIDTH-1:0] o_write_data_EX;
    output [DATA_WIDTH-1:0] o_pc_target_EX;

    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------
    wire [DATA_WIDTH-1:0] srcA_EX;
    wire [DATA_WIDTH-1:0] srcB_EX;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    pc_target U_PC_TARGET (
        .i_pc_EX(i_pc_EX),
        .i_imm_ext_EX(i_imm_ext_EX),
        .o_pc_target_EX(o_pc_target_EX)
    );

    alu #(
        .WIDTH(DATA_WIDTH)
    ) U_ALU (
        .i_alu_ctrl_EX(i_alu_ctrl_EX),
        .i_rd1_EX(srcA_EX),
        .i_rd2_EX(srcB_EX),
        .o_alu_result_EX(o_alu_result_EX),
        .o_equal_EX(o_equal_EX)
    );

    mux_3x1 U_MUX_3X1 (
        .i_sel(i_forward_rs1_EX),
        .i_a  (i_rd1_EX),
        .i_b  (i_result_WB),
        .i_c  (i_alu_result_M),
        .o_mux(srcA_EX)
    );

    mux_3x1 U2_MUX_3X1 (
        .i_sel(i_forward_rs2_EX),
        .i_a  (i_rd2_EX),
        .i_b  (i_result_WB),
        .i_c  (i_alu_result_M),
        .o_mux(o_write_data_EX)
    );

    mux_2x1 U_MUX_2X1 (
        .i_sel(i_alu_src_EX),
        .i_a  (o_write_data_EX),
        .i_b  (i_imm_ext_EX),
        .o_mux(srcB_EX)
    );

endmodule
