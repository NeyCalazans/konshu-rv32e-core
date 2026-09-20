/**
 * @defgroup tb_components Testbench components
 * @brief Interface and assertion modules used by the verification environment.
 */
/**
 * @file s_interface.sv
 * @brief ALU stimulus/response interface shared by the DUT and the UVM environment.
 *
 * @details Declares the ALU operand/opcode/result/handshake signals and exposes
 *          the `driver`, `monitor`, and `dut` modports used by the UVM driver,
 *          the UVM monitor, and the `alu_wrapper` DUT respectively.
 * @ingroup tb_components
 */
/**
 * @interface s_interface
 * @brief ALU stimulus/response interface shared by the DUT and the UVM environment.
 */
interface s_interface (
  input logic clk,
  input logic reset
);

  logic [31:0] register_1;  ///< Operand rs1 (`i_rd1_EX`), driven by the driver.
  logic [31:0] register_2;  ///< Operand rs2 (`i_rd2_EX`), driven by the driver.
  logic [4:0] alu_ctrl;     ///< ALU opcode (`i_alu_ctrl_EX`), driven by the driver.
  logic [31:0] alu_result;  ///< ALU result (`o_alu_result_EX`), driven by the DUT.
  logic equal;              ///< Comparison/branch-taken flag (`o_equal_EX`), driven by the DUT.
  logic enable;             ///< Pulsed high by the driver while a transaction is valid.

  /// Modport used by the UVM driver: drives the stimulus signals.
  modport driver (
    input  clk, reset,
    output register_1, register_2, alu_ctrl, enable
  );

  /// Modport used by the UVM monitor: observes every signal, drives none.
  modport monitor (
    input  clk, reset, register_1, register_2, alu_ctrl, alu_result, equal, enable
  );

  /// Modport used by the `alu_wrapper` DUT: consumes the stimulus, drives the result.
  modport dut (
    input  clk, reset, register_1, register_2, alu_ctrl, enable,
    output alu_result, equal
  );

endinterface