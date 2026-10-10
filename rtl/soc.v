//////////////////////////////////////////////////////////////////////////////
// Filename:    soc.v
// Block:       soc
// Description: Top level. Connects the RV32E core to the instruction and data
//              memories.
////////////////////////////////////////////////////////////////////////////////

module soc #(
    parameter DATA_WIDTH = 32,
    parameter IMEM_FILE  = ""
) (
    clk,
    rst
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire clk;
    input wire rst;

    // ------------------------------------------
    // Signal declaration
    // ------------------------------------------

    wire [DATA_WIDTH-1:0] pc_IF;
    wire [DATA_WIDTH-1:0] instr_IF;

    wire [DATA_WIDTH-1:0] data_addr_M;
    wire [DATA_WIDTH-1:0] read_data_M;
    wire [DATA_WIDTH-1:0] write_data_aligned;
    wire                  mem_write_M;
    wire                  bw_M;
    wire                  hw_M;
    wire                  mem_access_M;

    // ------------------------------------------
    // Core
    // ------------------------------------------

    UFSC_V #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U_CORE (
        .clk                   (clk),
        .rst                   (rst),
        .o_pc_IF               (pc_IF),
        .i_instr_IF            (instr_IF),
        .o_data_addr_M         (data_addr_M),
        .o_write_data_aligned_M(write_data_aligned),
        .o_bw_M                (bw_M),
        .o_hw_M                (hw_M),
        .o_mem_access_M        (mem_access_M),
        .o_mem_write_M         (mem_write_M),
        .i_read_data_M         (read_data_M)
    );

    dual_port_memory_misaligned #(
        .DATA_WIDTH(DATA_WIDTH),
        .INIT_FILE (IMEM_FILE)
    ) U_DUAL_PORT_MEM (
        .clk      (clk),
        .i_we     (mem_write_M),
        .i_bw     (bw_M),
        .i_hw     (hw_M),
        .i_addr_A (pc_IF),
        .i_addr_B (data_addr_M),
        .i_data   (write_data_aligned),
        .o_data_A (instr_IF),
        .o_data_B (read_data_M)
    );

endmodule
