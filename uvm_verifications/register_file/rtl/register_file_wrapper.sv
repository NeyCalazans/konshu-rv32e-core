/**
 * @file register_file_wrapper.sv
 * @brief Wrapper that connects the register-file RTL to the UVM interface.
 */
module register_file_wrapper (
    s_interface.dut vif
);

    register_file U_REGISTER_FILE (
        .clk(vif.clk),
        .i_rst_ID(~vif.reset),
        .i_write_en_WB(vif.write_en),
        .i_data_WB(vif.write_data),
        .i_rd_WB(vif.write_addr),
        .i_instr_ID(vif.instr),
        .o_rs1_ID(vif.rs1_data),
        .o_rs2_ID(vif.rs2_data)
    );

endmodule