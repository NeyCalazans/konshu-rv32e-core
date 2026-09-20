/**
 * @file reference_model.c
 * @brief Golden reference model for the extend unit, called from the UVM scoreboard via DPI-C.
 *
 * @details Reconstructs the sign-extended RISC-V immediate for every `imm_src`
 *          format (I/S/B/J/U), operating on the same instr[31:7] slice
 *          (`i_imm_ID`, 25 bits) received by `extend_unit.v` after the opcode
 *          field has been stripped off by the decode stage.
 * @ingroup uvm_components
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// imm_src encoding defined by extend_unit.v (values 5..7 are reserved)
typedef enum {
    IMM_SRC_I = 0,
    IMM_SRC_S = 1,
    IMM_SRC_B = 2,
    IMM_SRC_J = 3,
    IMM_SRC_U = 4
} imm_src_e;

/**
 * @brief Computes the expected sign-extended immediate for one `imm_src` format.
 *
 * @param imm_src    Immediate format selector (see `imm_src_e`; any other value
 *                   is reserved and expected to produce 0).
 * @param imm_id     instr[31:7], right-aligned into the low 25 bits.
 * @param exp_imm_ex Output: expected `o_imm_ex_ID`.
 */
void extend_unit_golden(uint32_t imm_src, uint32_t imm_id, uint32_t *exp_imm_ex)
{
    // Rebuild the original 32-bit instruction (opcode bits left as 0), so the
    // standard RISC-V instr[31:0] bit positions can be used directly instead of
    // the shifted imm_id[24:0] offsets.
    uint32_t instr = imm_id << 7;
    int32_t imm = 0;

    switch (imm_src) {

    case IMM_SRC_I:
        // imm[11:0] = instr[31:20]; the arithmetic shift of int32_t sign-extends it
        imm = ((int32_t)instr) >> 20;
        break;

    case IMM_SRC_S:
        // imm[11:5] = instr[31:25] (sign-extended), imm[4:0] = instr[11:7]
        imm = (((int32_t)instr) >> 20) & ~0x1F;
        imm |= (instr >> 7) & 0x1F;
        break;

    case IMM_SRC_B:
        // imm[12|11|10:5|4:1|0] = instr[31|7|30:25|11:8|-], built with masks and shifts
        imm = (((int32_t)instr) >> 19) & ~0xFFF;            // instr[31] -> imm[12], sign-extended above
        imm |= (instr << 4) & 0x800;                       // instr[7]     -> imm[11]
        imm |= (instr >> 20) & 0x7E0;                      // instr[30:25] -> imm[10:5]
        imm |= (instr >> 7) & 0x1E;                        // instr[11:8]  -> imm[4:1]
        break;

    case IMM_SRC_J:
        // imm[20|19:12|11|10:1|0] = instr[31|19:12|20|30:21|-], built with masks and shifts
        imm = (((int32_t)instr) >> 11) & ~0xFFFFF;          // instr[31] -> imm[20], sign-extended above
        imm |= instr & 0xFF000;                            // instr[19:12] -> imm[19:12]
        imm |= (instr >> 9) & 0x800;                       // instr[20]    -> imm[11]
        imm |= (instr >> 20) & 0x7FE;                      // instr[30:21] -> imm[10:1]
        break;

    case IMM_SRC_U:
        // imm[31:12] = instr[31:12], imm[11:0] = 0
        imm = instr & 0xFFFFF000u;
        break;

    default:
        // Reserved imm_src values (5..7): the RTL's default branch outputs 0
        imm = 0;
        break;
    }

    *exp_imm_ex = (uint32_t)imm;
}

#ifdef __cplusplus
}
#endif