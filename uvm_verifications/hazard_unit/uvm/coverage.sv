/**
 * @file coverage.sv
 * @brief Coverage collector for hazard-unit transactions.
 *
 * @details Samples observed hazard-unit transactions and updates the coverage model
 *          used to determine whether the verification goal has been reached.
 * @ingroup uvm_components
 */
/**
 * @class coverage
 * @brief UVM coverage subscriber for hazard-unit transaction sampling.
 *
 * @details Tracks each hazard/forwarding condition individually, plus their
 *          priority-order combinations, and publishes the current percentage to
 *          the sequence layer through the configuration database
 *          under the key `"cov_status"`.
 */
class coverage extends uvm_subscriber #(pkt);
  `uvm_component_utils(coverage)

  pkt tr;  ///< Transaction currently being sampled by `cg_hazard_unit`.

  /// Forwarding/hazard condition coverage model.
  covergroup cg_hazard_unit;
    option.per_instance = 1;

    /// All 4 write-back source codes (2'b10 is the load/"data from memory" code the
    /// load-use check should key on).
    cp_result_src_EX: coverpoint tr.i_result_src_EX {
      bins values[4] = {[0:3]};
    }

    /// Both PC-redirect states, to exercise o_flush_ID/o_flush_EX.
    cp_pc_src_EX: coverpoint tr.i_pcSrc_EX {
      bins values[2] = {[0:1]};
    }

    /// True when the Decode-stage rs1 matches the Execute-stage rd while the
    /// Execute-stage instruction is a load: the load-use hazard condition for rs1.
    cp_load_hazard_rs1: coverpoint (tr.i_result_src_EX == 2'b10 && tr.i_rs1Addr_ID == tr.i_rdAddr_EX) {
      bins values[2] = {[0:1]};
    }

    /// Same as cp_load_hazard_rs1, for rs2.
    cp_load_hazard_rs2: coverpoint (tr.i_result_src_EX == 2'b10 && tr.i_rs2Addr_ID == tr.i_rdAddr_EX) {
      bins values[2] = {[0:1]};
    }

    /// True when rs1 at Execute matches rd at Memory, that Memory instruction writes
    /// the register file, and rs1 isn't x0: the Memory-forward condition for rs1.
    cp_forward_rs1_mem: coverpoint (tr.i_rs1Addr_EX == tr.i_rdAddr_M && tr.i_reg_write_M && tr.i_rs1Addr_EX != 0) {
      bins values[2] = {[0:1]};
    }

    /// Same as cp_forward_rs1_mem, against the WriteBack stage.
    cp_forward_rs1_wb: coverpoint (tr.i_rs1Addr_EX == tr.i_rdAddr_WB && tr.i_reg_write_WB && tr.i_rs1Addr_EX != 0) {
      bins values[2] = {[0:1]};
    }

    /// Same as cp_forward_rs1_mem, for rs2.
    cp_forward_rs2_mem: coverpoint (tr.i_rs2Addr_EX == tr.i_rdAddr_M && tr.i_reg_write_M && tr.i_rs2Addr_EX != 0) {
      bins values[2] = {[0:1]};
    }

    /// Same as cp_forward_rs1_wb, for rs2.
    cp_forward_rs2_wb: coverpoint (tr.i_rs2Addr_EX == tr.i_rdAddr_WB && tr.i_reg_write_WB && tr.i_rs2Addr_EX != 0) {
      bins values[2] = {[0:1]};
    }

    /// Crossing mem/wb for rs1 exercises the mem-over-wb priority when both are true.
    cp_cross_forward_rs1: cross cp_forward_rs1_mem, cp_forward_rs1_wb;

    /// Crossing mem/wb for rs2 exercises the mem-over-wb priority when both are true.
    cp_cross_forward_rs2: cross cp_forward_rs2_mem, cp_forward_rs2_wb;

  endgroup

  function new(string name = "coverage", uvm_component parent);
    super.new(name, parent);
    cg_hazard_unit = new();
    cg_hazard_unit.set_inst_name("hazard_unit_cov");
  endfunction

  /// @brief Samples the covergroup for one transaction and republishes the running coverage percentage.
  virtual function void write(pkt t);
    this.tr = t;
    cg_hazard_unit.sample();
    uvm_config_db#(real)::set(null, "*", "cov_status", cg_hazard_unit.get_inst_coverage());
  endfunction

endclass
