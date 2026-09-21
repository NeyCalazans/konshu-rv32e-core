/**
 * @file pkt.sv
 * @brief Transaction item used to model one control-unit decode in the UVM environment.
 *
 * @details Encapsulates the instruction fields and EX-stage feedback driven into
 *          the control unit, plus the control signals sampled back from it.
 * @ingroup uvm_components
 */
/**
 * @class pkt
 * @brief Sequence item that models one control-unit decode (stimulus + expected response fields).
 *
 * @details Carries the fields randomized by the sequence/driver, and the result
 *          fields filled in by the monitor for the scoreboard to check against the
 *          golden reference model.
 */
class pkt extends uvm_sequence_item;

  rand logic [4:0] i_op;         ///< RV32I base opcode, instr[6:2].
  rand logic [2:0] i_funct_3;    ///< instr[14:12].
  rand logic       i_funct_7_5;  ///< instr[30].
  rand logic       i_branch_EX;  ///< Registered o_branch_ID at Execute.
  rand logic       i_jump_EX;    ///< Registered o_jump_ID at Execute.
  rand logic       i_zero;       ///< ALU branch-comparison result.

  logic       o_pc_src_EX;      ///< Sampled by the monitor.
  logic       o_jump_ID;        ///< Sampled by the monitor.
  logic       o_branch_ID;      ///< Sampled by the monitor.
  logic       o_reg_write_ID;   ///< Sampled by the monitor.
  logic [1:0] o_result_src_ID;  ///< Sampled by the monitor.
  logic       o_mem_write_ID;   ///< Sampled by the monitor.
  logic [4:0] o_alu_ctrl_ID;    ///< Sampled by the monitor.
  logic       o_alu_src_ID;     ///< Sampled by the monitor.
  logic       o_addr_src_ID;    ///< Sampled by the monitor.
  logic [2:0] o_imm_src_ID;     ///< Sampled by the monitor.
  logic       o_fence_ID;       ///< Sampled by the monitor.

  `uvm_object_utils_begin(pkt)
    `uvm_field_int (i_op, UVM_DEFAULT)
    `uvm_field_int (i_funct_3, UVM_DEFAULT)
    `uvm_field_int (i_funct_7_5, UVM_DEFAULT)
    `uvm_field_int (i_branch_EX, UVM_DEFAULT)
    `uvm_field_int (i_jump_EX, UVM_DEFAULT)
    `uvm_field_int (i_zero, UVM_DEFAULT)
    `uvm_field_int (o_pc_src_EX, UVM_DEFAULT)
    `uvm_field_int (o_jump_ID, UVM_DEFAULT)
    `uvm_field_int (o_branch_ID, UVM_DEFAULT)
    `uvm_field_int (o_reg_write_ID, UVM_DEFAULT)
    `uvm_field_int (o_result_src_ID, UVM_DEFAULT)
    `uvm_field_int (o_mem_write_ID, UVM_DEFAULT)
    `uvm_field_int (o_alu_ctrl_ID, UVM_DEFAULT)
    `uvm_field_int (o_alu_src_ID, UVM_DEFAULT)
    `uvm_field_int (o_addr_src_ID, UVM_DEFAULT)
    `uvm_field_int (o_imm_src_ID, UVM_DEFAULT)
    `uvm_field_int (o_fence_ID, UVM_DEFAULT)
  `uvm_object_utils_end

  /// Restricts the randomized opcode to the opcodes whose o_alu_ctrl_ID/o_alu_src_ID
  /// have a real, checkable answer (i.e. the instruction writes a register or
  /// touches memory). FENCE and SYSTEM (ECALL/EBREAK) are excluded: they never use
  /// the ALU result, so there is no defined expected value for those two fields.
  constraint op_range {
    i_op inside {5'b00000, 5'b00100, 5'b00101, 5'b01000,
                 5'b01100, 5'b01101, 5'b11000, 5'b11001, 5'b11011};
  }

  /// RV32I only defines 6 branch conditions (BEQ/BNE/BLT/BGE/BLTU/BGEU);
  /// funct3 == 3'b010/3'b011 are reserved and don't correspond to a real branch.
  constraint branch_funct3_valid {
    (i_op == 5'b11000) -> i_funct_3 inside {3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111};
  }

  function new(string name = "pkt");
      super.new(name);
  endfunction

endclass
