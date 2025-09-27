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
    input logic [2:0] i_alu_op;
    input logic [2:0] i_funct_3;
    input logic i_funct_7_5;
    output logic [4:0] o_alu_ctrl_ID;

    localparam logic [2:0] OP_LUI = 3'b000,  // 0 else: LUI
    OP_ARITH = 3'b001,  // 1 Arithmetic: R-type I-type
    OP_ADD_SUB = 3'b010,  // 2 add: R-type add, sub (just look at func7_bit5), load (imm + rs1), store (imm + rs1) , jalr (PC + imm), fence (???), auipc (PC + imm)
    OP_BRANCH = 3'b011,  // 3 branch
    OP_ADD = 3'b100;  // only JAL


    localparam logic [4:0] AND = 5'b00000,  // 0 ok
    OR = 5'b00001,  // 1 ok
    XOR = 5'b00010,  // 2 ok
    ADD = 5'b00011,  // 3 ok
    SUB = 5'b00100,  // 4 check
    SLL = 5'b00101,  // 5 ok
    SRL = 5'b00110,  // 6 ok
    SLT = 5'b00111,  // 7 check if it is signed comparison
    SLTU = 5'b01000,  // 8 check unsigned
    SRA = 5'b01001,  // 9 ok
    BEQ = 5'b01010,  // 10 check -> // ' the ALU computes A − B and looks at the flags. If Z is asserted, the result is 0, so A = B. Otherwise, A is not equal to B.
    BNE = 5'b01011,  // 11 check
    BLT = 5'b01100,  // 12 check
    BLTU = 5'b01101,  // 13 check
    BGE = 5'b01110,  // 14 check
    BGEU = 5'b01111,  // 15 check
    LUI = 5'b10000,  // 16 ok
    AUIPC = 5'b10001,  // 17 check
    FENCE = 5'b10010,  // 18 dummy (check if it is necessary)
    ECALL = 5'b10011,  // 19 dummy (check if it is necessary)
    EBREAK = 5'b10100;  // 20 dummy (check if it is necessary)
    // ------------------------------------------
    // Logic
    // ------------------------------------------
    // assign o_alu_ctrl_ID = (i_alu_op == OP_ADD_SUB) ? ADD :  // ADD
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b111)) ? AND :  // AND and ANDI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b110)) ? OR :  // OR and ORI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b100)) ? XOR :  // XOR and XORI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b001)) ? SLL :  // SLL and SLLI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b0)) ?
    //         SRL :  // SRL and SRLI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b010)) ? SLT :  // SLT and SLTI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b011)) ? SLTU :  // SLTU and SLTIU
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b1)) ?
    //         SRA :  // SRA and SRAI
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b000)) ? BEQ :  // BEQ
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b001)) ? BNE :  // BNE
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b100)) ? BLT :  // BLT 
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b110)) ? BLTU :  // BLTU
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b101)) ? BGE :  // BGE
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b111)) ? BGEU :  // BGEU
    //     (i_alu_op == 2'b10) ? SUB :  // SUB
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b000)) ? LUI :  // LUI
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b001)) ? AUIPC :  // AUIPC
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b010)) ? FENCE :  // FENCE
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b011)) ? ECALL :  // ECALL
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b100)) ? 5'b10100 :  // EBREAK
    //     5'bzzzz;  // default case

    assign o_alu_ctrl_ID = ((i_alu_op == OP_ADD_SUB) & (i_funct_3 == 3'b000) &
                            (i_funct_7_5 == 1'b0)) ? ADD :  // ADD
        ((i_alu_op == OP_ADD_SUB) & (i_funct_3 == 3'b000) & (i_funct_7_5 == 1'b1)) ? SUB :  // SUB
        ((i_alu_op == OP_ADD_SUB)) ? ADD :  // add: LOAD, STORE, AUIPC, FENCE, ECALL, EBREAK
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b000)) ? ADD :  // SLL and SLLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b001)) ? SLL :  // SLL and SLLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b010)) ? SLT :  // SLT and SLTI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b011)) ? SLTU :  // SLTU and SLTIU
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b100)) ? XOR :  // XOR and XORI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b0)) ?
            SRL :  // SRL and SRLI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b1)) ?
            SRA :  // SRA and SRAI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b110)) ? OR :  // OR and ORI
        ((i_alu_op == OP_ARITH) & (i_funct_3 == 3'b111)) ? AND :  // AND and ANDI
        // SRA :  // SRA and SRAI
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b000)) ? BEQ :  // BEQ
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b001)) ? BNE :  // BNE
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b100)) ? BLT :  // BLT 
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b110)) ? BLTU :  // BLTU
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b101)) ? BGE :  // BGE
        ((i_alu_op == OP_BRANCH) & (i_funct_3 == 3'b111)) ? BGEU :  // BGEU
        ((i_alu_op == OP_LUI)) ? LUI :  // LUI
        ((i_alu_op == OP_ADD)) ? ADD :  // JALR
        5'bzzzzz;  // default case



    // assign o_alu_ctrl_ID =
    //     // Load/Store instructions or ADD
    //     (i_alu_op == 2'b00) ? 2'b11 :  // ADD: Load/Store operations set ALU to perform an ADD

    //     // Immediate or Register-Register instructions
    //     // Logical AND operation (AND and ANDI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b111)) ?
    //         2'b00 :  // AND: i_funct_3 = 111 for logical AND

    //     // Logical OR operation (OR and ORI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b110)) ?
    //         2'b01 :  // OR: i_funct_3 = 110 for logical OR

    //     // Logical XOR operation (XOR and XORI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b100)) ?
    //         2'b10 :  // XOR: i_funct_3 = 100 for logical XOR

    //     // Shift left logical operation (SLL and SLLI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b001)) ?
    //         2'b01 :  // SLL: i_funct_3 = 001 for logical left shift

    //     // Shift right logical operation (SRL and SRLI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b0)) ?
    //         2'b10 :  // SRL: i_funct_3 = 101, i_funct_7_5 = 0 for logical right shift

    //     // Set less than (SLT and SLTI) for signed comparison
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b010)) ?
    //         2'b11 :  // SLT: i_funct_3 = 010 for signed comparison

    //     // Set less than unsigned (SLTU and SLTIU) for unsigned comparison
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b011)) ?
    //         SLTU :  // SLTU: i_funct_3 = 011 for unsigned comparison

    //     // Shift right arithmetic operation (SRA and SRAI)
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b101) & (i_funct_7_5 == 1'b1)) ?
    //         SRA :  // SRA: i_funct_3 = 101, i_funct_7_5 = 1 for arithmetic right shift

    //     // Branch instructions
    //     // BEQ: Branch if equal
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b000)) ?
    //         BEQ :  // BEQ: i_funct_3 = 000 for branch equal

    //     // BNE: Branch if not equal
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b001)) ?
    //         BNE :  // BNE: i_funct_3 = 001 for branch not equal

    //     // BLT: Branch if less than (signed)
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b100)) ?
    //         BLT :  // BLT: i_funct_3 = 100 for branch if less than (signed)

    //     // BLTU: Branch if less than (unsigned)
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b110)) ?
    //         BLTU :  // BLTU: i_funct_3 = 110 for branch if less than (unsigned)

    //     // BGE: Branch if greater or equal (signed)
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b101)) ?
    //         BGE :  // BGE: i_funct_3 = 101 for branch if greater or equal (signed)

    //     // BGEU: Branch if greater or equal (unsigned)
    //     ((i_alu_op == 2'b11) & (i_funct_3 == 3'b111)) ?
    //         BGEU :  // BGEU: i_funct_3 = 111 for branch if greater or equal (unsigned)

    //     // SUB: Subtraction operation
    //     (i_alu_op == 2'b10) ? 2'b00 :  // SUB: i_alu_op = 2'b10 for subtraction

    //     // New instructions for LUI, AUIPC, FENCE, ECALL, and EBREAK
    //     // LUI: Load Upper Immediate
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b000)) ?
    //         LUI :  // LUI: i_funct_3 = 000 for load upper immediate

    //     // AUIPC: Add Upper Immediate to PC
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b001)) ?
    //         AUIPC :  // AUIPC: i_funct_3 = 001 for add upper immediate to PC

    //     // FENCE: Memory ordering instruction
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b010)) ?
    //         FENCE :  // FENCE: i_funct_3 = 010 for memory fence

    //     // ECALL: Environment call
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b011)) ?
    //         ECALL :  // ECALL: i_funct_3 = 011 for environment call

    //     // EBREAK: Breakpoint instruction
    //     ((i_alu_op == 2'b01) & (i_funct_3 == 3'b100)) ?
    //         5'b10100 :  // EBREAK: i_funct_3 = 100 for breakpoint

    //     // Default case
    //     5'bzzzz;  // Undefined behavior for unknown instruction combinations


endmodule

