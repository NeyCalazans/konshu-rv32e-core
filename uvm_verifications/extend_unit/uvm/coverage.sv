/**
 * @file coverage.sv
 * @brief Coverage collector for extend-unit transactions.
 *
 * @details Samples observed extend-unit transactions and updates the coverage model
 *          used to determine whether the verification goal has been reached.
 * @ingroup uvm_components
 */
/**
 * @class coverage
 * @brief UVM coverage subscriber for extend-unit transaction sampling.
 *
 * @details Tracks imm_src x imm_id-quadrant cross coverage and publishes the
 *          current percentage to the sequence layer through the configuration database
 *          under the key `"cov_status"`.
 */
class coverage extends uvm_subscriber #(pkt);
  `uvm_component_utils(coverage)

  pkt tr;  ///< Transaction currently being sampled by `cg_extend_unit`.

  /// imm_src x imm_id-quadrant cross coverage model.
  covergroup cg_extend_unit;
    option.per_instance = 1;

    /// One bin per imm_src value: 0..4 are I/S/B/J/U, 5..7 exercise the RTL's default branch.
    cp_imm_src: coverpoint tr.i_imm_src_ID {
      bins formats[8] = {[0:7]};
    }

    /// Splits the full 25-bit imm_id range into 4 equal quadrants, so random stimulus
    /// hits every bin (a narrower range would make some bins statistically unreachable).
    cp_imm_id: coverpoint tr.i_imm_ID {
      bins low      = {[25'h000_0000:25'h07F_FFFF]};
      bins low_med  = {[25'h080_0000:25'h0FF_FFFF]};
      bins high_med = {[25'h100_0000:25'h17F_FFFF]};
      bins high     = {[25'h180_0000:25'h1FF_FFFF]};
    }

    /// Full cross of imm_src with the imm_id quadrants.
    cp_cross: cross cp_imm_src, cp_imm_id;

  endgroup

  function new(string name = "coverage", uvm_component parent);
    super.new(name, parent);
    cg_extend_unit = new();
    cg_extend_unit.set_inst_name("extend_unit_cov");
  endfunction

  /// @brief Samples the covergroup for one transaction and republishes the running coverage percentage.
  virtual function void write(pkt t);
    this.tr = t;
    cg_extend_unit.sample();
    uvm_config_db#(real)::set(null, "*", "cov_status", cg_extend_unit.get_inst_coverage());
  endfunction

endclass
