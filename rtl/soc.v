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
    // Localparams
    // ------------------------------------------

    localparam TOTAL_WORDS = 1024 + 2048;
    localparam ADDR_WIDTH  = $clog2(TOTAL_WORDS); // 12 bits

    // ------------------------------------------
    // Sign declaration
    // ------------------------------------------

    wire [DATA_WIDTH-1:0] pc_IF;
    wire [DATA_WIDTH-1:0] instr_IF;

    wire [DATA_WIDTH-1:0] data_addr_M;
    wire [DATA_WIDTH-1:0] write_data_M;
    wire                  mem_write_M;
    wire [2:0]            funct_3_M;
    wire [DATA_WIDTH-1:0] read_data_M;
    wire [3:0]            we_mask;
    wire [DATA_WIDTH-1:0] write_data_aligned;

    wire [ADDR_WIDTH-1:0] imem_index;
    wire [ADDR_WIDTH-1:0] dmem_index;

    assign imem_index = pc_IF[ADDR_WIDTH+1:2];
    assign dmem_index = data_addr_M[ADDR_WIDTH+1:2];

    // ------------------------------------------
    // Core
    // ------------------------------------------

    core #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U_CORE (
        .clk           (clk),
        .rst           (rst),
        .o_pc_IF       (pc_IF),
        .i_instr_IF    (instr_IF),
        .o_data_addr_M (data_addr_M),
        .o_write_data_M(write_data_M),
        .o_mem_write_M (mem_write_M),
        .o_funct_3_M   (funct_3_M),
        .i_read_data_M (read_data_M)
    );

    store_align U_STORE_ALIGN (
        .i_mem_write_M       (mem_write_M),
        .i_funct_3           (funct_3_M),
        .i_addr_low          (data_addr_M[1:0]),
        .i_write_data_M      (write_data_M),
        .o_we_mask           (we_mask),
        .o_write_data_aligned(write_data_aligned)
    );

    dual_port_memory #(
        .DATA_WIDTH  (DATA_WIDTH),
        .NUM_WORDS   (TOTAL_WORDS),
        .INIT_FILE   (IMEM_FILE)
    ) U_DUAL_PORT_MEM (
        .clk      (clk),
        .i_we     (we_mask),
        .i_addr_A (imem_index),
        .i_addr_B (dmem_index),
        .i_data   (write_data_aligned),
        .o_data_A (instr_IF),
        .o_data_B (read_data_M)
    );

endmodule
