/**
 * @file scoreboard.sv
 * @brief Scoreboard that checks extend-unit transactions against the golden reference model.
 *
 * @details Receives monitored transactions and validates them against the DPI-C
 *          reference model implemented in the C source file.
 * @ingroup uvm_components
 */
/**
 * @brief DPI-C import of the golden reference model (see `reference_model.c`).
 *
 * @param imm_src    Immediate format selector.
 * @param imm_id     Raw instr[31:7] slice.
 * @param exp_imm_ex Expected `o_imm_ex_ID`.
 */
import "DPI-C" function void extend_unit_golden(
  input  int unsigned imm_src,
  input  int unsigned imm_id,
  output int unsigned exp_imm_ex
);

/**
 * @class scoreboard
 * @brief UVM scoreboard for extend-unit functional checking.
 *
 * @details Compares monitored extend-unit inputs/outputs with the DPI-C reference
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

  /// @brief Analysis-port callback: checks one monitored transaction against `extend_unit_golden`.
  virtual function void write(pkt data);
    logic [31:0] exp_imm_ex;

    extend_unit_golden(data.i_imm_src_ID, data.i_imm_ID, exp_imm_ex);

    if (data.o_imm_ex_ID == exp_imm_ex) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS: imm_src=%0d imm_id=%0h imm_ex=%0h",
          data.i_imm_src_ID, data.i_imm_ID, data.o_imm_ex_ID),
        UVM_LOW)
    end
    else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL: imm_src=%0d imm_id=%0h EXPECTED imm_ex=%0h GOT imm_ex=%0h",
          data.i_imm_src_ID, data.i_imm_ID, exp_imm_ex, data.o_imm_ex_ID))
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
