/**
 * @defgroup rtl_design RTL design
 * @brief Register-transfer-level implementation of the hazard-unit DUT.
 */
/**
 * @file hazard_unit_wrapper.sv
 * @brief Thin combinational wrapper around @ref hazard_unit, used as the DUT.
 *
 * @details `hazard_unit` has no internal state, so the wrapper simply wires the
 *          `s_interface.dut` modport straight into it, with no clock/reset logic.
 * @ingroup rtl_design
 */
module hazard_unit_wrapper (
    s_interface.dut vif
);

    hazard_unit #(
        .REG_WIDTH(4)
    ) U_HAZARD_UNIT (
        .i_rs1Addr_ID    (vif.rs1_addr_id),
        .i_rs2Addr_ID    (vif.rs2_addr_id),
        .i_rdAddr_EX     (vif.rd_addr_ex),
        .i_rs1Addr_EX    (vif.rs1_addr_ex),
        .i_rs2Addr_EX    (vif.rs2_addr_ex),
        .i_pcSrc_EX      (vif.pc_src_ex),
        .i_result_src_EX (vif.result_src_ex),
        .i_rdAddr_M      (vif.rd_addr_m),
        .i_reg_write_M   (vif.reg_write_m),
        .i_rdAddr_WB     (vif.rd_addr_wb),
        .i_reg_write_WB  (vif.reg_write_wb),
        .o_stall_IF      (vif.stall_if),
        .o_stall_ID      (vif.stall_id),
        .o_flush_EX      (vif.flush_ex),
        .o_flush_ID      (vif.flush_id),
        .o_forward_rs1_EX(vif.forward_rs1_ex),
        .o_forward_rs2_EX(vif.forward_rs2_ex)
    );

endmodule
