/**
 * @file scoreboard.sv
 * @brief Scoreboard that checks register-file transactions against the golden reference model.
 *
 * @details Receives monitored transactions and validates them against the DPI-C
 *          reference model implemented in the C source file.
 * @ingroup uvm_components
 */
/**
 * @brief DPI-C import of the golden reference model (see `reference_model.c`).
 *
 * @details The model is stateful: it keeps its own copy of the registers, so it
 *          must be called once per transaction, in order.
 *
 * @param write_en    Register-file write enable.
 * @param write_data  Data to write.
 * @param write_addr  Destination register address.
 * @param instr       Instruction whose rs1/rs2 fields select the registers to read.
 * @param exp_rs1     Output: expected `o_rs1_ID`.
 * @param exp_rs2     Output: expected `o_rs2_ID`.
 */
import "DPI-C" function void register_file_golden(
  input byte unsigned write_en,
  input int unsigned write_data,
  input byte unsigned write_addr,
  input int unsigned instr,
  output int unsigned exp_rs1,
  output int unsigned exp_rs2
);

/**
 * @class scoreboard
 * @brief UVM scoreboard for register-file functional checking.
 *
 * @details Compares the monitored read data with the DPI-C reference model and
 *          reports mismatches as test failures.
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

  /// @brief Analysis-port callback: checks one monitored transaction against `register_file_golden`.
  virtual function void write(pkt data);
    int unsigned exp_rs1;
    int unsigned exp_rs2;

    register_file_golden(data.i_write_en_WB, data.i_data_WB, data.i_rd_WB,
      data.i_instr_ID, exp_rs1, exp_rs2);

    if (data.o_rs1_ID == exp_rs1 && data.o_rs2_ID == exp_rs2) begin
      `uvm_info("SCOREBOARD",
        $sformatf("PASS: write_en=%0b write_addr=%0d write_data=%08h instr=%08h -> rs1=%08h rs2=%08h",
          data.i_write_en_WB, data.i_rd_WB, data.i_data_WB, data.i_instr_ID,
          data.o_rs1_ID, data.o_rs2_ID), UVM_LOW)
    end else begin
      `uvm_error("SCOREBOARD",
        $sformatf("FAIL: write_en=%0b write_addr=%0d write_data=%08h instr=%08h EXPECTED rs1=%08h rs2=%08h GOT rs1=%08h rs2=%08h",
          data.i_write_en_WB, data.i_rd_WB, data.i_data_WB, data.i_instr_ID,
          exp_rs1, exp_rs2, data.o_rs1_ID, data.o_rs2_ID))
      num_errors++;
    end
  endfunction

  /// @brief Fails the test if any mismatch was recorded by `write()`.
  virtual function void check_phase(uvm_phase phase);
    super.check_phase(phase);
    if (num_errors > 0) begin
      `uvm_fatal("FINAL_RESULT",
        $sformatf("TEST FAILED: Scoreboard found %0d errors.", num_errors))
    end else begin
      `uvm_info("FINAL_RESULT", "TEST PASS: All transactions were correct.", UVM_NONE)
    end
  endfunction

endclass
