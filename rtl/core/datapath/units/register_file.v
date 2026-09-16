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
    parameter DATA_WIDTH = 32,
    NUM_REGS = 16,
    INDEX_WIDTH = 4
) (
    clk,
    i_rst_ID,
    i_write_en_WB,
    i_data_WB,
    i_rd_WB,
    i_instr_ID,
    o_rs1_ID,
    o_rs2_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    
    input wire                   clk;
    input wire                   i_rst_ID;
    input wire                   i_write_en_WB;  // determine write operation is enabled
    input wire [DATA_WIDTH-1:0]  i_data_WB;  // data to be written
    input wire [INDEX_WIDTH-1:0] i_rd_WB;  // determine the register to be written
    input wire [DATA_WIDTH-1:0]  i_instr_ID;  // determine the registers to be read

    output reg [DATA_WIDTH-1:0] o_rs1_ID;
    output reg [DATA_WIDTH-1:0] o_rs2_ID;

    /*output wire [DATA_WIDTH-1:0] o_rs1_ID;
    output wire [DATA_WIDTH-1:0] o_rs2_ID;*/

    // ------------------------------------------
    // Sign declaration
    // ------------------------------------------

    reg [DATA_WIDTH-1:0] registers[15:0];
    integer i;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    // assign registers[0] = 32'b0;  // * search for static registers -> save energy

    // writing occurs in the first half of the clock cycle (first clock semicircle)
    always @(posedge clk) begin
        // ! ? synchronous reset ??
        if (i_rst_ID) begin
            for (i = 0; i < NUM_REGS; i = i + 1) begin
                // registers[i] <= {DATA_WIDTH{1'b0}};
                // if (i == 1) begin
                //     registers[i] <= {DATA_WIDTH{1'b0}} + i;
                // end else begin
                //     registers[i] <= {(DATA_WIDTH / 2) {2'b01}};
                // end
                registers[i] <= {DATA_WIDTH{1'b0}} + i;
                // registers[i] <= 32'b0 - i;
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
        o_rs1_ID <= (i_instr_ID[18:15] == 5'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_instr_ID[18:15] == i_rd_WB)) ? i_data_WB : registers[i_instr_ID[18:15]];
    
        o_rs2_ID <= (i_instr_ID[23:20] == 5'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_instr_ID[23:20] == i_rd_WB)) ? i_data_WB : registers[i_instr_ID[23:20]];

    end

    /*assign o_rs1_ID = (i_instr_ID[18:15] == 5'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_instr_ID[18:15] == i_rd_WB)) ? i_data_WB : registers[i_instr_ID[18:15]];
    assign o_rs2_ID = (i_instr_ID[23:20] == 5'b0) ? {DATA_WIDTH{1'b0}} :
                      (i_write_en_WB && (i_instr_ID[23:20] == i_rd_WB)) ? i_data_WB : registers[i_instr_ID[23:20]];*/

endmodule
