/**
 * @defgroup uvm_components UVM verification components
 * @brief UVM classes and utilities used to verify the control unit.
 */
/**
 * @file control_unit_pkg.sv
 * @brief Package that includes the UVM classes used by the control-unit verification environment.
 *
 * @details Centralizes the inclusion of all verification components required to
 *          build the control-unit UVM testbench.
 */
package control_unit_pkg;
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    `include "pkt.sv"
    `include "sequencer.sv"
    `include "control_unit_sequence.sv"
    `include "driver.sv"
    `include "monitor.sv"
    `include "agent.sv"
    `include "coverage.sv"
    `include "scoreboard.sv"
    `include "env.sv"
    `include "test.sv"

endpackage
