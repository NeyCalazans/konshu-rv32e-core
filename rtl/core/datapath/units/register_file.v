//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    register_file.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       register_file
// Description: This file describes a register file of 16x32 bit register with 
//              x0=0.
//////////////////////////////////////////////////////////////////////////////

module register_file #(
    parameter DATA_WIDTH  = 32,
    parameter NUM_REGS    = 16,
    parameter INDEX_WIDTH = 4
) (
    clk,
    rst,
    i_write_en_WB,
    i_data_WB,
    i_rd_WB,
    i_rs1Addr_ID,
    i_rs2Addr_ID,
    o_rs1_ID,
    o_rs2_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    
    input wire                   clk;
    input wire                   rst;
    input wire                   i_write_en_WB;  // determine write operation is enabled
    input wire [DATA_WIDTH-1:0]  i_data_WB;      // data to be written
    input wire [INDEX_WIDTH-1:0] i_rd_WB;        // determine the register to be written
    input wire [INDEX_WIDTH-1:0] i_rs1Addr_ID;     // determine the registers to be read
    input wire [INDEX_WIDTH-1:0] i_rs2Addr_ID;     // determine the registers to be read

    output reg [DATA_WIDTH-1:0] o_rs1_ID;
    output reg [DATA_WIDTH-1:0] o_rs2_ID;

    // ------------------------------------------
    // Sign declaration
    // ------------------------------------------

    reg [DATA_WIDTH-1:0] registers[15:0];
    integer i;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    // writing occurs in the first half of the clock cycle (first clock semicircle)
    always @(posedge clk) begin
        // ! ? synchronous reset ??
        if (rst) begin
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                registers[i] <= {DATA_WIDTH{1'b0}} + i;
                // registers[i] <= 32'b0;
            end
        end 
        else begin
            if (i_write_en_WB & (i_rd_WB != 4'b0)) begin
                registers[i_rd_WB] <= i_data_WB;
            end
        end
    end

    // reading takes place in the second half of the clock cycle (second semicircle)
    always @(negedge clk) begin
        if (rst) begin
            o_rs1_ID <= {DATA_WIDTH{1'b0}};
            o_rs2_ID <= {DATA_WIDTH{1'b0}};
        end
        o_rs1_ID <= (i_rs1Addr_ID == 4'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_rs1Addr_ID == i_rd_WB)) ? i_data_WB : registers[i_rs1Addr_ID];
    
        o_rs2_ID <= (i_rs2Addr_ID == 4'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_rs2Addr_ID == i_rd_WB)) ? i_data_WB : registers[i_rs2Addr_ID];

    end

endmodule
