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
    i_funct_3,
    o_result_WB
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    
    input wire [1:0]            i_result_src_WB;
    input wire [DATA_WIDTH-1:0] i_alu_result_WB;
    input wire [DATA_WIDTH-1:0] i_result_data_WB;
    input wire [DATA_WIDTH-1:0] i_pcplus4_WB;
    input wire [DATA_WIDTH-1:0] i_pc_target_WB;
    input wire [2:0]            i_funct_3;

    output reg [31:0] o_result_WB;

    // ------------------------------------------
    // Sign declaration
    // ------------------------------------------

    wire [DATA_WIDTH-1:0] result_data_WB;
    wire [1:0]            addr_low_WB;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign addr_low_WB = i_alu_result_WB[1:0];

    load_extend #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U_LOAD_EXTEND (
        .i_funct_3(i_funct_3),
        .i_addr_low(addr_low_WB),
        .i_read_data_M(i_result_data_WB),
        .o_result_data_WB(result_data_WB)
    );

    always @(*) begin
        case (i_result_src_WB)
            2'b00: begin
                o_result_WB = i_alu_result_WB;  //
            end
            2'b01: begin
                o_result_WB = i_pcplus4_WB;  //
            end
            2'b10: begin
                o_result_WB = result_data_WB;  // comes from Data Memory
            end
            2'b11: begin
                o_result_WB = i_pc_target_WB;  // PC + imm (comes from stage_execute.next_pc)
            end
        endcase
    end




endmodule
