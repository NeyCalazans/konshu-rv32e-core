/**
 * @file coverage.sv
 * @brief Coverage collector for register-file transactions.
 *
 * @details Samples observed register-file transactions and updates the coverage model
 *          used to determine whether the verification goal has been reached.
 * @ingroup uvm_components
 */
/**
 * @class coverage
 * @brief UVM coverage subscriber for register-file transaction sampling.
 *
 * @details Tracks the possible values of the write enable, write address, and
 *          both read addresses, including their direct cross coverage. Publishes the
 *          current percentage to the sequence layer through the configuration database
 *          under the key `"cov_status"`.
 */
class coverage extends uvm_subscriber #(pkt);
  `uvm_component_utils(coverage)

  pkt tr;  ///< Transaction currently being sampled by `cg_register_file`.

  /// Write enable x write address x rs1 address x rs2 address cross coverage model.
  covergroup cg_register_file;
    option.per_instance = 1;

    /// Both write-enable states, so writes and non-writes are exercised.
    cp_write_enable: coverpoint tr.i_write_en_WB {
      bins disabled = {0};
      bins enabled = {1};
    }

    /// One bin per register (x0..x15) as write destination; x0 writes must be ignored.
    cp_write_address: coverpoint tr.i_rd_WB {
      bins registers[16] = {[0:15]};
    }

    /// One bin per register read through rs1 (instr[18:15]).
    cp_rd1_address: coverpoint tr.i_instr_ID[18:15] {
      bins registers[16] = {[0:15]};
    }

    /// One bin per register read through rs2 (instr[23:20]).
    cp_rd2_address: coverpoint tr.i_instr_ID[23:20] {
      bins registers[16] = {[0:15]};
    }

    /// Full cross of write enable/address with both read addresses, so every
    /// read-after-write combination (including same-cycle bypass) is hit.
    cross_register_file: cross cp_write_enable, cp_write_address, cp_rd1_address, cp_rd2_address;

  endgroup

  function new(string name = "coverage", uvm_component parent);
    super.new(name, parent);
    cg_register_file = new();
    cg_register_file.set_inst_name("register_file_cov");
  endfunction

  /// @brief Samples the covergroup for one transaction and republishes the running coverage percentage.
  virtual function void write(pkt t);
    this.tr = t;
    cg_register_file.sample();
    uvm_config_db#(real)::set(null, "*", "cov_status", cg_register_file.get_inst_coverage());
  endfunction

endclass
