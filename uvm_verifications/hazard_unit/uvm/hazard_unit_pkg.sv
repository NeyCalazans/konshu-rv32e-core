/**
 * @defgroup uvm_components UVM verification components
 * @brief UVM classes and utilities used to verify the hazard unit.
 */
/**
 * @file hazard_unit_pkg.sv
 * @brief Package that includes the UVM classes used by the hazard-unit verification environment.
 *
 * @details Centralizes the inclusion of all verification components required to
 *          build the hazard-unit UVM testbench.
 */
package hazard_unit_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "pkt.sv"
    `include "sequencer.sv"
    `include "hazard_unit_sequence.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "agent.sv"
    `include "coverage.sv"
    `include "scoreboard.sv"
    `include "env.sv"
    `include "test.sv"

endpackage
