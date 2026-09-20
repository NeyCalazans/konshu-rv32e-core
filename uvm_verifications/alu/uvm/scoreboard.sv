/**
 * @file scoreboard.sv
 * @brief Scoreboard that checks ALU transactions against the golden reference model.
 *
 * @details Receives monitored transactions and validates them against the DPI-C
 *          reference model implemented in the C source file.
 * @ingroup uvm_components
 */
/**
 * @brief DPI-C import of the golden reference model (see `reference_model.c`).
 *
 * @param alu_ctrl   ALU opcode.
 * @param rd1        Operand rs1.
 * @param rd2        Operand rs2.
 * @param exp_result Expected `o_alu_result_EX`.
 * @param exp_equal  Expected `o_equal_EX` (only the low bit is meaningful).
 */
import "DPI-C" function void alu_golden(
  input  int          alu_ctrl,
  input  int unsigned rd1,
  input  int unsigned rd2,
  output int unsigned exp_result,
  output byte unsigned exp_equal
);

/**
 * @class scoreboard
 * @brief UVM scoreboard for ALU functional checking.
 *
 * @details Compares monitored ALU inputs/outputs with the DPI-C reference model
 *          and reports mismatches as test failures.
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

  /// @brief Analysis-port callback: checks one monitored transaction against `alu_golden`.
  virtual function void write(pkt data);
    logic [31:0] exp_result;
    byte unsigned exp_equal_raw;
    logic exp_equal;

    alu_golden(data.i_alu_ctrl_EX, data.i_rd1_EX, data.i_rd2_EX, exp_result, exp_equal_raw);
    exp_equal = exp_equal_raw[0];

    if (data.o_alu_result_EX == exp_result && data.o_equal_EX == exp_equal) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS: ctrl=%0d rd1=%0h rd2=%0h result=%0h equal=%0b",
          data.i_alu_ctrl_EX, data.i_rd1_EX, data.i_rd2_EX, data.o_alu_result_EX, data.o_equal_EX),
        UVM_LOW)
    end
    else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL: ctrl=%0d rd1=%0h rd2=%0h EXPECTED result=%0h equal=%0b GOT result=%0h equal=%0b",
          data.i_alu_ctrl_EX, data.i_rd1_EX, data.i_rd2_EX,
          exp_result, exp_equal, data.o_alu_result_EX, data.o_equal_EX))
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