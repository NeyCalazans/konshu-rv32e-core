//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    ex_mem.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       ex_mem
// Description: Verilog module ex_mem is teh pipeline register for the stage
//              EXECUTE and MEMORY
////////////////////////////////////////////////////////////////////////////////

module ex_mem #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 4
) (
    clk,
    rst,
    i_alu_result_EX,
    i_write_data_EX,
    i_pc_plus4_EX,
    i_rd_EX,
    i_reg_write_EX,
    i_result_src_EX,
    i_mem_write_EX,
    i_pc_target_EX,
    o_alu_result_M,
    o_write_data_M,
    o_pc_plus4_M,
    o_rd_M,
    o_reg_write_M,
    o_result_src_M,
    o_mem_write_M,
    o_pc_target_M
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic clk;
    input logic rst;
    input logic [DATA_WIDTH-1:0] i_alu_result_EX;  // Datapath
    input logic [DATA_WIDTH-1:0] i_write_data_EX;
    input logic [DATA_WIDTH-1:0] i_pc_plus4_EX;
    input logic [REG_WIDTH-1:0] i_rd_EX;
    input logic i_reg_write_EX;  // Control
    input logic [1:0] i_result_src_EX;
    input logic i_mem_write_EX;
    input logic [DATA_WIDTH-1:0] i_pc_target_EX;

    output logic [DATA_WIDTH-1:0] o_alu_result_M;  // Datapath
    output logic [DATA_WIDTH-1:0] o_write_data_M;
    output logic [DATA_WIDTH-1:0] o_pc_plus4_M;
    output logic [REG_WIDTH-1:0] o_rd_M;
    output logic o_reg_write_M;  // Control
    output logic [1:0] o_result_src_M;
    output logic o_mem_write_M;
    output logic [DATA_WIDTH-1:0] o_pc_target_M;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            o_pc_plus4_M <= {DATA_WIDTH{1'b0}};
            o_rd_M <= {REG_WIDTH{1'b0}};
            o_reg_write_M <= 1'b0;
            o_result_src_M <= 2'b00;
            o_pc_target_M <= {DATA_WIDTH{1'b0}};
            o_mem_write_M <= 1'b0;  //*
            o_alu_result_M <= {DATA_WIDTH{1'b0}};  //*
            o_write_data_M <= {DATA_WIDTH{1'b0}};  //*
        end else begin
            o_pc_plus4_M <= i_pc_plus4_EX;
            o_rd_M <= i_rd_EX;
            o_reg_write_M <= i_reg_write_EX;
            o_result_src_M <= i_result_src_EX;
            o_pc_target_M <= i_pc_target_EX;
            o_mem_write_M <= i_mem_write_EX;  //*
            o_alu_result_M <= i_alu_result_EX;  //*
            o_write_data_M <= i_write_data_EX;  //*
        end
    end


endmodule
