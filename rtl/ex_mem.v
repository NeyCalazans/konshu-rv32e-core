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
    i_funct_3_EX,
    o_alu_result_M,
    o_write_data_M,
    o_pc_plus4_M,
    o_rd_M,
    o_reg_write_M,
    o_result_src_M,
    o_mem_write_M,
    o_pc_target_M,
    o_funct_3_M
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire                  clk;
    input wire                  rst;
    input wire [DATA_WIDTH-1:0] i_alu_result_EX;  // Datapath
    input wire [DATA_WIDTH-1:0] i_write_data_EX;
    input wire [DATA_WIDTH-1:0] i_pc_plus4_EX;
    input wire [REG_WIDTH-1:0]  i_rd_EX;
    input wire                  i_reg_write_EX;  // Control
    input wire [1:0]            i_result_src_EX;
    input wire                  i_mem_write_EX;
    input wire [DATA_WIDTH-1:0] i_pc_target_EX;
    input wire [2:0]            i_funct_3_EX;

    output reg [DATA_WIDTH-1:0] o_alu_result_M;  // Datapath
    output reg [DATA_WIDTH-1:0] o_write_data_M;
    output reg [DATA_WIDTH-1:0] o_pc_plus4_M;
    output reg [REG_WIDTH-1:0]  o_rd_M;
    output reg                  o_reg_write_M;  // Control
    output reg [1:0]            o_result_src_M;
    output reg                  o_mem_write_M;
    output reg [DATA_WIDTH-1:0] o_pc_target_M;
    output reg [2:0]            o_funct_3_M;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(posedge clk) begin
        if (rst) begin
            o_pc_plus4_M   <= {DATA_WIDTH{1'b0}};
            o_rd_M         <= {REG_WIDTH{1'b0}};
            o_reg_write_M  <= 1'b0;
            o_result_src_M <= 2'b00;
            o_pc_target_M  <= {DATA_WIDTH{1'b0}};
            o_mem_write_M  <= 1'b0;  //*
            o_alu_result_M <= {DATA_WIDTH{1'b0}};  //*
            o_write_data_M <= {DATA_WIDTH{1'b0}};  //*
            o_funct_3_M    <= 3'b0;
        end
        else begin
            o_pc_plus4_M   <= i_pc_plus4_EX;
            o_rd_M         <= i_rd_EX;
            o_reg_write_M  <= i_reg_write_EX;
            o_result_src_M <= i_result_src_EX;
            o_pc_target_M  <= i_pc_target_EX;
            o_mem_write_M  <= i_mem_write_EX;  //*
            o_alu_result_M <= i_alu_result_EX;  //*
            o_write_data_M <= i_write_data_EX;  //*
            o_funct_3_M    <= i_funct_3_EX;
        end
    end


endmodule
