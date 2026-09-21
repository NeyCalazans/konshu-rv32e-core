/**
 * @file reference_model.c
 * @brief Golden reference model for the register file, called from the UVM scoreboard via DPI-C.
 *
 * @details Keeps a software copy of the 16 registers, with the same reset values
 *          as the RTL (register i holds i), and models the write-then-read behavior
 *          of one transaction. Register x0 is hard-wired to zero: writes to it
 *          are ignored and reads of it return 0.
 * @ingroup uvm_components
 */

#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

// Number of registers implemented by the RTL (x0..x15)
#define NUM_REGS 16u

/**
 * @brief Applies one write and returns the expected values of the two read ports.
 *
 * @details The write is applied before the reads, so a read of the register just
 *          written returns the new data (the RTL writes on the rising edge and reads on
 *          the falling edge of the same cycle). State persists across calls.
 *
 * @param write_en   1 to write `write_data` into `write_addr`.
 * @param write_data Data to write.
 * @param write_addr Destination register address (writes to x0 are ignored).
 * @param instr      Instruction; rs1 = instr[18:15], rs2 = instr[23:20].
 * @param exp_rs1    Output: expected `o_rs1_ID`.
 * @param exp_rs2    Output: expected `o_rs2_ID`.
 */
void register_file_golden(unsigned char write_en,
                          unsigned int write_data,
                          unsigned char write_addr,
                          unsigned int instr,
                          unsigned int *exp_rs1,
                          unsigned int *exp_rs2)
{
    // Register state kept across calls; lazily initialized to the RTL reset values
    static uint32_t registers[NUM_REGS];
    static int initialized = 0;
    unsigned int rs1_addr = (instr >> 15) & 0xFu;
    unsigned int rs2_addr = (instr >> 20) & 0xFu;

    if (!initialized) {
        for (unsigned int index = 0; index < NUM_REGS; index++) {
            registers[index] = index;
        }
        initialized = 1;
    }

    if (write_en && write_addr != 0u) {
        registers[write_addr & 0xFu] = (uint32_t)write_data;
    }

    *exp_rs1 = (rs1_addr == 0u) ? 0u : registers[rs1_addr];
    *exp_rs2 = (rs2_addr == 0u) ? 0u : registers[rs2_addr];
}

#ifdef __cplusplus
}
#endif
