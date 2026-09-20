/**
 * @file pkt.sv
 * @brief Transaction item used to model one extend-unit operation in the UVM environment.
 *
 * @details Encapsulates the immediate-format selector and raw immediate bits driven
 *          into the extend unit, plus the extended immediate sampled back from it.
 * @ingroup uvm_components
 */
/**
 * @class pkt
 * @brief Sequence item that models one extend-unit operation (stimulus + expected response fields).
 *
 * @details Carries the fields randomized by the sequence/driver, and the result
 *          field filled in by the monitor for the scoreboard to check against the
 *          golden reference model.
 */
class pkt extends uvm_sequence_item;

  rand logic [2:0]  i_imm_src_ID;  ///< Immediate format selector to drive (0..4 = I/S/B/J/U; 5..7 reserved).
  rand logic [24:0] i_imm_ID;      ///< Raw instr[31:7] slice to drive.
  logic [31:0]      o_imm_ex_ID;   ///< Sign-extended immediate, sampled by the monitor.

  `uvm_object_utils_begin(pkt)
    `uvm_field_int (i_imm_src_ID, UVM_DEFAULT)
    `uvm_field_int (i_imm_ID, UVM_DEFAULT)
    `uvm_field_int (o_imm_ex_ID, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "pkt");
      super.new(name);
  endfunction

endclass
