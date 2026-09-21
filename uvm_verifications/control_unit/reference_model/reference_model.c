/**
 * @file reference_model.c
 * @brief Golden reference model for the control unit, called from the UVM scoreboard via DPI-C.
 *
 * @details Derives every control signal directly from the RISC-V base ISA
 *          instruction formats (RV32I opcode map, instr[6:2]) and their funct3/
 *          funct7[5] encoding, independently of the RTL decoders under test.
 *          FENCE and SYSTEM (ECALL/EBREAK) are not modeled: they never use the
 *          ALU result, so o_alu_ctrl_ID/o_alu_src_ID have no defined expected
 *          value for them; pkt.sv excludes those two opcodes from randomization.
 * @ingroup uvm_components
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// RV32I base opcodes (instr[6:2]; instr[1:0] is always 2'b11 and carries no information)
#define OP_LOAD   0x00u
#define OP_IMM    0x04u
#define OP_AUIPC  0x05u
#define OP_STORE  0x08u
#define OP_REG    0x0Cu
#define OP_LUI    0x0Du
#define OP_BRANCH 0x18u
#define OP_JALR   0x19u
#define OP_JAL    0x1Bu

// ALU control codes (per alu.v)
#define ALU_AND 0u
#define ALU_OR 1u
#define ALU_XOR 2u
#define ALU_ADD 3u
#define ALU_SUB 4u
#define ALU_SLL 5u
#define ALU_SRL 6u
#define ALU_SLT 7u
#define ALU_SLTU 8u
#define ALU_SRA 9u
#define ALU_BEQ 10u
#define ALU_BNE 11u
#define ALU_BLT 12u
#define ALU_BLTU 13u
#define ALU_BGE 14u
#define ALU_BGEU 15u
#define ALU_LUI 16u

// Immediate formats: 0=I, 1=S, 2=B, 3=J, 4=U
#define IMM_I 0u
#define IMM_S 1u
#define IMM_B 2u
#define IMM_J 3u
#define IMM_U 4u

// Write-back source select: 0=ALU result, 1=PC+4, 2=data memory, 3=PC+imm
#define RESULT_ALU 0u
#define RESULT_PC4 1u
#define RESULT_MEM 2u
#define RESULT_PCIMM 3u

/**
 * @brief ALU control for the shared R-type/I-type arithmetic funct3 encoding.
 *
 * @param funct3    instr[14:12].
 * @param funct7_5  instr[30] (bit 5 of funct7; distinguishes ADD/SUB and SRL/SRA).
 * @param is_reg_type 1 for R-type (OP), 0 for I-type immediate arithmetic (OP-IMM).
 *                     ADDI has no subtract-immediate counterpart, so funct7_5 only
 *                     selects SUB over ADD for R-type.
 */
static unsigned int alu_ctrl_for_arith(unsigned int funct3, unsigned char funct7_5, int is_reg_type)
{
    switch (funct3) {
    case 0: return (is_reg_type && funct7_5) ? ALU_SUB : ALU_ADD;
    case 1: return ALU_SLL;
    case 2: return ALU_SLT;
    case 3: return ALU_SLTU;
    case 4: return ALU_XOR;
    case 5: return funct7_5 ? ALU_SRA : ALU_SRL;
    case 6: return ALU_OR;
    default: return ALU_AND;  // funct3 == 7
    }
}

/**
 * @brief ALU control for a conditional branch, selected purely by funct3.
 *
 * @details funct3 == 3'b010/3'b011 are reserved (not real RV32I branch
 *          conditions); pkt.sv's branch_funct3_valid constraint keeps them
 *          from ever being generated, so they are not handled here.
 */
static unsigned int alu_ctrl_for_branch(unsigned int funct3)
{
    switch (funct3) {
    case 0: return ALU_BEQ;
    case 1: return ALU_BNE;
    case 4: return ALU_BLT;
    case 5: return ALU_BGE;
    case 6: return ALU_BLTU;
    default: return ALU_BGEU;  // funct3 == 7
    }
}

/**
 * @brief Computes the expected control-unit outputs for one instruction.
 *
 * @param op              instr[6:2], the RV32I base opcode.
 * @param funct3          instr[14:12].
 * @param funct7_5        instr[30].
 * @param branch_ex       1 if the instruction at Execute is a branch (o_branch_ID, registered).
 * @param jump_ex         1 if the instruction at Execute is a jump (o_jump_ID, registered).
 * @param zero            1 if the ALU's branch comparison result is true.
 * @param exp_jump_id       Output: expected o_jump_ID.
 * @param exp_branch_id     Output: expected o_branch_ID.
 * @param exp_reg_write_id  Output: expected o_reg_write_ID.
 * @param exp_result_src_id Output: expected o_result_src_ID (see RESULT_* above).
 * @param exp_mem_write_id  Output: expected o_mem_write_ID.
 * @param exp_alu_ctrl_id   Output: expected o_alu_ctrl_ID (see ALU_* above).
 * @param exp_alu_src_id    Output: expected o_alu_src_ID.
 * @param exp_addr_src_id   Output: expected o_addr_src_ID.
 * @param exp_imm_src_id    Output: expected o_imm_src_ID (see IMM_* above).
 * @param exp_fence_id      Output: expected o_fence_ID.
 * @param exp_pc_src_ex     Output: expected o_pc_src_EX.
 */
void control_unit_golden(unsigned int op,
                         unsigned int funct3,
                         unsigned char funct7_5,
                         unsigned char branch_ex,
                         unsigned char jump_ex,
                         unsigned char zero,
                         unsigned char *exp_jump_id,
                         unsigned char *exp_branch_id,
                         unsigned char *exp_reg_write_id,
                         unsigned int *exp_result_src_id,
                         unsigned char *exp_mem_write_id,
                         unsigned int *exp_alu_ctrl_id,
                         unsigned char *exp_alu_src_id,
                         unsigned char *exp_addr_src_id,
                         unsigned int *exp_imm_src_id,
                         unsigned char *exp_fence_id,
                         unsigned char *exp_pc_src_ex)
{
    unsigned char jump = 0, branch = 0, reg_write = 0, mem_write = 0, alu_src = 0, addr_src = 0, fence = 0;
    unsigned int result_src = RESULT_ALU, imm_src = IMM_I, alu_ctrl = ALU_ADD;

    switch (op) {

    case OP_LOAD:
        reg_write = 1;
        alu_src = 1;
        imm_src = IMM_I;
        alu_ctrl = ALU_ADD;
        result_src = RESULT_MEM;
        break;

    case OP_IMM:
        reg_write = 1;
        alu_src = 1;
        imm_src = IMM_I;
        alu_ctrl = alu_ctrl_for_arith(funct3, funct7_5, 0);
        break;

    case OP_AUIPC:
        reg_write = 1;
        alu_src = 1;
        imm_src = IMM_U;
        alu_ctrl = ALU_ADD;
        result_src = RESULT_PCIMM;
        break;

    case OP_STORE:
        mem_write = 1;
        alu_src = 1;
        imm_src = IMM_S;
        alu_ctrl = ALU_ADD;
        break;

    case OP_REG:
        reg_write = 1;
        alu_ctrl = alu_ctrl_for_arith(funct3, funct7_5, 1);
        break;

    case OP_LUI:
        reg_write = 1;
        alu_src = 1;
        imm_src = IMM_U;
        alu_ctrl = ALU_LUI;
        break;

    case OP_BRANCH:
        branch = 1;
        imm_src = IMM_B;
        alu_ctrl = alu_ctrl_for_branch(funct3);
        break;

    case OP_JALR:
        jump = 1;
        reg_write = 1;
        addr_src = 1;
        alu_src = 1;
        imm_src = IMM_I;
        alu_ctrl = ALU_ADD;
        result_src = RESULT_PC4;
        break;

    case OP_JAL:
        jump = 1;
        reg_write = 1;
        imm_src = IMM_J;
        result_src = RESULT_PC4;
        break;

    default:
        // Reserved/unimplemented opcode: everything stays at its default (0).
        break;
    }

    *exp_jump_id = jump;
    *exp_branch_id = branch;
    *exp_reg_write_id = reg_write;
    *exp_result_src_id = result_src;
    *exp_mem_write_id = mem_write;
    *exp_alu_ctrl_id = alu_ctrl;
    *exp_alu_src_id = alu_src;
    *exp_addr_src_id = addr_src;
    *exp_imm_src_id = imm_src;
    *exp_fence_id = fence;
    *exp_pc_src_ex = (zero && branch_ex) || jump_ex;
}

#ifdef __cplusplus
}
#endif
