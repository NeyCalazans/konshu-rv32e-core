//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    next_pc.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       next_pc_tb
// Description: Calculate the address fro the next intruction to be fetched from
//              instruction memory
//////////////////////////////////////////////////////////////////////////////

module next_pc #(
    parameter DATA_WIDTH = 32
) (
    clk,
    i_pc_target_EX,
    i_pc_src_EX,
    i_alu_result_EX,
    i_rst_IF,
    i_en_IF,
    o_pcplus4_IF,
    o_pc_IF
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire                  clk;
    input wire [DATA_WIDTH-1:0] i_pc_target_EX;  //todo: cut signal LSB outside this block
    input wire [1:0]            i_pc_src_EX;
    input wire [DATA_WIDTH-1:0] i_alu_result_EX;
    input wire                  i_rst_IF;
    input wire                  i_en_IF;

    output wire [DATA_WIDTH-1:0] o_pc_IF;
    output wire [DATA_WIDTH-1:0] o_pcplus4_IF;

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------

    reg [DATA_WIDTH-1:0] muxed_input;
    reg [DATA_WIDTH-1:0] current_pc;
    reg [DATA_WIDTH-1:0] pc_plus_4;
    wire [DATA_WIDTH-1:0] pc_target_word;
    wire [DATA_WIDTH-1:0] alu_target_word;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign pc_target_word = {i_pc_target_EX[DATA_WIDTH-1:2], 2'b00};
    assign alu_target_word = {i_alu_result_EX[DATA_WIDTH-1:1], 1'b0};
    
    // next pc origin
    always @(*) begin
        case (i_pc_src_EX)
            2'b00:   muxed_input = pc_plus_4;
            2'b01:   muxed_input = pc_target_word;
            2'b11:   muxed_input = alu_target_word;
            default: muxed_input = pc_plus_4;
        endcase
    end

    always @(posedge clk or posedge i_rst_IF) begin
        if (i_rst_IF) begin
            current_pc <= 32'h0;
            pc_plus_4  <= 32'h4;
        end else begin
            if (i_en_IF) begin
                current_pc <= muxed_input;  // Load the muxed input
                pc_plus_4  <= muxed_input + 32'h4;  // PC+4 
            end
        end
    end

    assign o_pc_IF      = current_pc;
    assign o_pcplus4_IF = pc_plus_4;

endmodule
