//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    core.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    2.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       core
// Description: RISC-V RV32E processor core. Contains the control unit and the
//              datapath. Instruction and data memories are external and are
//              connected through the memory interfaces below.
////////////////////////////////////////////////////////////////////////////////
module core #(
    parameter DATA_WIDTH = 32
) (
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
    clk,
    rst,
    // instruction memory interface
    o_pc_IF,
    i_instr_IF,
    // data memory interface
    o_data_addr_M,
    o_write_data_M,
    o_mem_write_M,
    o_funct_3_M,
    i_read_data_M
);
 
    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    `ifdef USE_POWER_PINS
        inout vccd1;
        inout vssd1;
    `endif
 
    input wire clk;
    input wire rst;
 
    // instruction memory: core drives the address, memory returns the instruction
    output wire [DATA_WIDTH-1:0] o_pc_IF;
    input  wire [DATA_WIDTH-1:0] i_instr_IF;
 
    // data memory: core drives address, data and write enable; memory returns data
    output wire [DATA_WIDTH-1:0] o_data_addr_M;
    output wire [DATA_WIDTH-1:0] o_write_data_M;
    output wire                  o_mem_write_M;
    output wire [2:0]            o_funct_3_M;
    input  wire [DATA_WIDTH-1:0] i_read_data_M;
 
    // ------------------------------------------
    // Internal wires: control unit <-> datapath
    // ------------------------------------------
 
    // decoded instruction fields, produced by the datapath
    wire [4:0] op;
    wire [2:0] funct3;
    wire       funct_7_5;
 
    // flags produced by the datapath, consumed by the control unit
    wire zero;
    wire branch_EX;
    wire addr_src_EX;
    wire jump_EX;
 
    // control signals produced by the control unit
    wire [1:0] pc_src_EX;
    wire       jump_ID;
    wire       branch_ID;
    wire       addr_src_ID;
    wire       reg_write_ID;
    wire [1:0] result_src_ID;
    wire       mem_write_ID;
    wire       alu_src_ID;
    wire [2:0] imm_src_ID;
    wire [4:0] alu_ctrl_ID;
 
    // ------------------------------------------
    // Control Unit
    // ------------------------------------------

    control_unit U_CONTROL_UNIT (
        .i_op           (op),
        .i_funct_3      (funct3),
        .i_funct_7_5    (funct_7_5),
        .i_zero         (zero),
        .i_branch_EX    (branch_EX),
        .i_addr_src_EX  (addr_src_EX),
        .i_jump_EX      (jump_EX),
        .o_pc_src_EX    (pc_src_EX),
        .o_jump_ID      (jump_ID),
        .o_branch_ID    (branch_ID),
        .o_addr_src_ID  (addr_src_ID),
        .o_reg_write_ID (reg_write_ID),
        .o_result_src_ID(result_src_ID),
        .o_mem_write_ID (mem_write_ID),
        .o_alu_src_ID   (alu_src_ID),
        .o_imm_src_ID   (imm_src_ID),
        .o_alu_ctrl_ID  (alu_ctrl_ID)
    );
 
    // ------------------------------------------
    // Datapath
    // ------------------------------------------
    
    datapath #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U_DATAPATH (
        .clk            (clk),
        .rst            (rst),
        .i_pc_src_EX    (pc_src_EX),
        .i_jump_ID      (jump_ID),
        .i_branch_ID    (branch_ID),
        .i_addr_src_ID  (addr_src_ID),
        .i_reg_write_ID (reg_write_ID),
        .i_result_src_ID(result_src_ID),
        .i_mem_write_ID (mem_write_ID),
        .i_alu_ctrl_ID  (alu_ctrl_ID),
        .i_alu_src_ID   (alu_src_ID),
        .i_imm_src_ID   (imm_src_ID),
        .i_instr_IF     (i_instr_IF),
        .i_read_data_M  (i_read_data_M),
        .o_jump_EX      (jump_EX),
        .o_branch_EX    (branch_EX),
        .o_addr_src_EX  (addr_src_EX),
        .o_zero         (zero),
        .o_mem_write_M  (o_mem_write_M),
        .o_write_data_M (o_write_data_M),
        .o_data_addr_M  (o_data_addr_M),
        .o_funct_3_M    (o_funct_3_M),
        .o_op           (op),
        .o_funct3       (funct3),
        .o_funct_7_5    (funct_7_5),
        .o_pc_IF        (o_pc_IF)
    );
 
endmodule
