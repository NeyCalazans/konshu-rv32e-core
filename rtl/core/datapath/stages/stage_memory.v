module stage_memory #(
    parameter DATA_WIDTH = 32
) (
    i_alu_result_M,
    i_write_data_M,
    i_mem_write_M,
    i_result_src_M,
    i_funct_3_M,
    o_data_addr_M,
    o_write_data_aligned_M,
    o_data_ce_M,
    o_mem_write_M,
    o_bw_M,
    o_hw_M
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [DATA_WIDTH-1:0] i_alu_result_M;
    input wire [DATA_WIDTH-1:0] i_write_data_M;
    input wire                  i_mem_write_M;
    input wire [1:0]            i_result_src_M;
    input wire [2:0]            i_funct_3_M;

    output wire [DATA_WIDTH-1:0] o_data_addr_M;
    output wire [DATA_WIDTH-1:0] o_write_data_aligned_M;
    output wire                  o_data_ce_M;
    output wire                  o_mem_write_M;
    output wire                  o_bw_M;
    output wire                  o_hw_M;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign o_data_addr_M          = i_alu_result_M;
    assign o_write_data_aligned_M = i_write_data_M;
    assign o_data_ce_M            = i_mem_write_M | (i_result_src_M == 2'b10);
    assign o_mem_write_M          = i_mem_write_M;

    store_align U_STORE_ALIGN (
            .i_mem_write_M(i_mem_write_M),
            .i_funct_3    (i_funct_3_M),
            .o_bw_M       (o_bw_M),
            .o_hw_M       (o_hw_M)
        );

endmodule