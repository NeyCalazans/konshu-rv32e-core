//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    stage_decode.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       stage_decode
// Description: This file describes the Decoder stage which is composed by the 
//              extend_unit and the register_file.
//////////////////////////////////////////////////////////////////////////////

// `include "./extend_unit/extend_unit.v"
// `include "./register_file/register_file.v"

module stage_decode (
    clk,
    i_rst_ID,
    i_instr_ID,
    i_data_WB,
    i_rd_WB,
    i_write_en_WB,
    i_imm_src_ID,
    o_op,
    o_funct3,
    o_funct_7_5,
    o_rd_ID,
    o_rs1_ID,
    o_rs2_ID,
    o_rs1Addr_ID,
    o_rs2Addr_ID,
    o_imm_ex_ID
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input wire clk;  // Clock input
    input wire i_rst_ID;  // Reset input for regiser file
    input wire [3:0] i_rd_WB;  // register to perform the write
    input wire [31:0] i_instr_ID;  // Instruction ID input
    input wire [31:0] i_data_WB;  // data to write in a register
    input wire i_write_en_WB;  // ennable write operation in register file
    input wire [2:0] i_imm_src_ID;  // 3 bits for choose which immediate extension

    output wire o_funct_7_5;  // Bit 5 for func7 field   
    output wire [4:0] o_op;  // Opcode
    output wire [2:0] o_funct3;  // Field func3
    output wire [3:0] o_rd_ID;  //
    output wire [3:0] o_rs1Addr_ID;  // goes to Hazard unit
    output wire [3:0] o_rs2Addr_ID;  // goes to Hazard unit
    output wire [31:0] o_rs1_ID;  // rs1 register content
    output wire [31:0] o_rs2_ID;  // rs2 register content
    output wire [31:0] o_imm_ex_ID;  // Immediate with sign extended                                

    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    extend_unit U_EXTEND_UNIT (
        .i_imm_ID(i_instr_ID[31:7]),
        .i_imm_src_ID(i_imm_src_ID),
        .o_imm_ex_ID(o_imm_ex_ID)
    );

    register_file #(
        .DATA_WIDTH(32),
        .NUM_REGS(16),
        .INDEX_WIDTH(4)
    ) U_REGISTER_FILE (
        .clk(clk),
        .i_rst_ID(i_rst_ID),
        .i_write_en_WB(i_write_en_WB),
        .i_data_WB(i_data_WB),
        .i_rd_WB(i_rd_WB),
        .i_instr_ID(i_instr_ID),
        .o_rs1_ID(o_rs1_ID),
        .o_rs2_ID(o_rs2_ID)
    );

    assign o_op = i_instr_ID[6:2];
    assign o_funct3 = i_instr_ID[14:12];
    assign o_funct_7_5 = i_instr_ID[30];
    assign o_rd_ID = i_instr_ID[10:7];

    assign o_rs1Addr_ID = i_instr_ID[18:15];
    assign o_rs2Addr_ID = i_instr_ID[23:20];


endmodule
