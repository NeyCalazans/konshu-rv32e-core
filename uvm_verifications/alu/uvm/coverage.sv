/**
 * @file coverage.sv
 * @brief Coverage collector for ALU transactions.
 *
 * @details Samples observed ALU transactions and updates the coverage model used
 *          to determine whether the verification goal has been reached.
 * @ingroup uvm_components
 */
/**
 * @class coverage
 * @brief UVM coverage subscriber for ALU transaction sampling.
 *
 * @details Tracks opcode x operand-quadrant cross coverage and publishes the
 *          current percentage to the sequence layer through the configuration database
 *          under the key `"cov_status"`.
 */
class coverage extends uvm_subscriber #(pkt);
  `uvm_component_utils(coverage)

  pkt tr;  ///< Transaction currently being sampled by `cg_alu`.

  /// Opcode x rs1-quadrant x rs2-quadrant cross coverage model.
  covergroup cg_alu;
    option.per_instance = 1;

    /// One bin per ALU opcode (see alu.v's localparams / reference_model.c's OP_* defines).
    cp_control: coverpoint tr.i_alu_ctrl_EX {
      bins controls[21] = {[0:20]};
    }

    /// Splits the full 32-bit rs1 range into 4 equal quadrants, so random stimulus
    /// hits every bin (a narrower range would make some bins statistically unreachable).
    cp_register_1: coverpoint tr.i_rd1_EX {
      bins low      = {[32'h0000_0000:32'h3FFF_FFFF]};
      bins low_med  = {[32'h4000_0000:32'h7FFF_FFFF]};
      bins high_med = {[32'h8000_0000:32'hBFFF_FFFF]};
      bins high     = {[32'hC000_0000:32'hFFFF_FFFF]};
    }

    /// Same quadrant split as cp_register_1, applied to rs2.
    cp_register_2: coverpoint tr.i_rd2_EX {
      bins low      = {[32'h0000_0000:32'h3FFF_FFFF]};
      bins low_med  = {[32'h4000_0000:32'h7FFF_FFFF]};
      bins high_med = {[32'h8000_0000:32'hBFFF_FFFF]};
      bins high     = {[32'hC000_0000:32'hFFFF_FFFF]};
    }

    /// Full cross of opcode with both operand quadrants.
    cp_cross_operations: cross cp_control, cp_register_1, cp_register_2;

  endgroup

  function new(string name = "coverage", uvm_component parent);
    super.new(name, parent);
    cg_alu = new();
    cg_alu.set_inst_name("alu_cov");
  endfunction

  /// @brief Samples the covergroup for one transaction and republishes the running coverage percentage.
  virtual function void write(pkt t);
    this.tr = t;
    cg_alu.sample();
    uvm_config_db#(real)::set(null, "*", "cov_status", cg_alu.get_inst_coverage());
  endfunction

endclass