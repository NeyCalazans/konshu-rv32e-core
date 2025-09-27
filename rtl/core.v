//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    core.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       risc_core
// Description: Verilog module risc_core
////////////////////////////////////////////////////////////////////////////////

module core #(
    parameter DATA_WIDTH = 32
) (
`ifdef USE_POWER_PINS
    vccd1,
    vssd1,
`endif
    clk,
    rst,
    // input  wire [DATA_WIDTH-1:0] i_instr_ID,
    // input  wire [DATA_WIDTH-1:0] i_read_data_M,

    // Core-visible interfaces remain the same:
    o_pc_IF,
    o_mem_write_M,
    o_data_addr_M,
    o_write_data_M
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
`ifdef USE_POWER_PINS
    inout vccd1;
    inout vssd1;
`endif
    input  wire clk;
    input  wire rst;

    // ----- Outputs from your datapath -----
    output wire [DATA_WIDTH-1:0] o_pc_IF;          // instruction address (byte address)
    output wire                  o_mem_write_M;    // data memory write enable
    output wire [DATA_WIDTH-1:0] o_data_addr_M;    // data memory address (byte address)
    output wire [DATA_WIDTH-1:0] o_write_data_M;   // data to write

    // ------------------------------------------
    // Internal wires to connect memories <-> datapath
    // ------------------------------------------
    wire [DATA_WIDTH-1:0] instr_IF;     // instruction fetched
    wire [DATA_WIDTH-1:0] read_data_M;  // data read from data memory

    // ------------------------------------------
    // Address slicing: 512 x 32 => 9-bit word index
    // ------------------------------------------
    localparam integer ADDR_LSB   = $clog2(DATA_WIDTH/8); // = 2 for 32-bit data
    localparam integer ADDR_WIDTH = 9;                     // 512 deep
    localparam integer ADDR_MSB   = ADDR_LSB + ADDR_WIDTH - 1;

    wire [ADDR_WIDTH-1:0] inst_rd_addr = o_pc_IF[ADDR_MSB:ADDR_LSB];
    wire [ADDR_WIDTH-1:0] data_addr_ix = o_data_addr_M[ADDR_MSB:ADDR_LSB];

    // ------------------------------------------
    // Instantiate Control Unit
    // ------------------------------------------
    control_unit U_CONTROL_UNIT (
        .i_op           (o_op),             // Opcode from datapath
        .i_funct_3      (o_funct3),         // Funct3 from datapath
        .i_funct_7_5    (o_funct_7_5),      // Funct7[5] from datapath
        .i_zero         (o_zero),           // Zero flag from datapath
        .i_branch_EX    (o_branch_EX),      // Branch signal from EX stage
        .i_jump_EX      (o_jump_EX),        // Jump signal from EX stage
        .o_pc_src_EX    (pc_src_EX),        // PC source from EX stage
        .o_jump_ID      (o_jump_ID),        // Jump signal for ID stage
        .o_branch_ID    (o_branch_ID),      // Branch signal for ID stage
        .o_reg_write_ID (o_reg_write_ID),   // RegWrite signal for ID stage
        .o_result_src_ID(o_result_src_ID),  // Result source signal for ID stage
        .o_mem_write_ID (o_mem_write_ID),   // Memory write enable signal for ID stage
        .o_alu_src_ID   (o_alu_src_ID),     // ALU source signal for ID stage
        .o_imm_src_ID   (o_imm_src_ID),     // Immediate source for ID stage
        .o_alu_ctrl_ID  (o_alu_ctrl_ID),    // ALU control signal for ID stage
        .o_addr_src_ID  (o_addr_src_ID),    // Address source for ID stage
        .o_fence_ID     (o_fence_ID)        // Fence signal for ID stage
    );

    // ------------------------------------------
    // Instantiate Datapath
    // ------------------------------------------
    datapath #(
        .DATA_WIDTH(DATA_WIDTH)
    ) U_DATAPATH (
        .clk            (clk),
        .rst            (rst),
        .i_pc_src_EX    (pc_src_EX),
        .i_jump_ID      (o_jump_ID),
        .i_branch_ID    (o_branch_ID),
        .i_reg_write_ID (o_reg_write_ID),
        .i_result_src_ID(o_result_src_ID),
        .i_mem_write_ID (o_mem_write_ID),
        .i_alu_ctrl_ID  (o_alu_ctrl_ID),
        .i_alu_src_ID   (o_alu_src_ID),
        .i_addr_src_ID  (o_addr_src_ID),
        .i_imm_src_ID   (o_imm_src_ID),
        .i_fence_ID     (o_fence_ID),

        .i_instr_IF     (instr_IF),
        .i_read_data_M  (read_data_M),

        .o_jump_EX      (o_jump_EX),
        .o_branch_EX    (o_branch_EX),
        .o_zero         (o_zero),
        .o_mem_write_M  (o_mem_write_M),
        .o_write_data_M (o_write_data_M),
        .o_data_addr_M  (o_data_addr_M),
        .o_op           (o_op),
        .o_funct3       (o_funct3),
        .o_funct_7_5    (o_funct_7_5),
        .o_pc_IF        (o_pc_IF)
    );

    // ------------------------------------------
    // Instruction Memory (read-only here)
    // ckw = clk
    // enw = 0 (disable writes)
    // addw/inw are don't-cares; tie to 0
    // addr = PC[ADDR_MSB:ADDR_LSB]
    // outr -> instr_IF
    // ------------------------------------------
    rf2p512x32mux4co U_INST_MEM (
        .ckw   (clk),
        .enw   (1'b0),
        .addw  ({ADDR_WIDTH{1'b0}}),
        .addr  (inst_rd_addr),
        .inw   ({DATA_WIDTH{1'b0}}),
        .outr  (instr_IF)
    );

    // ------------------------------------------
    // Data Memory (read + write)
    // ckw = clk
    // enw = o_mem_write_M (write enable from datapath)
    // addw = write address index (same as read index here)
    // addr = read address index
    // inw  = o_write_data_M
    // outr = read_data_M
    // ------------------------------------------
    rf2p512x32mux4co U_DATA_MEM (
        .ckw   (clk),
        .enw   (o_mem_write_M),
        .addw  (data_addr_ix),
        .addr  (data_addr_ix),
        .inw   (o_write_data_M),
        .outr  (read_data_M)
    );

endmodule