/**
 * @defgroup tb_components Testbench components
 * @brief Interface and top-level testbench modules used by the verification environment.
 */
/**
 * @file s_interface.sv
 * @brief Hazard-unit stimulus/response interface shared by the DUT and the UVM environment.
 *
 * @details Declares the pipeline-register-address/control signals consumed by the
 *          hazard unit and the stall/flush/forward signals it produces, and exposes
 *          the `driver`, `monitor`, and `dut` modports used by the UVM driver, the
 *          UVM monitor, and the `hazard_unit_wrapper` DUT respectively.
 * @ingroup tb_components
 */
/**
 * @interface s_interface
 * @brief Hazard-unit stimulus/response interface shared by the DUT and the UVM environment.
 */
interface s_interface (
  input logic clk,
  input logic reset
);

  logic [3:0] rs1_addr_id;     ///< rs1 address at Decode (`i_rs1Addr_ID`).
  logic [3:0] rs2_addr_id;     ///< rs2 address at Decode (`i_rs2Addr_ID`).
  logic [3:0] rd_addr_ex;      ///< rd address at Execute (`i_rdAddr_EX`).
  logic [3:0] rs1_addr_ex;     ///< rs1 address at Execute (`i_rs1Addr_EX`).
  logic [3:0] rs2_addr_ex;     ///< rs2 address at Execute (`i_rs2Addr_EX`).
  logic       pc_src_ex;       ///< PC-redirect flag at Execute (`i_pcSrc_EX`).
  logic [1:0] result_src_ex;   ///< Write-back source select at Execute (`i_result_src_EX`).
  logic [3:0] rd_addr_m;       ///< rd address at Memory (`i_rdAddr_M`).
  logic       reg_write_m;     ///< Register-file write enable at Memory (`i_reg_write_M`).
  logic [3:0] rd_addr_wb;      ///< rd address at WriteBack (`i_rdAddr_WB`).
  logic       reg_write_wb;    ///< Register-file write enable at WriteBack (`i_reg_write_WB`).

  logic       stall_if;        ///< `o_stall_IF`, driven by the DUT.
  logic       stall_id;        ///< `o_stall_ID`, driven by the DUT.
  logic       flush_id;        ///< `o_flush_ID`, driven by the DUT.
  logic       flush_ex;        ///< `o_flush_EX`, driven by the DUT.
  logic [1:0] forward_rs1_ex;  ///< `o_forward_rs1_EX`, driven by the DUT.
  logic [1:0] forward_rs2_ex;  ///< `o_forward_rs2_EX`, driven by the DUT.

  logic enable;                ///< Pulsed high by the driver while a transaction is valid.

  /// Modport used by the UVM driver: drives the stimulus signals.
  modport driver (
    input  clk, reset,
    output rs1_addr_id, rs2_addr_id, rd_addr_ex, rs1_addr_ex, rs2_addr_ex,
           pc_src_ex, result_src_ex, rd_addr_m, reg_write_m, rd_addr_wb, reg_write_wb,
           enable
  );

  /// Modport used by the UVM monitor: observes every signal, drives none.
  modport monitor (
    input clk, reset, rs1_addr_id, rs2_addr_id, rd_addr_ex, rs1_addr_ex, rs2_addr_ex,
          pc_src_ex, result_src_ex, rd_addr_m, reg_write_m, rd_addr_wb, reg_write_wb,
          stall_if, stall_id, flush_id, flush_ex, forward_rs1_ex, forward_rs2_ex, enable
  );

  /// Modport used by the `hazard_unit_wrapper` DUT: consumes the stimulus, drives the results.
  modport dut (
    input  clk, reset, rs1_addr_id, rs2_addr_id, rd_addr_ex, rs1_addr_ex, rs2_addr_ex,
           pc_src_ex, result_src_ex, rd_addr_m, reg_write_m, rd_addr_wb, reg_write_wb, enable,
    output stall_if, stall_id, flush_id, flush_ex, forward_rs1_ex, forward_rs2_ex
  );

endinterface
