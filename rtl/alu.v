//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    alu.v
// Date:        17/03/2024
// Reviewer:    Luis Spader @LuisSpader
// Revision:    2.0
///////////////////////////;///////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     OSIRIS I
// Block:       alu
// Description: RISC V ALU module (Arithmetic Logic Unit), implements ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU
//////////////////////////////////////////////////////////////////////////////

module alu #(
    parameter WIDTH = 32
) (
    i_alu_ctrl_EX,
    i_rd1_EX,
    i_rd2_EX,
    o_alu_result_EX,
    o_equal_EX
);
    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    input wire [4:0] i_alu_ctrl_EX;  // from ALU decoder
    input wire [WIDTH-1:0] i_rd1_EX;  // todo: verify signed declaration
    input wire [WIDTH-1:0] i_rd2_EX;  // todo: verify signed declaration
    output  reg [WIDTH-1:0] o_alu_result_EX;  //ALUResult = rd (destination register)
    output reg o_equal_EX;  // ZeroE

    // ------------------------------------------
    // Localparams
    // ------------------------------------------
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
    // Signals deinitions
    // ------------------------------------------

    wire [WIDTH-1:0] not_i_rd2_EX;
    reg  [WIDTH-1:0] rd2_operand;
    reg  [WIDTH-1:0] adder_result;
    reg              cin;
    reg              change_signal;
    reg              last_bit_equal;

    assign not_i_rd2_EX = ~i_rd2_EX;


    // ---------------------------- Register/Register Instructions ---------------------------------------
    adder #(
        .WIDTH(WIDTH)
    ) U_ADDER (
        .cin(cin),
        .a  (i_rd1_EX),
        .b  (rd2_operand),
        .sum(adder_result)
    );

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(*) begin
        if (i_alu_ctrl_EX == SUB) begin
            rd2_operand = not_i_rd2_EX;
            cin = 1'b1;
        end else begin
            cin = 1'b0;
            rd2_operand = i_rd2_EX;
        end
    end

    always @(*) begin
        case (i_alu_ctrl_EX)

            AND: begin
                // AND performs and bitwise (bit-by-bit operation) logical operations.
                o_alu_result_EX = i_rd1_EX & i_rd2_EX;  // ! todo: verify AND TYPE declaration
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            OR: begin
                // OR performs or bitwise (bit-by-bit operation) logical operations.
                o_alu_result_EX = i_rd1_EX | i_rd2_EX;  // OK TODO: verify OR TYPE declaration
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            XOR: begin
                // XOR performs xor bitwise (bit-by-bit operation) logical operations.
                o_alu_result_EX = i_rd1_EX ^ i_rd2_EX;  // OK TODO: verify XOR TYPE declaration
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            ADD: begin
                // ADD performs arithmetical addition
                //o_alu_result_EX = i_rd1_EX + i_rd2_EX; 
                o_alu_result_EX = adder_result;
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            SUB: begin
                // SUB performs subtraction
                // todo: decide which way below to use
                // o_alu_result_EX = i_rd1_EX - i_rd2_EX; // ! todo: verify Verilog signed SUB operation
                // o_alu_result_EX = i_rd1_EX + not_i_rd2_EX + 1;
                o_alu_result_EX = adder_result;
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            SLL: begin
                // SLL performs logical left shifts (ignores sign) on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2.
                // rd1 shifted left by rd2: we can only shift 32 bits so we need to use 5 bits of rd2
                o_alu_result_EX = i_rd1_EX <<
                    i_rd2_EX[5-1:0];  // ! TODO: verify SLL TYPE declaration
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            SRL: begin
                // SRL performs logical right shifts (ignores sign) on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2.
                o_alu_result_EX = i_rd1_EX >>
                    i_rd2_EX[5-1:0];  // ! todo: verify SRL TYPE declaration
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            SLT: begin  // signed comparison
                // SLT performs signed comparison, writing 1 to rd if rs1 < rs2, 0 otherwise.
                o_alu_result_EX = {{WIDTH - 1{1'b0}}, (i_rd1_EX < i_rd2_EX)};
                o_equal_EX = (i_rd1_EX == i_rd2_EX);
            end

            SLTU: begin  // unsigned comparison
                // SLTU performs unsigned comparison, writing 1 to rd if rs1 < rs2, 0 otherwise.
                // o_alu_result_EX = (unsigned(i_rd1_EX) < unsigned(i_rd2_EX));
                o_alu_result_EX = {{WIDTH - 1{1'b0}}, ($unsigned(i_rd1_EX) < $unsigned(i_rd2_EX))};
                // TODO: verify SLTU TYPE declaration: need to be unsigned comparison
                o_equal_EX = (i_rd1_EX == i_rd2_EX);
            end

            SRA: begin
                // SRA performs arithmetic right shifts (consider sign) on the value in register rs1 by the shift amount held in the lower 5 bits of register rs2.
                o_alu_result_EX = $signed(i_rd1_EX) >>> $signed(i_rd2_EX[5-1:0]);
                o_equal_EX =
                    1'b0;  // todo: verify if this signal is not used on this 'case' @grouposiris
            end

            BEQ: begin
                // BEQ performs a branch if the values in registers rs1 and rs2 are equal.
                o_alu_result_EX = {WIDTH{1'b0}};
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // BTA = PC + SignExt({imm12:1,1'b0}) // ! todo: verify overflow necessity
                // todo: which signal is used to take a branch, o_equal_EX? @grouposiris
                o_equal_EX = (i_rd1_EX == i_rd2_EX);  // compare rs1 and rs2
            end

            BNE: begin
                // BNE performs a branch if the values in registers rs1 and rs2 are not equal.
                o_alu_result_EX = 'bz;
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // ! todo: verify overflow necessity
                o_equal_EX = (i_rd1_EX != i_rd2_EX);
            end

            BLT: begin
                // BLT performs a branch if the value in register rs1 is less than the value in register rs2.
                o_alu_result_EX = 'bz;
                // todo: which signal is used to take a branch, o_equal_EX? @grouposiris
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // ! todo: verify overflow necessity
                o_equal_EX = (i_rd1_EX < i_rd2_EX);
            end

            BLTU: begin
                // BLTU performs a branch if the value in register unsigned(rs1) is less than the value in register unsigned(rs2).
                o_alu_result_EX = 'bz;
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // ! todo: verify overflow necessity
                o_equal_EX = ($unsigned(i_rd1_EX) < $unsigned(i_rd2_EX));
            end

            BGE: begin
                // BGE performs a branch if the value in register rs1 is greater than or equal to the value in register rs2.
                o_alu_result_EX = 'bz;
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // ! todo: verify overflow necessity
                // todo: verify logic improvement through using not in those operators and reusing BLT comparator logic
                o_equal_EX = (i_rd1_EX >= i_rd2_EX);
            end

            BGEU: begin
                // BGEU performs a branch if the value in register unsigned(rs1) is greater than or equal to the value in register unsigned(rs2).
                o_alu_result_EX = 'bz;
                // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // ! todo: verify overflow necessity
                // o_alu_result_EX = BTA = PC + SignExt({imm12:1,1'b0})

                // todo: verify logic improvement through using not in those operators and reusing BLTU logic
                o_equal_EX = ($unsigned(i_rd1_EX) >= $unsigned(i_rd2_EX));
            end

            LUI: begin
                // LUI loads the immediate value into the upper 20 bits of the destination register rd, filling in the lowest 12 bits with zeros. The bit extension is done by decode stage. The rd2 source selection is done by stage_execute (outside alu block).
                // *bits 11-0 of rd1 are set to 0.
                o_alu_result_EX = i_rd2_EX;
                o_equal_EX = 1'bz;
            end

            // AUIPC: begin
            //     // AUIPC adds the immediate value to the upper 20 bits of the PC, filling in the lowest 12 bits with zeros. The bit extension is done by decode stage. The rd2 source selection is done by stage_execute (outside alu block).
            //     // *bits 11-0 of rd1 are set to 0.
            //     o_alu_result_EX = 'bz;  // original osiris described version (o_pc_target_EX is executed outside 'alu' block, it is on 'pc_target' block)
            //     // o_alu_result_EX = i_rd1_EX + i_rd2_EX; // suggested by @LuisSpader (using a mux with i_rd1_ex) -> calculates the BTA = PC + SignExt({imm12:1,1'b0})
            //     o_equal_EX = 1'bz;
            // end

            // FENCE: begin
            //     // FENCE is a memory fence instruction. It does not operate on registers.
            //     o_alu_result_EX = 'bz;
            //     o_equal_EX = 1'bz;
            // end

            // ECALL: begin
            //     // ECALL is a system call instruction. It does not operate on registers.
            //     o_alu_result_EX = 'bz;
            //     o_equal_EX = 1'bz;
            // end

            // EBREAK: begin
            //     // EBREAK is a breakpoint instruction. It does not operate on registers.
            //     o_alu_result_EX = 'bz;
            //     o_equal_EX = 1'bz;
            // end


            default: begin
                // todo: verify best strategy for default case @grouposiris
                // '?' is don't care (by convention)
                // 'x' is unknown
                // 'z' is high impedance
                //  0
                o_alu_result_EX = 'bz;
                o_equal_EX = 1'bz;
            end
        endcase
    end


endmodule
