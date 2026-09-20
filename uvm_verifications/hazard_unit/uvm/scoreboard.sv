/**
 * @file scoreboard.sv
 * @brief Scoreboard that checks hazard-unit transactions against the golden reference model.
 *
 * @details Receives monitored transactions and validates them against the DPI-C
 *          reference model implemented in the C source file.
 * @ingroup uvm_components
 */
/**
 * @brief DPI-C import of the golden reference model (see `reference_model.c`).
 *
 * @param rs1_id             rs1 address at Decode.
 * @param rs2_id             rs2 address at Decode.
 * @param rd_ex              rd address at Execute.
 * @param rs1_ex             rs1 address at Execute.
 * @param rs2_ex             rs2 address at Execute.
 * @param pc_src_ex          PC-redirect flag at Execute.
 * @param result_src_ex      Write-back source select at Execute.
 * @param rd_m               rd address at Memory.
 * @param reg_write_m        Register-file write enable at Memory.
 * @param rd_wb              rd address at WriteBack.
 * @param reg_write_wb       Register-file write enable at WriteBack.
 * @param exp_stall_if       Output: expected o_stall_IF.
 * @param exp_stall_id       Output: expected o_stall_ID.
 * @param exp_flush_id       Output: expected o_flush_ID.
 * @param exp_flush_ex       Output: expected o_flush_EX.
 * @param exp_forward_rs1_ex Output: expected o_forward_rs1_EX.
 * @param exp_forward_rs2_ex Output: expected o_forward_rs2_EX.
 */
import "DPI-C" function void hazard_unit_golden(
  input  int unsigned rs1_id,
  input  int unsigned rs2_id,
  input  int unsigned rd_ex,
  input  int unsigned rs1_ex,
  input  int unsigned rs2_ex,
  input  byte unsigned pc_src_ex,
  input  int unsigned result_src_ex,
  input  int unsigned rd_m,
  input  byte unsigned reg_write_m,
  input  int unsigned rd_wb,
  input  byte unsigned reg_write_wb,
  output byte unsigned exp_stall_if,
  output byte unsigned exp_stall_id,
  output byte unsigned exp_flush_id,
  output byte unsigned exp_flush_ex,
  output int unsigned exp_forward_rs1_ex,
  output int unsigned exp_forward_rs2_ex
);

/**
 * @class scoreboard
 * @brief UVM scoreboard for hazard-unit functional checking.
 *
 * @details Compares monitored hazard-unit inputs/outputs with the DPI-C reference
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

  /// @brief Analysis-port callback: checks one monitored transaction against `hazard_unit_golden`.
  virtual function void write(pkt data);
    byte unsigned exp_stall_if_raw, exp_stall_id_raw, exp_flush_id_raw, exp_flush_ex_raw;
    logic [1:0] exp_forward_rs1_ex, exp_forward_rs2_ex;
    logic exp_stall_if, exp_stall_id, exp_flush_id, exp_flush_ex;

    hazard_unit_golden(data.i_rs1Addr_ID, data.i_rs2Addr_ID, data.i_rdAddr_EX,
      data.i_rs1Addr_EX, data.i_rs2Addr_EX, data.i_pcSrc_EX, data.i_result_src_EX,
      data.i_rdAddr_M, data.i_reg_write_M, data.i_rdAddr_WB, data.i_reg_write_WB,
      exp_stall_if_raw, exp_stall_id_raw, exp_flush_id_raw, exp_flush_ex_raw,
      exp_forward_rs1_ex, exp_forward_rs2_ex);

    exp_stall_if = exp_stall_if_raw[0];
    exp_stall_id = exp_stall_id_raw[0];
    exp_flush_id = exp_flush_id_raw[0];
    exp_flush_ex = exp_flush_ex_raw[0];

    if (data.o_stall_IF == exp_stall_if && data.o_stall_ID == exp_stall_id &&
        data.o_flush_ID == exp_flush_id && data.o_flush_EX == exp_flush_ex &&
        data.o_forward_rs1_EX == exp_forward_rs1_ex && data.o_forward_rs2_EX == exp_forward_rs2_ex) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS: stallIF=%0b stallID=%0b flushID=%0b flushEX=%0b fwd1=%0d fwd2=%0d",
          data.o_stall_IF, data.o_stall_ID, data.o_flush_ID, data.o_flush_EX,
          data.o_forward_rs1_EX, data.o_forward_rs2_EX),
        UVM_LOW)
    end
    else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL: rs1_id=%0d rs2_id=%0d rd_ex=%0d rs1_ex=%0d rs2_ex=%0d pcSrc=%0b resSrc=%0d rd_m=%0d rw_m=%0b rd_wb=%0d rw_wb=%0b EXPECTED stallIF=%0b stallID=%0b flushID=%0b flushEX=%0b fwd1=%0d fwd2=%0d GOT stallIF=%0b stallID=%0b flushID=%0b flushEX=%0b fwd1=%0d fwd2=%0d",
          data.i_rs1Addr_ID, data.i_rs2Addr_ID, data.i_rdAddr_EX, data.i_rs1Addr_EX, data.i_rs2Addr_EX,
          data.i_pcSrc_EX, data.i_result_src_EX, data.i_rdAddr_M, data.i_reg_write_M,
          data.i_rdAddr_WB, data.i_reg_write_WB,
          exp_stall_if, exp_stall_id, exp_flush_id, exp_flush_ex, exp_forward_rs1_ex, exp_forward_rs2_ex,
          data.o_stall_IF, data.o_stall_ID, data.o_flush_ID, data.o_flush_EX,
          data.o_forward_rs1_EX, data.o_forward_rs2_EX))
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
