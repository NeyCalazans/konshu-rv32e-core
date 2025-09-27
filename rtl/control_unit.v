//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    control_unit.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       control_unit
// Description: Verilog module control_unit is responsible for integrate the 
//              opcode decoder and the ALU decoder in order to become de complete
//              control unit. 
////////////////////////////////////////////////////////////////////////////////
// `include "./op_decoder/op_decoder.v"
// `include "./alu_decoder/alu_decoder.v"
module control_unit (
    i_op,
    i_funct_3,
    i_funct_7_5,
    i_branch_EX,
    i_jump_EX,
    i_zero,
    o_pc_src_EX,
    o_jump_ID,
    o_branch_ID,
    o_reg_write_ID,
    o_result_src_ID,
    o_mem_write_ID,
    o_alu_src_ID,
    o_imm_src_ID,
    o_alu_ctrl_ID,
    o_addr_src_ID,
    o_fence_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic [4:0] i_op;
    input logic [2:0] i_funct_3;
    input logic i_funct_7_5;
    input logic i_zero, i_branch_EX, i_jump_EX;

    output logic o_pc_src_EX;
    output logic o_jump_ID;
    output logic o_branch_ID;
    output logic o_reg_write_ID;
    output logic [1:0] o_result_src_ID;
    output logic o_mem_write_ID;
    output logic [4:0] o_alu_ctrl_ID;
    output logic o_alu_src_ID;
    output logic o_addr_src_ID;
    output logic [2:0] o_imm_src_ID;
    output logic o_fence_ID;

    // ------------------------------------------
    // Signals
    // ------------------------------------------
    logic [2:0] alu_op;

    // ------------------------------------------
    // Instantiating op_decoder module
    // ------------------------------------------

    op_decoder U_OP_DECODER (
        .i_op(i_op),
        .i_funct_3(i_funct_3),
        .i_funct_7_5(i_funct_7_5),
        .o_jump_ID(o_jump_ID),
        .o_branch_ID(o_branch_ID),
        .o_reg_write_ID(o_reg_write_ID),
        .o_result_src_ID(o_result_src_ID),
        .o_mem_write_ID(o_mem_write_ID),
        .o_alu_src_ID(o_alu_src_ID),
        .o_imm_src_ID(o_imm_src_ID),
        .o_alu_op(alu_op),
        .o_addr_src_ID(o_addr_src_ID),
        .o_fence_ID(o_fence_ID)
    );

    // ------------------------------------------
    // Instantiating alu_decoder module
    // ------------------------------------------

    alu_decoder U_ALU_DECODER (
        .i_alu_op(alu_op),
        .i_funct_3(i_funct_3),
        .i_funct_7_5(i_funct_7_5),
        .o_alu_ctrl_ID(o_alu_ctrl_ID)
    );

    assign o_pc_src_EX = ((i_zero && i_branch_EX) || i_jump_EX) ? 1'b1 : 1'b0;

endmodule
