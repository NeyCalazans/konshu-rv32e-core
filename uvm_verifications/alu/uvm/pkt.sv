/**
 * @file pkt.sv
 * @brief Transaction item used to model one ALU operation in the UVM environment.
 *
 * @details Encapsulates the opcode and operands driven into the ALU, plus the
 *          result and equal flag sampled back from it.
 * @ingroup uvm_components
 */
/**
 * @class pkt
 * @brief Sequence item that models one ALU operation (stimulus + expected response fields).
 *
 * @details Carries the opcode and operands randomized by the sequence/driver,
 *          and the result/equal fields filled in by the monitor for the scoreboard
 *          to check against the golden reference model.
 */
class pkt extends uvm_sequence_item;

  rand logic [4:0] i_alu_ctrl_EX;  ///< ALU opcode to drive.
  rand logic [31:0] i_rd1_EX;      ///< Operand rs1 to drive.
  rand logic [31:0] i_rd2_EX;      ///< Operand rs2 to drive.
  logic [31:0] o_alu_result_EX;    ///< ALU result, sampled by the monitor.
  logic o_equal_EX;                ///< Comparison/branch-taken flag, sampled by the monitor.

  `uvm_object_utils_begin(pkt)
    `uvm_field_int (i_alu_ctrl_EX, UVM_DEFAULT)
    `uvm_field_int (i_rd1_EX, UVM_DEFAULT)
    `uvm_field_int (i_rd2_EX, UVM_DEFAULT)
    `uvm_field_int (o_alu_result_EX, UVM_DEFAULT)
    `uvm_field_int(o_equal_EX, UVM_DEFAULT)
  `uvm_object_utils_end

  /// Restricts the randomized opcode to the 21 opcodes implemented by the ALU (see alu.v).
  constraint alu_ctrl_range {
    i_alu_ctrl_EX inside {[0:20]};
  }

  function new(string name = "pkt");
      super.new(name);
  endfunction

endclass
