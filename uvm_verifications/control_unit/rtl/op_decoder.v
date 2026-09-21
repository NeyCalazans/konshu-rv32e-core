//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    opcode_decoder.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       opcode_decoder
// Description: Verilog module opcode_decoder responsible for identifing the
//              instruction to be executed by the ALU
////////////////////////////////////////////////////////////////////////////////

module op_decoder (
    i_op,
    i_funct_3,
    i_funct_7_5,
    o_jump_ID,
    o_branch_ID,
    o_reg_write_ID,
    o_result_src_ID,
    o_mem_write_ID,
    o_alu_src_ID,
    o_imm_src_ID,
    o_alu_op,
    o_addr_src_ID,
    o_fence_ID
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input logic [4:0] i_op;
    input logic [2:0] i_funct_3;
    input logic       i_funct_7_5;

    output logic       o_jump_ID;
    output logic       o_branch_ID;
    output logic       o_reg_write_ID;
    output logic [1:0] o_result_src_ID;
    output logic       o_mem_write_ID;
    output logic       o_alu_src_ID;
    output logic [2:0] o_imm_src_ID;
    output logic [2:0] o_alu_op;
    output logic       o_addr_src_ID;
    output logic       o_fence_ID;

    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    localparam logic [2:0] OP_LUI     = 3'b000;  // 0 else: LUI
    localparam logic [2:0] OP_ARITH   = 3'b001;  // 1 Arithmetic: R-type I-type
    localparam logic [2:0] OP_ADD_SUB = 3'b010;  // 2 add: R-type add, sub (just look at func7_bit5), load (imm + rs1), store (imm + rs1) , jalr (PC + imm), fence (???), auipc (PC + imm)
    localparam logic [2:0] OP_BRANCH  = 3'b011;  // 3 branch
    localparam logic [2:0] OP_ADD     = 3'b100;  // only JAL

    localparam logic [2:0] I_type = 3'b000;  
    localparam logic [2:0] S_type = 3'b001;  
    localparam logic [2:0] B_type = 3'b010;  
    localparam logic [2:0] J_type = 3'b011;  
    localparam logic [2:0] U_type = 3'b100; 

    localparam logic [4:0] R_TYPE        = 5'b01100;
    localparam logic [4:0] I_TYPE_LOAD   = 5'b00000;
    localparam logic [4:0] I_TYPE_ARITH  = 5'b00100;
    localparam logic [4:0] I_TYPE_JALR   = 5'b11001;
    localparam logic [4:0] J_TYPE_JAL    = 5'b11011;
    localparam logic [4:0] U_TYPE_LUI    = 5'b01101;
    localparam logic [4:0] U_TYPE_AUIPC  = 5'b00101;
    localparam logic [4:0] S_TYPE        = 5'b01000;  
    localparam logic [4:0] B_TYPE_BRANCH = 5'b11000;
    localparam logic [4:0] I_TYPE_FENCE  = 5'b00011;
    localparam logic [4:0] I_TYPE_SYSTEM = 5'b11100;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign o_jump_ID      = (i_op == J_TYPE_JAL | i_op == I_TYPE_JALR) ? 1'b1 : 1'b0;  

    assign o_branch_ID    = (i_op == B_TYPE_BRANCH) ? 1'b1 : 1'b0;  

    assign o_mem_write_ID = (i_op == S_TYPE) ? 1'b1 : 1'b0;  

    assign o_addr_src_ID  = (i_op == I_TYPE_JALR) ? 1'b1 : 1'b0;  

    assign o_fence_ID     = (i_op == I_TYPE_FENCE) ? 1'b1 : 1'b0;  

    assign o_reg_write_ID = (i_op == U_TYPE_LUI | i_op == U_TYPE_AUIPC | i_op == J_TYPE_JAL |
                             i_op == I_TYPE_JALR | i_op == I_TYPE_LOAD | i_op == I_TYPE_ARITH |
                             i_op == R_TYPE) ? 1'b1 : 1'b0;

    // 00: alu
    // 01: PC + 4
    // 10: Data from Data Memory
    // 11:  PC + imm (comes from stage_execute.next_pc)

    // write_back mux selection: stage_write_back.o_result_WB
    assign o_result_src_ID =
        (i_op == R_TYPE)       ? 2'b00 :  // ALU result
        (i_op == I_TYPE_LOAD)  ? 2'b10 :  //
        (i_op == I_TYPE_ARITH) ? 2'b00 :  // ALU result
        (i_op == I_TYPE_JALR)  ? 2'b01 :  // Data from Data Memory
        (i_op == J_TYPE_JAL)   ? 2'b01 :  // PC + 4
        (i_op == U_TYPE_LUI)   ? 2'b00 :  // ALU result: add: 0 + imm ({upimm, 12'b0})
        (i_op == U_TYPE_AUIPC) ? 2'b11 :  // next_pc result: add: PC + imm ({upimm, 12'b0})
        2'bxx;  // bx


    assign o_alu_src_ID = (i_op == U_TYPE_LUI | i_op == U_TYPE_AUIPC | i_op == I_TYPE_JALR |
                           i_op == I_TYPE_LOAD | i_op == S_TYPE | i_op == I_TYPE_ARITH | i_op == I_TYPE_SYSTEM) 
                           ? 1'b1 : 1'b0;

    assign o_imm_src_ID = (i_op == U_TYPE_LUI) ?
                           U_type : (i_op == U_TYPE_AUIPC) ? U_type : (i_op == J_TYPE_JAL) ? J_type :  
                          (i_op == B_TYPE_BRANCH) ? B_type : (i_op == S_TYPE) ? S_type : I_type;


    // 00 else: LUI
    // 01 Arithmetic: R-type I-type
    // 10 add: R-type add, sub (just look at func7_bit5), load (imm + rs1), store (imm + rs1) , jalr (PC + imm), fence (???), auipc (PC + imm), ecall (??), ebreak (???)
    // 11 branch

    assign o_alu_op =
        // Branch instructions (e.g., BEQ, BNE)
        (i_op == B_TYPE_BRANCH) ? OP_BRANCH :

        // Load instructions
        (i_op == I_TYPE_LOAD) ? OP_ADD_SUB :

        // Store instructions
        (i_op == S_TYPE) ? OP_ADD_SUB :

        // Immediate arithmetic instructions (e.g., ANDI, ORI, etc.)
        (i_op == I_TYPE_ARITH) ? OP_ARITH :

        // Register-Register arithmetic instructions
        (i_op == R_TYPE) ? (

        // SUB instruction (funct7[5] == 1 and funct3 == 000)
        (i_funct_3 == 3'b000) ? OP_ADD_SUB :

        // Other R-type instructions
        OP_ARITH) :

        // LUI instruction
        (i_op == U_TYPE_LUI) ? OP_LUI :

        // AUIPC instruction
        (i_op == U_TYPE_AUIPC) ? OP_ADD :

        // FENCE instruction
        (i_op == I_TYPE_FENCE) ? OP_ADD_SUB :

        // ECALL and EBREAK instructions
        (i_op == I_TYPE_SYSTEM) ? OP_ADD_SUB :

        // JALR instruction: PC = rs1 + imm, rd = PC + 4 (selects pc_plus4 instead of alu result)
        (i_op == I_TYPE_JALR) ? OP_ADD :

        // Default case
        // 2'bxx;
        OP_ADD_SUB;


endmodule
