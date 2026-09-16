//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    alu_decoder.v
// Date:        03.11.2024
// Reviewer:    Luis Spader
// Revision:    1.1
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       alu_decoder
// Description: Verilog module alu_decoder
////////////////////////////////////////////////////////////////////////////////

module alu_decoder (
    i_alu_op,
    i_funct_3,
    i_funct_7_5,
    o_alu_ctrl_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [2:0] i_alu_op;
    input wire [2:0] i_funct_3;
    input wire       i_funct_7_5;

    output wire [4:0] o_alu_ctrl_ID;

    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    localparam [2:0] OP_LUI     = 3'b000;  // 0 else: LUI
    localparam [2:0] OP_ARITH   = 3'b001;  // 1 Arithmetic: R-type I-type
    localparam [2:0] OP_ADD_SUB = 3'b010;  // 2 add: R-type add, sub (just look at func7_bit5), load (imm + rs1), store (imm + rs1) , jalr (PC + imm), fence (???), auipc (PC + imm)
    localparam [2:0] OP_BRANCH  = 3'b011;  // 3 branch
    localparam [2:0] OP_ADD     = 3'b100;  // only JAL


    localparam [4:0] AND    = 5'b00000;  
    localparam [4:0] OR     = 5'b00001;  
    localparam [4:0] XOR    = 5'b00010;  
    localparam [4:0] ADD    = 5'b00011;  
    localparam [4:0] SUB    = 5'b00100;  // 4 check
    localparam [4:0] SLL    = 5'b00101;  
    localparam [4:0] SRL    = 5'b00110;  
    localparam [4:0] SLT    = 5'b00111;  // 7 check if it is signed comparison // it is (Zambotto)
    localparam [4:0] SLTU   = 5'b01000;  // 8 check unsigned
    localparam [4:0] SRA    = 5'b01001;  
    localparam [4:0] BEQ    = 5'b01010;  // 10 check -> // ' the ALU computes A − B and looks at the flags. If Z is asserted, the result is 0, so A = B. Otherwise, A is not equal to B.
    localparam [4:0] BNE    = 5'b01011;  // 11 check
    localparam [4:0] BLT    = 5'b01100;  // 12 check
    localparam [4:0] BLTU   = 5'b01101;  // 13 check
    localparam [4:0] BGE    = 5'b01110;  // 14 check
    localparam [4:0] BGEU   = 5'b01111;  // 15 check
    localparam [4:0] LUI    = 5'b10000;  
    localparam [4:0] AUIPC  = 5'b10001;  // 17 check (not being used, it doesnt go through the ALU)
    
    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign o_alu_ctrl_ID = 
        ((i_alu_op == OP_ADD_SUB) & (i_funct_3 == 3'b000) & (i_funct_7_5 == 1'b0)) ? ADD :   // ADD
        ((i_alu_op == OP_ADD_SUB) & (i_funct_3 == 3'b000) & (i_funct_7_5 == 1'b1)) ? SUB :   // SUB
        ((i_alu_op == OP_ADD_SUB))                                                 ? ADD :   // add: LOAD, STORE, AUIPC
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b000))                           ? ADD :   // SLL and SLLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b001))                           ? SLL :   // SLL and SLLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b010))                           ? SLT :   // SLT and SLTI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b011))                           ? SLTU :  // SLTU and SLTIU
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b100))                           ? XOR :   // XOR and XORI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b0))   ? SRL :   // SRL and SRLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b1))   ? SRA :   // SRA and SRAI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b110))                           ? OR :    // OR and ORI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b111))                           ? AND :   // AND and ANDI
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b000))                          ? BEQ :   // BEQ
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b001))                          ? BNE :   // BNE
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b100))                          ? BLT :   // BLT 
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b110))                          ? BLTU :  // BLTU
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b101))                          ? BGE :   // BGE
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b111))                          ? BGEU :  // BGEU
        ((i_alu_op == OP_LUI))                                                     ? LUI :   // LUI
        ((i_alu_op == OP_ADD))                                                     ? ADD :   // JALR
        5'b0zzzz;                                                                            // default case (maybe change it to x)

endmodule

