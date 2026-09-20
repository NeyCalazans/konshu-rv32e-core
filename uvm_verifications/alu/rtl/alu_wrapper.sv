/**
 * @defgroup rtl_design RTL design
 * @brief Register-transfer-level implementation of the ALU DUT.
 */
/**
 * @file alu_wrapper.sv
 * @brief Registered wrapper around the combinational @ref alu module, used as the DUT.
 *
 * @details Latches `i_alu_ctrl_EX`/`i_rd1_EX`/`i_rd2_EX` from the `s_interface.dut`
 *          modport on the rising edge of `clk`, feeds them into the combinational
 *          @ref alu instance, and registers the result back onto
 *          `vif.alu_result`/`vif.equal` a few time units later. Held at zero while
 *          `vif.reset` is deasserted (active-low).
 * @ingroup rtl_design
 */
module alu_wrapper (
	s_interface.dut vif
	);

	logic [4:0] i_alu_ctrl_EX;
	logic [31:0] i_rd1_EX;
	logic [31:0] i_rd2_EX;
	logic [31:0] o_alu_result_EX;
	logic o_equal_EX;

	alu #(.WIDTH(32)) U_ALU (.i_alu_ctrl_EX(i_alu_ctrl_EX),
								.i_rd1_EX(i_rd1_EX),
								.i_rd2_EX(i_rd2_EX),
								.o_alu_result_EX(o_alu_result_EX),
								.o_equal_EX(o_equal_EX)
								);

	always_ff @(posedge vif.clk or negedge vif.reset) begin
		if (!vif.reset) begin
			i_alu_ctrl_EX <= 'b0;
			i_rd1_EX <= 'b0;
			i_rd2_EX <= 'b0;
			vif.alu_result <= 'b0;
			vif.equal <= 'b0;
		end
		else begin
			i_alu_ctrl_EX <= vif.alu_ctrl;
			i_rd1_EX <= vif.register_1;
			i_rd2_EX <= vif.register_2;
			
			#5;

			vif.alu_result <= o_alu_result_EX;
			vif.equal <= o_equal_EX;
		end
	end


endmodule