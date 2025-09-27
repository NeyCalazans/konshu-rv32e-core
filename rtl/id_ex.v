//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    id_ex.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       id_ex
// Description: Verilog module id_ex is the pipeline register for the stage 
//              DECODE and EXECUTE
//////////////////////////////////////////////////////////////////////////////

module id_ex #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 4
) (
    clk,
    i_rd_ID,
    i_rs1_ID,
    i_rs2_ID,
    i_imm_ex_ID,
    i_rs1Addr_ID,
    i_rs2Addr_ID,
    i_pc_ID,
    i_pc_plus4_ID,
    i_jump_ID,
    i_branch_ID,
    i_reg_write_ID,
    i_result_src_ID,
    i_mem_write_ID,
    i_alu_ctrl_ID,
    i_alu_src_ID,
    i_clear,
    o_rd_EX,
    o_rs1_EX,
    o_rs2_EX,
    o_imm_ex_EX,
    o_rs1Addr_EX,
    o_rs2Addr_EX,
    o_pc_EX,
    o_pc_plus4_EX,
    o_jump_EX,
    o_branch_EX,
    o_reg_write_EX,
    o_result_src_EX,
    o_mem_write_EX,
    o_alu_ctrl_EX,
    o_alu_src_EX
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic clk;
    input logic [REG_WIDTH-1:0] i_rd_ID;  // Datapath
    input logic [DATA_WIDTH-1:0] i_rs1_ID;
    input logic [DATA_WIDTH-1:0] i_rs2_ID;
    input logic [DATA_WIDTH-1:0] i_imm_ex_ID;
    input logic [REG_WIDTH-1:0] i_rs1Addr_ID;
    input logic [REG_WIDTH-1:0] i_rs2Addr_ID;
    input logic [DATA_WIDTH-1:0] i_pc_ID;
    input logic [DATA_WIDTH-1:0] i_pc_plus4_ID;
    input logic i_jump_ID;  // Control
    input logic i_branch_ID;
    input logic i_reg_write_ID;
    input logic [1:0] i_result_src_ID;
    input logic i_mem_write_ID;
    input logic [4:0] i_alu_ctrl_ID;
    input logic i_alu_src_ID;
    input logic i_clear;  // Hazard

    output logic [REG_WIDTH-1:0] o_rd_EX;  // Datapath
    output logic [DATA_WIDTH-1:0] o_rs1_EX;
    output logic [DATA_WIDTH-1:0] o_rs2_EX;
    output logic [DATA_WIDTH-1:0] o_imm_ex_EX;
    output logic [REG_WIDTH-1:0] o_rs1Addr_EX;
    output logic [REG_WIDTH-1:0] o_rs2Addr_EX;
    output logic [DATA_WIDTH-1:0] o_pc_EX;
    output logic [DATA_WIDTH-1:0] o_pc_plus4_EX;
    output logic o_jump_EX;  // Control
    output logic o_branch_EX;
    output logic o_reg_write_EX;
    output logic [1:0] o_result_src_EX;
    output logic o_mem_write_EX;
    output logic [4:0] o_alu_ctrl_EX;
    output logic o_alu_src_EX;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    always @(posedge clk) begin
        if (i_clear) begin
            // Clear the pipeline registers
            o_rd_EX <= 4'b0;
            o_rs1_EX <= 32'b0;
            o_rs2_EX <= 32'b0;
            o_imm_ex_EX <= 32'b0;
            o_rs1Addr_EX <= 4'b0;
            o_rs2Addr_EX <= 4'b0;
            o_pc_EX <= 32'b0;
            o_pc_plus4_EX <= 32'b0;
            o_jump_EX <= 1'b0;
            o_branch_EX <= 1'b0;
            o_reg_write_EX <= 1'b0;
            o_result_src_EX <= 2'b0;
            o_mem_write_EX <= 1'b0;
            o_alu_ctrl_EX <= 5'b0;
            o_alu_src_EX <= 1'b0;
        end else begin
            // Update the pipeline registers
            o_rd_EX <= i_rd_ID;
            o_rs1_EX <= i_rs1_ID;
            o_rs2_EX <= i_rs2_ID;
            o_imm_ex_EX <= i_imm_ex_ID;
            o_rs1Addr_EX <= i_rs1Addr_ID;
            o_rs2Addr_EX <= i_rs2Addr_ID;
            o_pc_EX <= i_pc_ID;
            o_pc_plus4_EX <= i_pc_plus4_ID;
            o_jump_EX <= i_jump_ID;
            o_branch_EX <= i_branch_ID;
            o_reg_write_EX <= i_reg_write_ID;
            o_result_src_EX <= i_result_src_ID;
            o_mem_write_EX <= i_mem_write_ID;
            o_alu_ctrl_EX <= i_alu_ctrl_ID;
            o_alu_src_EX <= i_alu_src_ID;
        end

    end
endmodule
