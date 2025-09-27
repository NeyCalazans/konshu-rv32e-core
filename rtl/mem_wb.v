//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    mem_wb.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       mem_wb
// Description: Verilog module mem_wb. This is the pipeline register between 
//              stage MEM and WB 
////////////////////////////////////////////////////////////////////////////////

module mem_wb #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 4
) (
    clk,
    rst,
    i_alu_result_M,
    i_read_data_M,
    i_pc_target_M,
    i_pc_plus4_M,
    i_rd_M,
    i_reg_write_M,
    i_result_src_M,
    i_mem_write_M,
    i_write_data_M,
    o_alu_result_WB,
    o_alu_result_WB_neg,
    o_read_data_WB,
    o_pc_target_WB,
    o_pc_plus4_WB,
    o_rd_WB,
    o_reg_write_WB,
    o_result_src_WB,
    o_mem_write_WB,
    o_write_data_WB
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic clk;
    input logic rst;
    input logic [DATA_WIDTH-1:0] i_alu_result_M;  // Datapath
    input logic [DATA_WIDTH-1:0] i_read_data_M;
    input logic [DATA_WIDTH-1:0] i_pc_plus4_M;
    input logic [DATA_WIDTH-1:0] i_pc_target_M;
    input logic [REG_WIDTH-1:0] i_rd_M;
    input logic i_reg_write_M;  // Control
    input logic [1:0] i_result_src_M;
    input logic i_mem_write_M;
    input logic [DATA_WIDTH-1:0] i_write_data_M;

    output logic [DATA_WIDTH-1:0] o_alu_result_WB;  // Datapath
    output logic [DATA_WIDTH-1:0] o_alu_result_WB_neg;  // for write on Data Memory
    output logic [DATA_WIDTH-1:0] o_read_data_WB;
    output logic [DATA_WIDTH-1:0] o_pc_plus4_WB;
    output logic [DATA_WIDTH-1:0] o_pc_target_WB;
    output logic [REG_WIDTH-1:0] o_rd_WB;
    output logic o_reg_write_WB;  // Control
    output logic [1:0] o_result_src_WB;
    output logic o_mem_write_WB;
    output logic [DATA_WIDTH-1:0] o_write_data_WB;


    // ------------------------------------------
    // Logic
    // ------------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            // Clear the pipeline registers
            o_read_data_WB  <= {DATA_WIDTH{1'b0}};
            o_pc_target_WB  <= {DATA_WIDTH{1'b0}};
            o_pc_plus4_WB   <= {DATA_WIDTH{1'b0}};
            o_reg_write_WB  <= 1'b0;
            o_result_src_WB <= 2'b00;

            // o_rd_WB <= {REG_WIDTH{1'b0}};  // reg file
            o_alu_result_WB <= {DATA_WIDTH{1'b0}};  //*
            // o_mem_write_WB <= 1'b0;  //* new
        end else begin
            o_read_data_WB  <= i_read_data_M;
            o_pc_target_WB  <= i_pc_target_M;
            o_pc_plus4_WB   <= i_pc_plus4_M;
            o_reg_write_WB  <= i_reg_write_M;
            o_result_src_WB <= i_result_src_M;

            o_rd_WB <= i_rd_M;  // reg file
            o_alu_result_WB <= i_alu_result_M;  //*
            // o_mem_write_WB <= i_mem_write_M;  //* new
        end
    end

    always @(negedge clk) begin
        if (rst) begin
            // o_rd_WB <= {REG_WIDTH{1'b0}};  // reg file
            o_alu_result_WB_neg <= {DATA_WIDTH{1'b0}};
            o_mem_write_WB <= 1'b0;
            o_write_data_WB <= {DATA_WIDTH{1'b0}};
        end else begin
            // o_rd_WB <= i_rd_M;  // reg file
            o_alu_result_WB_neg <= i_alu_result_M;
            o_mem_write_WB <= i_mem_write_M;
            o_write_data_WB <= i_write_data_M;
        end
    end

endmodule
