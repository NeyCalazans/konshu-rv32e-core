//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    stage_write_back.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       stage_write_back
// Description: Verilog module stage_write_back
////////////////////////////////////////////////////////////////////////////////

module stage_write_back #(
    parameter DATA_WIDTH = 32
) (
    i_result_src_WB,
    i_alu_result_WB,
    i_result_data_WB,
    i_pcplus4_WB,
    i_pc_target_WB,
    o_result_WB
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input logic [1:0] i_result_src_WB;
    input logic [DATA_WIDTH-1:0] i_alu_result_WB;
    input logic [DATA_WIDTH-1:0] i_result_data_WB;
    input logic [DATA_WIDTH-1:0] i_pcplus4_WB;
    input logic [DATA_WIDTH-1:0] i_pc_target_WB;

    output logic [31:0] o_result_WB;


    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    // ------------------------------------------
    // Signals definitions
    // ------------------------------------------


    // ------------------------------------------
    // Logic
    // ------------------------------------------
    always @(i_result_src_WB or i_alu_result_WB or i_result_data_WB or i_pcplus4_WB) begin
        case (i_result_src_WB)
            2'b00: begin
                o_result_WB = i_alu_result_WB;  //
            end
            2'b01: begin
                o_result_WB = i_pcplus4_WB;  //
            end
            2'b10: begin
                o_result_WB = i_result_data_WB;  // comes from Data Memory
            end
            2'b11: begin
                o_result_WB = i_pc_target_WB;  // PC + imm (comes from stage_execute.next_pc)
            end
        endcase
    end
endmodule
