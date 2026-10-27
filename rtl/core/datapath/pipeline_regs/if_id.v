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
    rst,
    i_stall_IF_ID,
    i_pc_IF,
    o_pc_ID,
    i_pcplus4_IF,
    o_pcplus4_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire                  clk;
    input wire                  rst;
    input wire [DATA_WIDTH-1:0] i_pcplus4_IF;
    input wire [DATA_WIDTH-1:0] i_pc_IF;
    input wire                  i_stall_IF_ID;

    output reg [DATA_WIDTH-1:0] o_pcplus4_ID;
    output reg [DATA_WIDTH-1:0] o_pc_ID;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(posedge clk) begin
        if (rst) begin
            // If a flush signal is asserted, clear the pipeline registers
            o_pcplus4_ID <= 32'h00000004;
            o_pc_ID      <= 32'h0;
        end 
        else if (!i_stall_IF_ID) begin
            // Update the pipeline registers with new values
            o_pcplus4_ID <= i_pcplus4_IF;
            o_pc_ID      <= i_pc_IF;
        end
    end

endmodule
