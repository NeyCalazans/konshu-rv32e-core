//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    if_id.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       if_id
// Description: Verilog module if_id is the pipeline register for stage FETCH and 
//              stage DECODE
////////////////////////////////////////////////////////////////////////////////

module if_id #(
    parameter DATA_WIDTH = 32,
    parameter REG_WIDTH  = 4
) (
    clk,
    i_flush_ID,
    i_stall_ID,
    i_pc_IF,
    o_pc_ID,
    i_pcplus4_IF,
    o_pcplus4_ID,
    i_instr_IF,
    o_instr_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic clk;
    input logic [DATA_WIDTH-1:0] i_pcplus4_IF;
    input logic [DATA_WIDTH-1:0] i_pc_IF;
    input logic [DATA_WIDTH-1:0] i_instr_IF;
    input logic i_flush_ID;
    input logic i_stall_ID;

    output logic [DATA_WIDTH-1:0] o_pcplus4_ID;
    output logic [DATA_WIDTH-1:0] o_pc_ID;
    output logic [DATA_WIDTH-1:0] o_instr_ID;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    // Register always block
    always @(posedge clk) begin
        if (i_flush_ID) begin
            // If a flush signal is asserted, clear the pipeline registers
            o_pcplus4_ID <= 32'h00000004;
            o_pc_ID <= 32'h0;
            // o_instr_ID <= 32'h0;
            o_instr_ID <= 32'h00000033;  // resets to NOP instruction
            // o_instr_ID <= 32'h007383b3;  // add x7, x7, x7
        end else if (!i_stall_ID) begin
            // Update the pipeline registers with new values
            o_pcplus4_ID <= i_pcplus4_IF;
            o_pc_ID <= i_pc_IF;
            o_instr_ID <= i_instr_IF;
        end
    end

endmodule
