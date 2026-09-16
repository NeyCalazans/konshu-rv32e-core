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
    i_addr_src_ID,
    i_reg_write_ID,
    i_result_src_ID,
    i_mem_write_ID,
    i_alu_ctrl_ID,
    i_alu_src_ID,
    i_funct_3_ID,
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
    o_addr_src_EX,
    o_reg_write_EX,
    o_result_src_EX,
    o_mem_write_EX,
    o_alu_ctrl_EX,
    o_alu_src_EX,
    o_funct_3_EX
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input wire                  clk;
    input wire [REG_WIDTH-1:0]  i_rd_ID;  // Datapath
    input wire [DATA_WIDTH-1:0] i_rs1_ID;
    input wire [DATA_WIDTH-1:0] i_rs2_ID;
    input wire [DATA_WIDTH-1:0] i_imm_ex_ID;
    input wire [REG_WIDTH-1:0]  i_rs1Addr_ID;
    input wire [REG_WIDTH-1:0]  i_rs2Addr_ID;
    input wire [DATA_WIDTH-1:0] i_pc_ID;
    input wire [DATA_WIDTH-1:0] i_pc_plus4_ID;
    input wire                  i_jump_ID;  // Control
    input wire                  i_branch_ID;
    input wire                  i_addr_src_ID;
    input wire                  i_reg_write_ID;
    input wire [1:0]            i_result_src_ID;
    input wire                  i_mem_write_ID;
    input wire [4:0]            i_alu_ctrl_ID;
    input wire                  i_alu_src_ID;
    input wire [2:0]            i_funct_3_ID;
    input wire                  i_clear;  // Hazard

    output reg [REG_WIDTH-1:0]  o_rd_EX;  // Datapath
    output reg [DATA_WIDTH-1:0] o_rs1_EX;
    output reg [DATA_WIDTH-1:0] o_rs2_EX;
    output reg [DATA_WIDTH-1:0] o_imm_ex_EX;
    output reg [REG_WIDTH-1:0]  o_rs1Addr_EX;
    output reg [REG_WIDTH-1:0]  o_rs2Addr_EX;
    output reg [DATA_WIDTH-1:0] o_pc_EX;
    output reg [DATA_WIDTH-1:0] o_pc_plus4_EX;
    output reg                  o_jump_EX;  // Control
    output reg                  o_branch_EX;
    output reg                  o_addr_src_EX;
    output reg                  o_reg_write_EX;
    output reg [1:0]            o_result_src_EX;
    output reg                  o_mem_write_EX;
    output reg [4:0]            o_alu_ctrl_EX;
    output reg                  o_alu_src_EX;
    output reg [2:0]            o_funct_3_EX;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    always @(posedge clk) begin
        if (i_clear) begin
            // Clear the pipeline registers
            o_rd_EX         <= 4'b0;
            o_rs1_EX        <= 32'b0;
            o_rs2_EX        <= 32'b0;
            o_imm_ex_EX     <= 32'b0;
            o_rs1Addr_EX    <= 4'b0;
            o_rs2Addr_EX    <= 4'b0;
            o_pc_EX         <= 32'b0;
            o_pc_plus4_EX   <= 32'b0;
            o_jump_EX       <= 1'b0;
            o_branch_EX     <= 1'b0;
            o_addr_src_EX   <= 1'b0;
            o_reg_write_EX  <= 1'b0;
            o_result_src_EX <= 2'b0;
            o_mem_write_EX  <= 1'b0;
            o_alu_ctrl_EX   <= 5'b0;
            o_alu_src_EX    <= 1'b0;
            o_funct_3_EX    <= 3'b0;
        end
        else begin
            // Update the pipeline registers
            o_rd_EX         <= i_rd_ID;
            o_rs1_EX        <= i_rs1_ID;
            o_rs2_EX        <= i_rs2_ID;
            o_imm_ex_EX     <= i_imm_ex_ID;
            o_rs1Addr_EX    <= i_rs1Addr_ID;
            o_rs2Addr_EX    <= i_rs2Addr_ID;
            o_pc_EX         <= i_pc_ID;
            o_pc_plus4_EX   <= i_pc_plus4_ID;
            o_jump_EX       <= i_jump_ID;
            o_branch_EX     <= i_branch_ID;
            o_addr_src_EX   <= i_addr_src_ID;
            o_reg_write_EX  <= i_reg_write_ID;
            o_result_src_EX <= i_result_src_ID;
            o_mem_write_EX  <= i_mem_write_ID;
            o_alu_ctrl_EX   <= i_alu_ctrl_ID;
            o_alu_src_EX    <= i_alu_src_ID;
            o_funct_3_EX    <= i_funct_3_ID;
        end

    end
endmodule
