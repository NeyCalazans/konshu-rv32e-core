/**
 * @defgroup uvm_components UVM verification components
 * @brief UVM classes and utilities used to verify the register file.
 */
/**
 * @file register_file_pkg.sv
 * @brief Package containing the register-file UVM verification components.
 *
 * @details Centralizes the inclusion of all verification components required to
 *          build the register-file UVM testbench.
 */
package register_file_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "pkt.sv"
    `include "sequencer.sv"
    `include "register_file_sequence.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "agent.sv"
    `include "coverage.sv"
    `include "scoreboard.sv"
    `include "env.sv"
    `include "test.sv"
endpackage
