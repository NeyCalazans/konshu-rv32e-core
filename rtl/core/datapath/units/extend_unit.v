//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    extend_unit.v
// Date:        01.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       extend_unit
// Description: Verilog for Extend Unit block. It is reponsible for extend the 
//              size of data from a smaller width to a larger width (32bit).
//
// Command to execute: iverilog -o extend_unit.vvp extend_unit_tb.v extend_unit.v -g2012 -v
//                     vvp extend_unit.vvp
//                     gtk-wave extend_unit.vcd
//////////////////////////////////////////////////////////////////////////////
module extend_unit #(
    parameter WIDTH  = 32
) (
    i_imm_ID,
    i_imm_src_ID,
    o_imm_ex_ID
);
    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [2:0]       i_imm_src_ID;
    input wire [WIDTH-8:0] i_imm_ID;

    output reg [WIDTH-1:0] o_imm_ex_ID;

    // ------------------------------------------
    // Signals definitions
    // ------------------------------------------

    localparam [2:0] I_type = 3'b000;  
    localparam [2:0] S_type = 3'b001;  
    localparam [2:0] B_type = 3'b010;  
    localparam [2:0] J_type = 3'b011;  
    localparam [2:0] U_type = 3'b100; 

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(i_imm_src_ID, i_imm_ID) begin 
        case (i_imm_src_ID)
            I_type: begin
                // I-type: 12 bits [24:13] from i_imm_ID, extended to 32 bits
                o_imm_ex_ID = {{20{i_imm_ID[24]}}, i_imm_ID[24:13]};
            end

            S_type: begin
                // S-type: 5 bits [4:0] and 7 bits [24:18] from i_imm_ID concatenated, extended to 32 bits
                o_imm_ex_ID = {{20{i_imm_ID[24]}}, i_imm_ID[24:18], i_imm_ID[4:0]};
            end

            B_type: begin
                // B-type: 1'b0, 4 bits [4:1], 7 bits [23:18], [0], and [24] from i_imm_ID concatenated, extended to 32 bits
                o_imm_ex_ID = {
                    {19{i_imm_ID[24]}},
                    i_imm_ID[24],
                    i_imm_ID[0],
                    i_imm_ID[23:18],
                    i_imm_ID[4:1],
                    1'b0
                };
            end

            J_type: begin
                // J-type: 1'b0, 10 bits [23:14], [13], 8 bits [12:5], and [24] from i_imm_ID concatenated, extended to 32 bits
                o_imm_ex_ID = {
                    {11{i_imm_ID[24]}},
                    i_imm_ID[24],
                    i_imm_ID[12:5],
                    i_imm_ID[13],
                    i_imm_ID[23:14],
                    1'b0
                };
            end

            U_type: begin
                // U-type: 20 bits [24:5] from i_imm_ID, extended to 32 bits
                o_imm_ex_ID = {i_imm_ID[24:5], {12{1'b0}}};
            end

            default: begin
                o_imm_ex_ID = 32'h0;
            end

        endcase
    end

endmodule
