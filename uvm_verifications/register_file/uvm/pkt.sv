/**
 * @file pkt.sv
 * @brief Transaction item used to model one register-file access in the UVM environment.
 *
 * @details Encapsulates the write-back write port and the instruction whose
 *          rs1/rs2 fields select the registers to read, plus the read data
 *          sampled back from the register file.
 * @ingroup uvm_components
 */
/**
 * @class pkt
 * @brief Sequence item that models one register-file access.
 *
 * @details Carries the fields randomized by the sequence/driver, and the result
 *          fields filled in by the monitor for the scoreboard to check against the
 *          golden reference model.
 */
class pkt extends uvm_sequence_item;

  rand logic        i_write_en_WB;  ///< Register-file write enable at WriteBack.
  rand logic [31:0] i_data_WB;      ///< Data to write at WriteBack.
  rand logic [3:0]  i_rd_WB;        ///< Destination register address at WriteBack.
  rand logic [31:0] i_instr_ID;     ///< Instruction at Decode; rs1 = instr[18:15], rs2 = instr[23:20].

  logic [31:0] o_rs1_ID;            ///< Data read for rs1, sampled by the monitor.
  logic [31:0] o_rs2_ID;            ///< Data read for rs2, sampled by the monitor.

  `uvm_object_utils_begin(pkt)
    `uvm_field_int (i_write_en_WB, UVM_DEFAULT)
    `uvm_field_int (i_data_WB, UVM_DEFAULT)
    `uvm_field_int (i_rd_WB, UVM_DEFAULT)
    `uvm_field_int (i_instr_ID, UVM_DEFAULT)
    `uvm_field_int (o_rs1_ID, UVM_DEFAULT)
    `uvm_field_int (o_rs2_ID, UVM_DEFAULT)
  `uvm_object_utils_end

  function new(string name = "pkt");
      super.new(name);
  endfunction

endclass
