/**
 * @file pkt.sv
 * @brief Transaction item used to model one hazard-unit evaluation in the UVM environment.
 *
 * @details Encapsulates the pipeline-register addresses and control bits driven
 *          into the hazard unit, plus the stall/flush/forward fields sampled back from it.
 * @ingroup uvm_components
 */
/**
 * @class pkt
 * @brief Sequence item that models one hazard-unit evaluation (stimulus + expected response fields).
 *
 * @details Carries the fields randomized by the sequence/driver, and the result
 *          fields filled in by the monitor for the scoreboard to check against the
 *          golden reference model.
 */
class pkt extends uvm_sequence_item;

  rand logic [3:0] i_rs1Addr_ID;    ///< rs1 address at Decode.
  rand logic [3:0] i_rs2Addr_ID;    ///< rs2 address at Decode.
  rand logic [3:0] i_rdAddr_EX;     ///< rd address at Execute.
  rand logic [3:0] i_rs1Addr_EX;    ///< rs1 address at Execute.
  rand logic [3:0] i_rs2Addr_EX;    ///< rs2 address at Execute.
  rand logic       i_pcSrc_EX;      ///< PC-redirect flag at Execute.
  rand logic [1:0] i_result_src_EX; ///< Write-back source select at Execute.
  rand logic [3:0] i_rdAddr_M;      ///< rd address at Memory.
  rand logic       i_reg_write_M;   ///< Register-file write enable at Memory.
  rand logic [3:0] i_rdAddr_WB;     ///< rd address at WriteBack.
  rand logic       i_reg_write_WB;  ///< Register-file write enable at WriteBack.

  logic       o_stall_IF;        ///< Sampled by the monitor.
  logic       o_stall_ID;        ///< Sampled by the monitor.
  logic       o_flush_ID;        ///< Sampled by the monitor.
  logic       o_flush_EX;        ///< Sampled by the monitor.
  logic [1:0] o_forward_rs1_EX;  ///< Sampled by the monitor.
  logic [1:0] o_forward_rs2_EX;  ///< Sampled by the monitor.

  `uvm_object_utils_begin(pkt)
    `uvm_field_int (i_rs1Addr_ID, UVM_DEFAULT)
    `uvm_field_int (i_rs2Addr_ID, UVM_DEFAULT)
    `uvm_field_int (i_rdAddr_EX, UVM_DEFAULT)
    `uvm_field_int (i_rs1Addr_EX, UVM_DEFAULT)
    `uvm_field_int (i_rs2Addr_EX, UVM_DEFAULT)
    `uvm_field_int (i_pcSrc_EX, UVM_DEFAULT)
    `uvm_field_int (i_result_src_EX, UVM_DEFAULT)
    `uvm_field_int (i_rdAddr_M, UVM_DEFAULT)
    `uvm_field_int (i_reg_write_M, UVM_DEFAULT)
    `uvm_field_int (i_rdAddr_WB, UVM_DEFAULT)
    `uvm_field_int (i_reg_write_WB, UVM_DEFAULT)
    `uvm_field_int (o_stall_IF, UVM_DEFAULT)
    `uvm_field_int (o_stall_ID, UVM_DEFAULT)
    `uvm_field_int (o_flush_ID, UVM_DEFAULT)
    `uvm_field_int (o_flush_EX, UVM_DEFAULT)
    `uvm_field_int (o_forward_rs1_EX, UVM_DEFAULT)
    `uvm_field_int (o_forward_rs2_EX, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "pkt");
      super.new(name);
  endfunction

endclass
