/**
 * @defgroup rtl_design RTL design
 * @brief Register-transfer-level implementation of the control-unit DUT.
 */
/**
 * @file control_unit_wrapper.sv
 * @brief Thin combinational wrapper around @ref control_unit, used as the DUT.
 *
 * @details `control_unit` (and the `op_decoder`/`alu_decoder` it instantiates) has
 *          no internal state, so the wrapper simply wires the `s_interface.dut`
 *          modport straight into it, with no clock/reset logic.
 * @ingroup rtl_design
 */
module control_unit_wrapper (
    s_interface.dut vif
);

    control_unit U_CONTROL_UNIT (
        .i_op(vif.op),
        .i_funct_3(vif.funct3),
        .i_funct_7_5(vif.funct7_5),
        .i_branch_EX(vif.branch_ex),
        .i_jump_EX(vif.jump_ex),
        .i_zero(vif.zero),
        .o_pc_src_EX(vif.pc_src_ex),
        .o_jump_ID(vif.jump_id),
        .o_branch_ID(vif.branch_id),
        .o_reg_write_ID(vif.reg_write_id),
        .o_result_src_ID(vif.result_src_id),
        .o_mem_write_ID(vif.mem_write_id),
        .o_alu_src_ID(vif.alu_src_id),
        .o_imm_src_ID(vif.imm_src_id),
        .o_alu_ctrl_ID(vif.alu_ctrl_id),
        .o_addr_src_ID(vif.addr_src_id),
        .o_fence_ID(vif.fence_id)
    );

endmodule
