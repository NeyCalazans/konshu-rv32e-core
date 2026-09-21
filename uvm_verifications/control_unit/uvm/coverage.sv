/**
 * @file coverage.sv
 * @brief Coverage collector for control-unit transactions.
 *
 * @details Samples observed control-unit transactions and updates the coverage model
 *          used to determine whether the verification goal has been reached.
 * @ingroup uvm_components
 */
/**
 * @class coverage
 * @brief UVM coverage subscriber for control-unit transaction sampling.
 *
 * @details Tracks opcode x funct3 x funct7[5] cross coverage (the decode space
 *          that selects `o_alu_ctrl_ID`/`o_imm_src_ID`/etc.), plus the
 *          branch/jump/zero cross that drives `o_pc_src_EX`. Publishes the current
 *          percentage to the sequence layer through the configuration database
 *          under the key `"cov_status"`.
 */
class coverage extends uvm_subscriber #(pkt);
  `uvm_component_utils(coverage)

  pkt tr;  ///< Transaction currently being sampled by `cg_control_unit`.

  /// Decode-space and PC-redirect coverage model.
  covergroup cg_control_unit;
    option.per_instance = 1;

    /// One bin per RV32I base opcode this design implements (see op_decoder.v).
    cp_op: coverpoint tr.i_op {
      bins op_load   = {5'b00000};
      bins op_imm    = {5'b00100};
      bins op_auipc  = {5'b00101};
      bins op_store  = {5'b01000};
      bins op_reg    = {5'b01100};
      bins op_lui    = {5'b01101};
      bins op_branch = {5'b11000};
      bins op_jalr   = {5'b11001};
      bins op_jal    = {5'b11011};
    }

    /// All 8 funct3 codes.
    cp_funct3: coverpoint tr.i_funct_3 {
      bins values[8] = {[0:7]};
    }

    /// Both funct7[5] states (ADD/SUB and SRL/SRA discriminator).
    cp_funct7_5: coverpoint tr.i_funct_7_5 {
      bins values[2] = {[0:1]};
    }

    /// Both states of the registered branch/jump/zero-flag inputs, to exercise
    /// every path through o_pc_src_EX = (zero && branch_EX) || jump_EX.
    /// Both states of the registered branch flag at Execute.
    cp_branch_ex: coverpoint tr.i_branch_EX {
      bins values[2] = {[0:1]};
    }

    /// Both states of the registered jump flag at Execute.
    cp_jump_ex: coverpoint tr.i_jump_EX {
      bins values[2] = {[0:1]};
    }

    /// Both states of the ALU zero/branch-comparison flag.
    cp_zero: coverpoint tr.i_zero {
      bins values[2] = {[0:1]};
    }

    /// Crosses branch, jump and zero so every path to `o_pc_src_EX` is exercised.
    cp_cross_pc_src: cross cp_branch_ex, cp_jump_ex, cp_zero;

    /// Exercises every (opcode, funct3, funct7[5]) combination this design can see.
    cp_cross_decode: cross cp_op, cp_funct3, cp_funct7_5 {
      // funct3 == 3'b010/3'b011 are reserved (not real branch conditions) and
      // excluded by pkt.sv's branch_funct3_valid constraint, so these bins can
      // never be hit.
      ignore_bins reserved_branch_funct3 =
          binsof(cp_op.op_branch) && binsof(cp_funct3) intersect {2, 3};
    }

  endgroup

  function new(string name = "coverage", uvm_component parent);
    super.new(name, parent);
    cg_control_unit = new();
    cg_control_unit.set_inst_name("control_unit_cov");
  endfunction

  /// @brief Samples the covergroup for one transaction and republishes the running coverage percentage.
  virtual function void write(pkt t);
    this.tr = t;
    cg_control_unit.sample();
    uvm_config_db#(real)::set(null, "*", "cov_status", cg_control_unit.get_inst_coverage());
  endfunction

endclass
