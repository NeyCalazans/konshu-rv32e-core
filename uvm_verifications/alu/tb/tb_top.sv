/**
 * @file tb_top.sv
 * @ingroup tb_components
 * @brief Top-level testbench that instantiates the DUT, interface, and UVM test.
 *
 * @details Connects `s_interface`, the `alu_wrapper` DUT, and the UVM test entry
 *          point in a single simulation environment.
 */
 
`timescale 1ns/1ps

module tb_top;
    import alu_pkg::*;
    import uvm_pkg::*;

    bit clk;
    bit rst;

    s_interface vif (.clk(clk), .reset(rst));

    alu_wrapper U_ALU_WRAPPER (.vif(vif));

    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    initial begin
        rst = 0;
        #55 rst = 1;
    end

    initial begin
        uvm_config_db #(virtual s_interface)::set(null, "*", "vif", vif);
        run_test("test");
    end
endmodule
