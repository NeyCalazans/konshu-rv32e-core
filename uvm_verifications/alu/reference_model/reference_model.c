/**
 * @file reference_model.c
 * @brief Golden reference model for the ALU, called from the UVM scoreboard via DPI-C.
 *
 * @details Implements the expected result and equal/comparison flag for every
 *          `alu_ctrl` opcode defined by the project, following the RISC-V ISA
 *          semantics (signed vs. unsigned comparisons, shift amount masking, etc.).
 * @ingroup uvm_components
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// alu_ctrl encoding defined by the project
#define OP_AND    0
#define OP_OR     1
#define OP_XOR    2
#define OP_ADD    3
#define OP_SUB    4
#define OP_SLL    5
#define OP_SRL    6
#define OP_SLT    7
#define OP_SLTU   8
#define OP_SRA    9
#define OP_BEQ   10
#define OP_BNE   11
#define OP_BLT   12
#define OP_BLTU  13
#define OP_BGE   14
#define OP_BGEU  15
#define OP_LUI   16
#define OP_AUIPC 17
#define OP_FENCE 18
#define OP_ECALL 19
#define OP_EBREAK 20


/**
 * @brief Computes the expected ALU result and equal/comparison flag for one operation.
 *
 * @param alu_ctrl   ALU opcode (see the OP_* defines above).
 * @param rd1        First operand (rs1), as an unsigned bit pattern.
 * @param rd2        Second operand (rs2), as an unsigned bit pattern.
 * @param exp_result Output: expected `o_alu_result_EX`.
 * @param exp_equal  Output: expected `o_equal_EX` (comparison/branch-taken flag).
 */
void alu_golden(int alu_ctrl,
                unsigned int rd1,
                unsigned int rd2,
                unsigned int *exp_result,
                unsigned char *exp_equal)
{
    // Signed version of the operands, for signed operations
    int32_t s1 = (int32_t)rd1;
    int32_t s2 = (int32_t)rd2;

    // shift amount usa apenas os 5 bits inferiores do segundo operando
    unsigned int shamt = rd2 & 0x1F;

    unsigned int result = 0;
    unsigned char equal = 0;

    switch (alu_ctrl) {

        case OP_AND:
            result = rd1 & rd2;
            break;

        case OP_OR:
            result = rd1 | rd2;
            break;

        case OP_XOR:
            result = rd1 ^ rd2;
            break;

        case OP_ADD:
            result = rd1 + rd2;
            break;

        case OP_SUB:
            result = rd1 - rd2;
            break;

        case OP_SLL:
            result = rd1 << shamt;
            break;

        case OP_SRL:
            result = rd1 >> shamt;
            break;

        case OP_SLT:
            result = (s1 < s2) ? 1u : 0u;
            equal = (rd1 == rd2) ? 1 : 0;
            break;

        case OP_SLTU:
            result = (rd1 < rd2) ? 1u : 0u;
            equal = (rd1 == rd2) ? 1 : 0;
            break;

        case OP_SRA:
            result = (unsigned int)(s1 >> shamt);
            break;

        case OP_BEQ:
            result = 0;
            equal = (rd1 == rd2) ? 1 : 0;
            break;

        case OP_BNE:
            result = 0;
            equal = (rd1 != rd2) ? 1 : 0;
            break;

        case OP_BLT:
            result = 0;
            equal = (s1 < s2) ? 1 : 0;
            break;

        case OP_BLTU:
            result = 0;
            equal = (rd1 < rd2) ? 1 : 0;
            break;

        case OP_BGE:
            result = 0;
            equal = (s1 >= s2) ? 1 : 0;
            break;

        case OP_BGEU:
            result = 0;
            equal = (rd1 >= rd2) ? 1 : 0;
            break;

        case OP_LUI:
            result = rd2;
            equal = 0;
            break;

        // This operations were not defined in the original ALU project,
        // but they were left here so we can compare the outputs
        case OP_AUIPC:
        case OP_FENCE:
        case OP_ECALL:
        case OP_EBREAK:
        
        default:
            result = 0;
            equal = 0;
            break;
        }

        *exp_result = result;
        *exp_equal = equal;
}

#ifdef __cplusplus
}
#endif