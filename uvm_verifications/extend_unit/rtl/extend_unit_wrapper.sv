/**
 * @defgroup rtl_design RTL design
 * @brief Register-transfer-level implementation of the extend-unit DUT.
 */
/**
 * @file extend_unit_wrapper.sv
 * @brief Thin combinational wrapper around @ref extend_unit, used as the DUT.
 *
 * @details `extend_unit` has no internal state, so the wrapper simply wires the
 *          `s_interface.dut` modport straight into it, with no clock/reset logic.
 * @ingroup rtl_design
 */
module extend_unit_wrapper (
    s_interface.dut vif
);

    extend_unit #(
        .WIDTH (32),
        .OFFSET(7)
    ) U_EXTEND_UNIT (
        .i_imm_ID    (vif.imm_id),
        .i_imm_src_ID(vif.imm_src),
        .o_imm_ex_ID (vif.imm_ex)
    );

endmodule
