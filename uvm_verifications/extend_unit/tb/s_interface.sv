/**
 * @defgroup tb_components Testbench components
 * @brief Interface and top-level testbench modules used by the verification environment.
 */
/**
 * @file s_interface.sv
 * @brief Extend-unit stimulus/response interface shared by the DUT and the UVM environment.
 *
 * @details Declares the immediate-format selector/raw-immediate/extended-immediate
 *          signals and exposes the `driver`, `monitor`, and `dut` modports used by
 *          the UVM driver, the UVM monitor, and the `extend_unit_wrapper` DUT respectively.
 * @ingroup tb_components
 */
/**
 * @interface s_interface
 * @brief Extend-unit stimulus/response interface shared by the DUT and the UVM environment.
 */
interface s_interface (
  input logic clk,
  input logic reset
);

  logic [2:0]  imm_src;   ///< Immediate format selector (`i_imm_src_ID`), driven by the driver.
  logic [24:0] imm_id;    ///< Raw instr[31:7] slice (`i_imm_ID`), driven by the driver.
  logic [31:0] imm_ex;    ///< Sign-extended immediate (`o_imm_ex_ID`), driven by the DUT.
  logic        enable;    ///< Pulsed high by the driver while a transaction is valid.

  /// Modport used by the UVM driver: drives the stimulus signals.
  modport driver (
    input  clk, reset,
    output imm_src, imm_id, enable
  );

  /// Modport used by the UVM monitor: observes every signal, drives none.
  modport monitor (
    input  clk, reset, imm_src, imm_id, imm_ex, enable
  );

  /// Modport used by the `extend_unit_wrapper` DUT: consumes the stimulus, drives the result.
  modport dut (
    input  clk, reset, imm_src, imm_id, enable,
    output imm_ex
  );

endinterface
