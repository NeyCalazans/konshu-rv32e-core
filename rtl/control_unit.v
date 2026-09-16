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
    i_addr_src_EX,
    o_pc_src_EX,
    o_jump_ID,
    o_branch_ID,
    o_reg_write_ID,
    o_result_src_ID,
    o_mem_write_ID,
    o_alu_src_ID,
    o_imm_src_ID,
    o_alu_ctrl_ID,
    o_addr_src_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [4:0] i_op;
    input wire [2:0] i_funct_3;
    input wire       i_funct_7_5;
    input wire       i_zero;
    input wire       i_addr_src_EX;
    input wire       i_branch_EX;
    input wire       i_jump_EX;

    output wire [1:0] o_pc_src_EX;
    output wire       o_jump_ID;
    output wire       o_branch_ID;
    output wire       o_reg_write_ID;
    output wire [1:0] o_result_src_ID;
    output wire       o_mem_write_ID;
    output wire [4:0] o_alu_ctrl_ID;
    output wire       o_alu_src_ID;
    output wire       o_addr_src_ID;
    output wire [2:0] o_imm_src_ID;

    // ------------------------------------------
    // Signals
    // ------------------------------------------
    
    wire [2:0] alu_op;

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
        .o_addr_src_ID(o_addr_src_ID)
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

    assign o_pc_src_EX = {i_addr_src_EX, ((i_zero && i_branch_EX) || i_jump_EX)};

endmodule
