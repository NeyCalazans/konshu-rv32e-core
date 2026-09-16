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
// Description: This file describes the Datapath which will include all the 
//              pipeline registers, the hazard unit, and the 5 modules that 
//              compose the code (stage_fetch, stage_decode, stage_execute,
//              stage_write_back)
//////////////////////////////////////////////////////////////////////////////
// import package::*;
// `include "./MODULE_DECODE/stage_decode.v"
// `include "./MODULE_EXECUTE/stage_execute.v"
// `include "./MODULE_FETCH/stage_fetch.v"
// `include "./MODULE_WRITEBACK/*.v"
// `include "./MODULE_HAZARDUNIT/hazard_unit.v"
// `include "./MODULE_PIPELINE/*.v"

module datapath #(
    parameter DATA_WIDTH = 32
) (
    clk,
    rst,
    i_pc_src_EX,
    i_jump_ID,
    i_branch_ID,
    i_reg_write_ID,
    i_result_src_ID,
    i_mem_write_ID,
    i_alu_ctrl_ID,
    i_alu_src_ID,
    i_addr_src_ID,
    i_imm_src_ID,
    i_instr_IF,
    i_read_data_M,

    o_jump_EX,
    o_branch_EX,
    o_addr_src_EX,
    o_zero,
    o_mem_write_M,
    o_write_data_M,
    o_data_addr_M,
    o_funct_3_M,
    o_op,
    o_funct3,
    o_funct_7_5,
    o_pc_IF
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input wire                  clk;
    input wire                  rst;
    input wire [1:0]            i_pc_src_EX;
    input wire                  i_jump_ID;
    input wire                  i_branch_ID;
    input wire                  i_reg_write_ID;
    input wire [1:0]            i_result_src_ID;
    input wire                  i_mem_write_ID;
    input wire [4:0]            i_alu_ctrl_ID;
    input wire                  i_alu_src_ID;
    input wire                  i_addr_src_ID;
    input wire [2:0]            i_imm_src_ID;
    input wire [DATA_WIDTH-1:0] i_instr_IF;
    input wire [DATA_WIDTH-1:0] i_read_data_M;

    output wire                  o_jump_EX;
    output wire                  o_branch_EX;
    output wire                  o_addr_src_EX;
    output wire                  o_zero;
    output wire                  o_mem_write_M;
    output wire [DATA_WIDTH-1:0] o_write_data_M;
    output wire [DATA_WIDTH-1:0] o_data_addr_M;
    output wire [2:0]            o_funct_3_M;
    output wire [4:0]            o_op;
    output wire [2:0]            o_funct3;
    output wire                  o_funct_7_5;
    output wire [DATA_WIDTH-1:0] o_pc_IF;

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------

    // Where is this from?
    wire mem_write_WB;

    // IF
    wire [DATA_WIDTH-1:0] pcplus4_IF;
    wire                  stall_IF;

    // ID
    wire [DATA_WIDTH-1:0] pc_ID;
    wire [DATA_WIDTH-1:0] instr_ID; 
    wire [DATA_WIDTH-1:0] pcplus4_ID;
    wire [DATA_WIDTH-1:0] imm_ex_ID;
    wire [DATA_WIDTH-1:0] rs1_ID;
    wire [DATA_WIDTH-1:0] rs2_ID;
    wire                  flush_ID;
    wire                  stall_ID;
    wire [3:0]            rs1Addr_ID;
    wire [3:0]            rs2Addr_ID;
    wire [3:0]            rd_ID;

    // EX
    wire [DATA_WIDTH-1:0] pc_EX; 
    wire [DATA_WIDTH-1:0] pcplus4_EX;
    wire [DATA_WIDTH-1:0] pc_target_EX;
    wire [DATA_WIDTH-1:0] imm_ext_EX; 
    wire [DATA_WIDTH-1:0] rs1_EX; 
    wire [DATA_WIDTH-1:0] rs2_EX;
    wire [DATA_WIDTH-1:0] alu_result_EX;
    wire [DATA_WIDTH-1:0] write_data_EX;
    wire [3:0]            rs1Addr_EX; 
    wire [3:0]            rs2Addr_EX;
    wire [3:0]            rd_EX;
    wire [4:0]            alu_ctrl_EX;
    wire [1:0]            result_src_EX;
    wire                  reg_write_EX;
    wire                  mem_write_EX; 
    wire                  alu_src_EX;
    wire                  flush_EX;
    wire [1:0]            forward_rs1_EX;
    wire [1:0]            forward_rs2_EX;
    wire [2:0]            funct_3_EX;

    // MEM
    wire [DATA_WIDTH-1:0] alu_result_M;
    wire [DATA_WIDTH-1:0] write_data_M;
    wire [DATA_WIDTH-1:0] pcplus4_M;
    wire [DATA_WIDTH-1:0] pc_target_M;
    wire [DATA_WIDTH-1:0] write_data_WB;  // used for writing on external memory
    wire [3:0]            rd_M;
    wire [1:0]            result_src_M;
    wire                  reg_write_M;
    wire                  mem_write_M;
    wire [2:0]            funct_3_M;

    // WB
    wire [DATA_WIDTH-1:0] result_WB;
    wire [DATA_WIDTH-1:0] read_data_WB;
    wire [DATA_WIDTH-1:0] alu_result_WB;
    wire [DATA_WIDTH-1:0] pc_plus4_WB;
    wire [DATA_WIDTH-1:0] o_alu_result_WB_neg;
    wire [DATA_WIDTH-1:0] pc_target_WB;
    wire [3:0]            rd_WB;
    wire                  reg_write_WB;
    wire [1:0]            result_src_WB;
    wire [2:0]            funct_3_WB;

    // @spadersimon: added below wire to implement initial reset
    wire                  if_id_rst;



    // ------------------------------------------
    // Logic
    // ------------------------------------------
    
    // Fetch Stage
    stage_fetch U_STAGE_FETCH (
        .clk(clk),
        .i_pc_target_EX(pc_target_EX),
        .i_alu_result_EX (alu_result_EX),
        .i_pc_src_EX(i_pc_src_EX),
        .i_rst_IF(rst),
        .i_en_IF(!stall_IF),
        .o_pcplus4_IF(pcplus4_IF),
        .o_pc_IF(o_pc_IF)
    );

    // IF/ID Pipeline Register
    assign if_id_rst = rst | flush_ID;

    if_id U_IF_ID (
        .clk(clk),
        .i_flush_ID(if_id_rst),  // reset
        .i_stall_ID(stall_ID),
        .i_pc_IF(o_pc_IF),
        .i_instr_IF(i_instr_IF),
        .i_pcplus4_IF(pcplus4_IF),
        .o_pc_ID(pc_ID),
        .o_instr_ID(instr_ID),
        .o_pcplus4_ID(pcplus4_ID)
    );

    // Decode Stage
    stage_decode U_STAGE_DECODE (
        .clk(clk),
        .i_rst_ID(rst),
        .i_instr_ID(instr_ID),
        .i_data_WB(result_WB),
        .i_rd_WB(rd_WB),
        .i_write_en_WB(reg_write_WB),
        .i_imm_src_ID(i_imm_src_ID),
        .o_op(o_op),
        .o_funct3(o_funct3),
        .o_funct_7_5(o_funct_7_5),
        .o_rd_ID(rd_ID),
        .o_rs1_ID(rs1_ID),
        .o_rs2_ID(rs2_ID),
        .o_rs1Addr_ID(rs1Addr_ID),
        .o_rs2Addr_ID(rs2Addr_ID),
        .o_imm_ex_ID(imm_ex_ID)
    );

    // ID/EX Pipeline Register
    id_ex U_ID_EX (
        .clk(clk),
        .i_rd_ID(rd_ID),
        .i_rs1_ID(rs1_ID),
        .i_rs2_ID(rs2_ID),
        .i_imm_ex_ID(imm_ex_ID),
        .i_rs1Addr_ID(rs1Addr_ID),
        .i_rs2Addr_ID(rs2Addr_ID),
        .i_pc_ID(pc_ID),
        .i_pc_plus4_ID(pcplus4_ID),
        .i_jump_ID(i_jump_ID),
        .i_branch_ID(i_branch_ID),
        .i_addr_src_ID (i_addr_src_ID),
        .i_reg_write_ID(i_reg_write_ID),
        .i_result_src_ID(i_result_src_ID),
        .i_mem_write_ID(i_mem_write_ID),
        .i_alu_ctrl_ID(i_alu_ctrl_ID),
        .i_alu_src_ID(i_alu_src_ID),
        .i_funct_3_ID(o_funct3),
        .i_clear(flush_EX),

        .o_rd_EX(rd_EX),
        .o_rs1_EX(rs1_EX),
        .o_rs2_EX(rs2_EX),
        .o_imm_ex_EX(imm_ext_EX),
        .o_rs1Addr_EX(rs1Addr_EX),
        .o_rs2Addr_EX(rs2Addr_EX),
        .o_pc_EX(pc_EX),
        .o_pc_plus4_EX(pcplus4_EX),
        .o_jump_EX(o_jump_EX),
        .o_branch_EX(o_branch_EX),
        .o_addr_src_EX(o_addr_src_EX),
        .o_reg_write_EX(reg_write_EX),
        .o_result_src_EX(result_src_EX),
        .o_mem_write_EX(mem_write_EX),
        .o_alu_ctrl_EX(alu_ctrl_EX),
        .o_alu_src_EX(alu_src_EX),
        .o_funct_3_EX(funct_3_EX)
    );

    // Execute Stage
    stage_execute U_STAGE_EXECUTE (
        .i_rd1_EX(rs1_EX),
        .i_rd2_EX(rs2_EX),
        .i_pc_EX(pc_EX),
        .i_imm_ext_EX(imm_ext_EX),
        .i_alu_src_EX(alu_src_EX),
        .i_result_WB(result_WB),
        .i_alu_result_M(alu_result_M),
        .i_forward_rs1_EX(forward_rs1_EX),
        .i_forward_rs2_EX(forward_rs2_EX),
        .i_alu_ctrl_EX(alu_ctrl_EX),
        .o_equal_EX(o_zero),
        .o_alu_result_EX(alu_result_EX),
        .o_write_data_EX(write_data_EX),
        .o_pc_target_EX(pc_target_EX)
    );

    // EX/MEM Pipeline Register
    ex_mem U_EX_MEM (
        .clk(clk),
        .rst(rst),
        .i_reg_write_EX(reg_write_EX),
        .i_result_src_EX(result_src_EX),
        .i_mem_write_EX(mem_write_EX),
        .i_alu_result_EX(alu_result_EX),
        .i_write_data_EX(write_data_EX),
        .i_pc_plus4_EX(pcplus4_EX),
        .i_rd_EX(rd_EX),
        .i_pc_target_EX(pc_target_EX),
        .i_funct_3_EX(funct_3_EX),
        .o_reg_write_M(reg_write_M),
        .o_result_src_M(result_src_M),
        .o_mem_write_M(mem_write_M),
        .o_alu_result_M(alu_result_M),
        .o_write_data_M(write_data_M),
        .o_pc_plus4_M(pcplus4_M),
        .o_rd_M(rd_M),
        .o_pc_target_M(pc_target_M),
        .o_funct_3_M(funct_3_M)
    );

    // Memory Access Stage
    // assign o_data_addr_M  = alu_result_WB;
    // assign o_write_data_M = write_data_M;
    // assign o_mem_write_M  = mem_write_M;

    // -------------------------------------
    // Memory Access Stage
    // assign o_data_addr_M  = alu_result_WB;
    //// assign o_data_addr_M  = alu_result_M;
    assign o_data_addr_M  = alu_result_M;

    // assign o_write_data_M = write_data_M;
    //// assign o_write_data_M = write_data_EX;
    assign o_write_data_M = write_data_M;

    assign o_mem_write_M  = mem_write_M;
    //assign o_mem_write_M  = mem_write_WB;

    assign o_funct_3_M    = funct_3_M;

    // MEM/WB Pipeline Register
    mem_wb U_MEM_WB (
        .clk(clk),
        .rst(rst),  //*
        .i_alu_result_M(alu_result_M),
        .i_read_data_M(i_read_data_M),
        .i_pc_target_M(pc_target_M),
        .i_pc_plus4_M(pcplus4_M),
        .i_rd_M(rd_M),
        .i_reg_write_M(reg_write_M),
        .i_result_src_M(result_src_M),
        .i_mem_write_M(mem_write_M),  //*
        .i_write_data_M(write_data_M),
        .i_funct_3_M(funct_3_M),
        .o_alu_result_WB(alu_result_WB),
        .o_alu_result_WB_neg(o_alu_result_WB_neg),
        .o_read_data_WB(read_data_WB),
        .o_pc_target_WB(pc_target_WB),  // ! not being used??
        .o_pc_plus4_WB(pc_plus4_WB),
        .o_rd_WB(rd_WB),
        .o_reg_write_WB(reg_write_WB),
        .o_result_src_WB(result_src_WB),
        .o_mem_write_WB(mem_write_WB),  //*
        .o_write_data_WB(write_data_WB),
        .o_funct_3_WB(funct_3_WB)
    );

    // Write-Back Stage
    stage_write_back U_STAGE_WRITE_BACK (
        .i_result_src_WB(result_src_WB),
        .i_alu_result_WB(alu_result_WB),
        // .i_alu_result_WB(o_alu_result_WB_neg),  //* reg file adjustment
        .i_pc_target_WB(pc_target_WB),
        .i_result_data_WB(read_data_WB),
        .i_pcplus4_WB(pc_plus4_WB),
        .i_funct_3(funct_3_WB),
        .o_result_WB(result_WB)
    );

    // Hazard Detection Unit
    hazard_unit U_HAZARD_UNIT (
        .i_rs1Addr_ID(rs1Addr_ID),
        .i_rs2Addr_ID(rs2Addr_ID),
        .i_rdAddr_EX(rd_EX),
        .i_rs1Addr_EX(rs1Addr_EX),
        .i_rs2Addr_EX(rs2Addr_EX),
        .i_pcSrc_EX(i_pc_src_EX),
        .i_result_src_EX(result_src_EX),
        .i_rdAddr_M(rd_M),
        .i_reg_write_M(reg_write_M),
        .i_rdAddr_WB(rd_WB),
        .i_reg_write_WB(reg_write_WB),
        .o_stall_IF(stall_IF),
        .o_stall_ID(stall_ID),
        .o_flush_ID(flush_ID),
        .o_flush_EX(flush_EX),
        .o_forward_rs1_EX(forward_rs1_EX),
        .o_forward_rs2_EX(forward_rs2_EX)
    );

endmodule
