//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2021 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    hazard_unit.v
// Date:        15.05.2024
// Reviewer:    Rafael Oliveira
// Revision:    1.0
//////////////////////////////////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     Osiris I
// Block:       hazard_unit
// Description: Verilog module hazard_unit is responsible for controlling the
//              data dependecy among the fetched instructions
////////////////////////////////////////////////////////////////////////////////

module hazard_unit #(
    parameter REG_WIDTH = 4
) (
    i_rs1Addr_ID,
    i_rs2Addr_ID,
    i_rdAddr_EX,
    i_rs1Addr_EX,
    i_rs2Addr_EX,
    i_pcSrc_EX,
    i_result_src_EX,
    i_rdAddr_M,
    i_reg_write_M,
    i_rdAddr_WB,
    i_reg_write_WB,
    i_pcSrc_M,
    o_stall_IF,
    o_stall_ID,
    o_flush_EX,
    o_flush_ID,
    o_flush_M,
    o_forward_rs1_EX,
    o_forward_rs2_EX
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [REG_WIDTH-1:0] i_rs1Addr_ID;    // Decode Stage
    input wire [REG_WIDTH-1:0] i_rs2Addr_ID;
    input wire [REG_WIDTH-1:0] i_rdAddr_EX;
    input wire [REG_WIDTH-1:0] i_rs1Addr_EX;     // Used for Data Hazards with forwading -> Used to check if any of the address of the source registers for the instruction at the Execute stage is the same address of a destination register in the Memory or WriteBack Stages 
    input wire [REG_WIDTH-1:0] i_rs2Addr_EX;     // Used for Data Hazards with forwading -> Used to check if any of the address of the source registers for the instruction at the Execute stage is the same address of a destination register in the Memory or WriteBack Stages
    input wire [1:0]           i_pcSrc_EX;
    input wire [1:0]           i_pcSrc_M;
    input wire [1:0]           i_result_src_EX;
    input wire [REG_WIDTH-1:0] i_rdAddr_M;       // Used for Data Hazards with forwading -> Used to check if there any data dependencies between the instruction in Memory stage and the one in Execute Stage
    input wire                 i_reg_write_M;    // Used for Data Hazards with forwading -> Try to avoid false data hazards such as in 'sw' and 'beq' instructions when any writings in the RegFile happens                 
    input wire [REG_WIDTH-1:0] i_rdAddr_WB;      // Used for Data Hazards with forwading -> Used to check if there any data dependencies between the instruction in the beginning of the WriteBack stage and the one in Execute Stage
    input wire                 i_reg_write_WB;   // Used for Data Hazards with forwading -> Try to avoid false data hazards such as in 'sw' and 'beq' instructions when any writings in the RegFile happens

    output wire      o_stall_IF;
    output wire      o_stall_ID;
    output wire      o_flush_ID;        // Used for Control Hazards
    output wire      o_flush_EX;
    output wire      o_flush_M;
    output reg [1:0] o_forward_rs1_EX;  // Used for Data Hazards with forwading -> Select signal for the MUX of the input A of ALU to select between the data at Memory Stage or WriteBack (forwading data)
    output reg [1:0] o_forward_rs2_EX;  // Used for Data Hazards with forwading -> Select signal for the MUX of the input B of ALU to select between the data at Memory Stage or WriteBack (forwading data)

    // ------------------------------------------
    // Signals definitions
    // ------------------------------------------     

    wire load_hazard_detect;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    // Forward to solve data hazards -> Forward from a stage if that stage will write a destination register and the destination register matches one of the source registers
    always @(*) begin
        // Checking for a data hazard in the Memory Stage
        if (((i_rs1Addr_EX == i_rdAddr_M) & i_reg_write_M) & (i_rs1Addr_EX != 4'b0)) begin
            o_forward_rs1_EX = 2'b10;
        end 
        // Checking for a data hazard in the WriteBack Stage
        else if (((i_rs1Addr_EX == i_rdAddr_WB) & i_reg_write_WB) & (i_rs1Addr_EX != 4'b0)) begin
            o_forward_rs1_EX = 2'b01;
        end 
        // No forwading is necessary
        else begin
            o_forward_rs1_EX = 2'b00;
        end
    end

    always @(*) begin
        // Checking for a data hazard in the Memory Stage
        if (((i_rs2Addr_EX == i_rdAddr_M) & i_reg_write_M) & (i_rs2Addr_EX != 4'b0)) begin
            o_forward_rs2_EX = 2'b10;
        end 
        // Checking for a data hazard in the WriteBack Stage
        else if (((i_rs2Addr_EX == i_rdAddr_WB) & i_reg_write_WB) & (i_rs2Addr_EX != 4'b0)) begin
            o_forward_rs2_EX = 2'b01;
        end 
        // No forwading is necessary
        else begin
            o_forward_rs2_EX = 2'b00;
        end
    end

    // Stall to solve load hazards
    // The stall is implemented if there is a load and a dependecy in the pipeline,
    // or if there is just a load (synchronous memory)
    assign load_hazard_detect = (i_result_src_EX === 2'b10);
    assign o_stall_IF         = load_hazard_detect;
    assign o_stall_ID         = load_hazard_detect;

    // Flush when a branch is taken or a load introduces a bubble
    assign o_flush_ID = (i_pcSrc_EX[0] === 1'b1);
    assign o_flush_M  = (i_pcSrc_M[0] === 1'b1);
    assign o_flush_EX = load_hazard_detect | o_flush_ID;

endmodule
