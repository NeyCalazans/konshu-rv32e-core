/**
 * @file scoreboard.sv
 * @brief Scoreboard that checks control-unit transactions against the golden reference model.
 *
 * @details Receives monitored transactions and validates them against the DPI-C
 *          reference model implemented in the C source file.
 * @ingroup uvm_components
 */
/**
 * @brief DPI-C import of the golden reference model (see `reference_model.c`).
 *
 * @param op                instr[6:2].
 * @param funct3            instr[14:12].
 * @param funct7_5          instr[30].
 * @param branch_ex         Registered o_branch_ID at Execute.
 * @param jump_ex           Registered o_jump_ID at Execute.
 * @param zero              ALU branch-comparison result.
 * @param exp_jump_id       Output: expected o_jump_ID.
 * @param exp_branch_id     Output: expected o_branch_ID.
 * @param exp_reg_write_id  Output: expected o_reg_write_ID.
 * @param exp_result_src_id Output: expected o_result_src_ID.
 * @param exp_mem_write_id  Output: expected o_mem_write_ID.
 * @param exp_alu_ctrl_id   Output: expected o_alu_ctrl_ID.
 * @param exp_alu_src_id    Output: expected o_alu_src_ID.
 * @param exp_addr_src_id   Output: expected o_addr_src_ID.
 * @param exp_imm_src_id    Output: expected o_imm_src_ID.
 * @param exp_fence_id      Output: expected o_fence_ID.
 * @param exp_pc_src_ex     Output: expected o_pc_src_EX.
 */
import "DPI-C" function void control_unit_golden(
  input  int unsigned op,
  input  int unsigned funct3,
  input  byte unsigned funct7_5,
  input  byte unsigned branch_ex,
  input  byte unsigned jump_ex,
  input  byte unsigned zero,
  output byte unsigned exp_jump_id,
  output byte unsigned exp_branch_id,
  output byte unsigned exp_reg_write_id,
  output int unsigned exp_result_src_id,
  output byte unsigned exp_mem_write_id,
  output int unsigned exp_alu_ctrl_id,
  output byte unsigned exp_alu_src_id,
  output byte unsigned exp_addr_src_id,
  output int unsigned exp_imm_src_id,
  output byte unsigned exp_fence_id,
  output byte unsigned exp_pc_src_ex
);

/**
 * @class scoreboard
 * @brief UVM scoreboard for control-unit functional checking.
 *
 * @details Compares monitored control-unit inputs/outputs with the DPI-C reference
 *          model and reports mismatches as test failures.
 */
class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_analysis_imp #(pkt, scoreboard) ap_imp;  ///< Receives transactions from the monitor's analysis port.

  int num_errors = 0;  ///< Number of mismatches found so far.

  function new(string name = "scoreboard", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  /// @brief Creates the analysis imp that receives transactions from the monitor.
  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ap_imp = new("ap_imp", this);
  endfunction

  /// @brief Analysis-port callback: checks one monitored transaction against `control_unit_golden`.
  virtual function void write(pkt data);
    byte unsigned jump_raw, branch_raw, reg_write_raw, mem_write_raw;
    byte unsigned alu_src_raw, addr_src_raw, fence_raw, pc_src_raw;
    logic [1:0] exp_result_src_id;
    logic [4:0] exp_alu_ctrl_id;
    logic [2:0] exp_imm_src_id;
    logic exp_jump_id, exp_branch_id, exp_reg_write_id, exp_mem_write_id;
    logic exp_alu_src_id, exp_addr_src_id, exp_fence_id, exp_pc_src_ex;

    control_unit_golden(data.i_op, data.i_funct_3, data.i_funct_7_5, data.i_branch_EX,
      data.i_jump_EX, data.i_zero,
      jump_raw, branch_raw, reg_write_raw, exp_result_src_id, mem_write_raw, exp_alu_ctrl_id,
      alu_src_raw, addr_src_raw, exp_imm_src_id, fence_raw, pc_src_raw);

    exp_jump_id = jump_raw[0];
    exp_branch_id = branch_raw[0];
    exp_reg_write_id = reg_write_raw[0];
    exp_mem_write_id = mem_write_raw[0];
    exp_alu_src_id = alu_src_raw[0];
    exp_addr_src_id = addr_src_raw[0];
    exp_fence_id = fence_raw[0];
    exp_pc_src_ex = pc_src_raw[0];

    if (data.o_jump_ID == exp_jump_id && data.o_branch_ID == exp_branch_id &&
        data.o_reg_write_ID == exp_reg_write_id && data.o_result_src_ID == exp_result_src_id &&
        data.o_mem_write_ID == exp_mem_write_id && data.o_alu_ctrl_ID == exp_alu_ctrl_id &&
        data.o_alu_src_ID == exp_alu_src_id &&
        data.o_addr_src_ID == exp_addr_src_id && data.o_imm_src_ID == exp_imm_src_id &&
        data.o_fence_ID == exp_fence_id && data.o_pc_src_EX == exp_pc_src_ex) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS: op=%0b f3=%0d f7_5=%0b -> jump=%0b branch=%0b regW=%0b resSrc=%0d memW=%0b aluCtrl=%0d aluSrc=%0b addrSrc=%0b immSrc=%0d fence=%0b pcSrc=%0b",
          data.i_op, data.i_funct_3, data.i_funct_7_5, data.o_jump_ID, data.o_branch_ID,
          data.o_reg_write_ID, data.o_result_src_ID, data.o_mem_write_ID, data.o_alu_ctrl_ID,
          data.o_alu_src_ID, data.o_addr_src_ID, data.o_imm_src_ID, data.o_fence_ID, data.o_pc_src_EX),
        UVM_LOW)
    end
    else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL: op=%0b f3=%0d f7_5=%0b branchEX=%0b jumpEX=%0b zero=%0b EXPECTED jump=%0b branch=%0b regW=%0b resSrc=%0d memW=%0b aluCtrl=%0d aluSrc=%0b addrSrc=%0b immSrc=%0d fence=%0b pcSrc=%0b GOT jump=%0b branch=%0b regW=%0b resSrc=%0d memW=%0b aluCtrl=%0d aluSrc=%0b addrSrc=%0b immSrc=%0d fence=%0b pcSrc=%0b",
          data.i_op, data.i_funct_3, data.i_funct_7_5, data.i_branch_EX, data.i_jump_EX, data.i_zero,
          exp_jump_id, exp_branch_id, exp_reg_write_id, exp_result_src_id, exp_mem_write_id,
          exp_alu_ctrl_id, exp_alu_src_id, exp_addr_src_id, exp_imm_src_id, exp_fence_id, exp_pc_src_ex,
          data.o_jump_ID, data.o_branch_ID, data.o_reg_write_ID, data.o_result_src_ID,
          data.o_mem_write_ID, data.o_alu_ctrl_ID, data.o_alu_src_ID, data.o_addr_src_ID,
          data.o_imm_src_ID, data.o_fence_ID, data.o_pc_src_EX))
      this.num_errors++;
    end
  endfunction

  /// @brief Fails the test if any mismatch was recorded by `write()`.
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (this.num_errors > 0) begin
      `uvm_fatal("FINAL_RESULT",
        $sformatf("TEST FAILED: Scoreboard found %0d errors.", num_errors))
    end
    else begin
      `uvm_info("FINAL_RESULT", "TEST PASS: All transactions were correct.", UVM_NONE)
    end
  endfunction

  /// @brief Run phase; unused, checking happens in `write()` and `check_phase()`.
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
  endtask

endclass
