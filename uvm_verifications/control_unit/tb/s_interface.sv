/**
 * @defgroup tb_components Testbench components
 * @brief Interface and top-level testbench modules used by the verification environment.
 */
/**
 * @file s_interface.sv
 * @brief Control-unit stimulus/response interface shared by the DUT and the UVM environment.
 *
 * @details Declares the instruction-field/EX-stage-feedback signals consumed by the
 *          control unit and the control signals it produces, and exposes the
 *          `driver`, `monitor`, and `dut` modports used by the UVM driver, the UVM
 *          monitor, and the `control_unit_wrapper` DUT respectively.
 * @ingroup tb_components
 */
/**
 * @interface s_interface
 * @brief Control-unit stimulus/response interface shared by the DUT and the UVM environment.
 */
interface s_interface (
  input logic clk,
  input logic reset
);

  logic [4:0] op;          ///< RV32I base opcode, instr[6:2] (`i_op`).
  logic [2:0] funct3;      ///< instr[14:12] (`i_funct_3`).
  logic       funct7_5;    ///< instr[30] (`i_funct_7_5`).
  logic       branch_ex;   ///< Registered o_branch_ID at Execute (`i_branch_EX`).
  logic       jump_ex;     ///< Registered o_jump_ID at Execute (`i_jump_EX`).
  logic       zero;        ///< ALU branch-comparison result (`i_zero`).

  logic       pc_src_ex;   ///< `o_pc_src_EX`, driven by the DUT.
  logic       jump_id;     ///< `o_jump_ID`, driven by the DUT.
  logic       branch_id;   ///< `o_branch_ID`, driven by the DUT.
  logic       reg_write_id;///< `o_reg_write_ID`, driven by the DUT.
  logic [1:0] result_src_id; ///< `o_result_src_ID`, driven by the DUT.
  logic       mem_write_id;///< `o_mem_write_ID`, driven by the DUT.
  logic [4:0] alu_ctrl_id; ///< `o_alu_ctrl_ID`, driven by the DUT.
  logic       alu_src_id;  ///< `o_alu_src_ID`, driven by the DUT.
  logic       addr_src_id; ///< `o_addr_src_ID`, driven by the DUT.
  logic [2:0] imm_src_id;  ///< `o_imm_src_ID`, driven by the DUT.
  logic       fence_id;    ///< `o_fence_ID`, driven by the DUT.

  logic enable;            ///< Pulsed high by the driver while a transaction is valid.

  /// Modport used by the UVM driver: drives the stimulus signals.
  modport driver (
    input  clk, reset,
    output op, funct3, funct7_5, branch_ex, jump_ex, zero, enable
  );

  /// Modport used by the UVM monitor: observes every signal, drives none.
  modport monitor (
    input clk, reset, op, funct3, funct7_5, branch_ex, jump_ex, zero, enable,
          pc_src_ex, jump_id, branch_id, reg_write_id, result_src_id, mem_write_id,
          alu_ctrl_id, alu_src_id, addr_src_id, imm_src_id, fence_id
  );

  /// Modport used by the `control_unit_wrapper` DUT: consumes the stimulus, drives the results.
  modport dut (
    input  clk, reset, op, funct3, funct7_5, branch_ex, jump_ex, zero, enable,
    output pc_src_ex, jump_id, branch_id, reg_write_id, result_src_id, mem_write_id,
           alu_ctrl_id, alu_src_id, addr_src_id, imm_src_id, fence_id
  );

endinterface
