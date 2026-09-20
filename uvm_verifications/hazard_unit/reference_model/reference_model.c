/**
 * @file reference_model.c
 * @brief Golden reference model for the hazard unit, called from the UVM scoreboard via DPI-C.
 *
 * @details Implements the forwarding and stall/flush rules expected from a
 *          standard 5-stage pipeline hazard unit (data hazards solved by
 *          forwarding, load-use hazards solved by a 1-cycle stall/bubble,
 *          control hazards solved by a flush on a taken branch/jump).
 * @ingroup uvm_components
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Computes the expected forwarding selects and stall/flush flags for one cycle.
 *
 * @param rs1_id        rs1 address at the Decode stage.
 * @param rs2_id        rs2 address at the Decode stage.
 * @param rd_ex         rd address at the Execute stage.
 * @param rs1_ex        rs1 address at the Execute stage.
 * @param rs2_ex        rs2 address at the Execute stage.
 * @param pc_src_ex     1 if the instruction at Execute redirects the PC (branch taken/jump).
 * @param result_src_ex Write-back source select of the instruction at Execute
 *                       (per op_decoder.v: 00=ALU, 01=PC+4, 10=data memory, 11=PC+imm).
 * @param rd_m          rd address at the Memory stage.
 * @param reg_write_m   1 if the instruction at Memory will write the register file.
 * @param rd_wb         rd address at the WriteBack stage.
 * @param reg_write_wb  1 if the instruction at WriteBack will write the register file.
 * @param exp_stall_if       Output: expected o_stall_IF.
 * @param exp_stall_id       Output: expected o_stall_ID.
 * @param exp_flush_id       Output: expected o_flush_ID.
 * @param exp_flush_ex       Output: expected o_flush_EX.
 * @param exp_forward_rs1_ex Output: expected o_forward_rs1_EX (00=none, 01=from WB, 10=from MEM).
 * @param exp_forward_rs2_ex Output: expected o_forward_rs2_EX (00=none, 01=from WB, 10=from MEM).
 */
void hazard_unit_golden(unsigned int rs1_id,
                        unsigned int rs2_id,
                        unsigned int rd_ex,
                        unsigned int rs1_ex,
                        unsigned int rs2_ex,
                        unsigned char pc_src_ex,
                        unsigned int result_src_ex,
                        unsigned int rd_m,
                        unsigned char reg_write_m,
                        unsigned int rd_wb,
                        unsigned char reg_write_wb,
                        unsigned char *exp_stall_if,
                        unsigned char *exp_stall_id,
                        unsigned char *exp_flush_id,
                        unsigned char *exp_flush_ex,
                        unsigned int *exp_forward_rs1_ex,
                        unsigned int *exp_forward_rs2_ex)
{
    unsigned char load_hazard;

    // Forward to rs1: prefer the Memory stage over WriteBack; never forward for x0.
    if (rs1_ex == rd_m && reg_write_m && rs1_ex != 0) {
        *exp_forward_rs1_ex = 2;
    }
    else if (rs1_ex == rd_wb && reg_write_wb && rs1_ex != 0) {
        *exp_forward_rs1_ex = 1;
    }
    else {
        *exp_forward_rs1_ex = 0;
    }

    // Forward to rs2: same rule as rs1.
    if (rs2_ex == rd_m && reg_write_m && rs2_ex != 0) {
        *exp_forward_rs2_ex = 2;
    }
    else if (rs2_ex == rd_wb && reg_write_wb && rs2_ex != 0) {
        *exp_forward_rs2_ex = 1;
    }
    else {
        *exp_forward_rs2_ex = 0;
    }

    // Load-use hazard: the instruction at Execute is a load (result_src_ex == 2,
    // "data from data memory" per op_decoder.v) and the instruction at Decode
    // reads the register it will write, so a 1-cycle stall/bubble is required.
    load_hazard = (result_src_ex == 2) &&
                  ((rs1_id == rd_ex) || (rs2_id == rd_ex));

    *exp_stall_if = load_hazard;
    *exp_stall_id = load_hazard;

    // Flush on a taken branch/jump; also flush Execute to turn a load-use stall
    // into a bubble.
    *exp_flush_id = pc_src_ex ? 1 : 0;
    *exp_flush_ex = (load_hazard || pc_src_ex) ? 1 : 0;
}

#ifdef __cplusplus
}
#endif
