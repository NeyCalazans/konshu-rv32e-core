/**
 * @defgroup tb_components Testbench components
 * @brief Interface and top-level testbench modules used by the verification environment.
 */
/**
 * @file s_interface.sv
 * @brief Register-file stimulus/response interface shared by the DUT and the UVM environment.
 *
 * @details Keeps the existing clock/reset/enable transaction protocol while exposing
 *          register-file write inputs and two read-data outputs.
 * @ingroup tb_components
 */
/**
 * @interface s_interface
 * @brief Register-file stimulus/response interface shared by the DUT and the UVM environment.
 */
interface s_interface (
  input logic clk,
  input logic reset
);

  logic        write_en;
  logic [31:0] write_data;
  logic [3:0]  write_addr;
  logic [31:0] instr;

  logic [31:0] rs1_data;
  logic [31:0] rs2_data;

  logic enable;            ///< Pulsed high by the driver while a transaction is valid.

  /// Modport used by the UVM driver: drives the stimulus signals.
  modport driver (
    input  clk, reset,
    output write_en, write_data, write_addr, instr, enable
  );

  /// Modport used by the UVM monitor: observes every signal, drives none.
  modport monitor (
    input clk, reset, write_en, write_data, write_addr, instr, enable, rs1_data, rs2_data
  );

  /// Modport used by the register-file wrapper: consumes the stimulus and drives the reads.
  modport dut (
    input  clk, reset, write_en, write_data, write_addr, instr, enable,
    output rs1_data, rs2_data
  );

endinterface
