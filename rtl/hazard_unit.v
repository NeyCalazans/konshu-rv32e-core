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
    o_stall_IF,
    o_stall_ID,
    o_flush_EX,
    o_flush_ID,
    o_forward_rs1_EX,
    o_forward_rs2_EX
);


    // ------------------------------------------
    // IO declaration
    // ------------------------------------------
    // Decode Stage
    input [REG_WIDTH-1:0] i_rs1Addr_ID;

    // Decode Stage   
    input [REG_WIDTH-1:0] i_rs2Addr_ID;

    // Execute Stage
    input [REG_WIDTH-1:0] i_rdAddr_EX;

    // Execute Stage -> Used for Data Hazards with forwading -> Used to check if any of the address of the source registers for the instruction at the Execute stage is the same address of a destination register in the Memory or WriteBack Stages 
    input [REG_WIDTH-1:0] i_rs1Addr_EX;

    // Execute Stage -> Used for Data Hazards with forwading -> Used to check if any of the address of the source registers for the instruction at the Execute stage is the same address of a destination register in the Memory or WriteBack Stages
    input [REG_WIDTH-1:0] i_rs2Addr_EX;

    // Execute Stage ->
    input i_pcSrc_EX;

    // Execute Stage ->
    input [1:0] i_result_src_EX;

    // Memory Stage -> Used for Data Hazards with forwading -> Used to check if there any data dependencies between the instruction in Memory stage and the one in Execute Stage
    input [REG_WIDTH-1:0] i_rdAddr_M;

    // Memory Stage -> Used for Data Hazards with forwading -> Try to avoid false data hazards such as in 'sw' and 'beq' instructions when any writings in the RegFile happens
    input i_reg_write_M;

    // WriteBack Stage -> Used for Data Hazards with forwading -> Used to check if there any data dependencies between the instruction in the beginning of the WriteBack stage and the one in Execute Stage
    input [REG_WIDTH-1:0] i_rdAddr_WB;

    // WriteBack Stage -> Used for Data Hazards with forwading -> Try to avoid false data hazards such as in 'sw' and 'beq' instructions when any writings in the RegFile happens
    input i_reg_write_WB;

    // Fetch Stage ->
    output o_stall_IF;

    // Decode Stage -> 
    output o_stall_ID;

    // Decode Stage -> Used for Control Hazards
    output o_flush_ID;

    // Execute Stage -> 
    output o_flush_EX;

    // Execute Stage -> Used for Data Hazards with forwading -> Select signal for the MUX of the input A of ALU to select between the data at Memory Stage or WriteBack (forwading data)
    output reg [1:0] o_forward_rs1_EX;

    // Execute Stageb -> Used for Data Hazards with forwading -> Select signal for the MUX of the input B of ALU to select between the data at Memory Stage or WriteBack (forwading data)
    output reg [1:0] o_forward_rs2_EX;


    // ------------------------------------------
    // Localparams
    // ------------------------------------------


    // ------------------------------------------
    // Signals definitions
    // ------------------------------------------     
    wire load_hazard_detect;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
    // Forward to solve data hazards -> Forward from a stage if that stage will write a destination register and the destination register matches one of the source registers
    always @* begin
        // Checking for a data hazard in the Memory Stage
        if (((i_rs1Addr_EX == i_rdAddr_M) & i_reg_write_M) & (i_rs1Addr_EX != 4'b0)) begin
            o_forward_rs1_EX = 2'b10;
            // Checking for a data hazard in the WriteBack Stage
        end else
            if (((i_rs1Addr_EX == i_rdAddr_WB) & i_reg_write_WB) & (i_rs1Addr_EX != 4'b0)) begin
            o_forward_rs1_EX = 2'b01;
            // No forwading is necessary
        end else begin
            o_forward_rs1_EX = 2'b00;
        end
    end

    always @* begin
        // Checking for a data hazard in the Memory Stage
        if (((i_rs2Addr_EX == i_rdAddr_M) & i_reg_write_M) & (i_rs2Addr_EX != 4'b0)) begin
            o_forward_rs2_EX = 2'b10;
            // Checking for a data hazard in the WriteBack Stage
        end else
            if (((i_rs2Addr_EX == i_rdAddr_WB) & i_reg_write_WB) & (i_rs2Addr_EX != 4'b0)) begin
            o_forward_rs2_EX = 2'b01;
            // No forwading is necessary
        end else begin
            o_forward_rs2_EX = 2'b00;
        end
    end

    // Stall to solve load hazards
    // assign load_hazard_detect = (i_result_src_EX & ((i_rs1Addr_ID == i_rdAddr_EX) | (i_rs2Addr_ID == i_rdAddr_EX)));  // Detecting a load hazard
    assign load_hazard_detect = ((i_result_src_EX == 2'b01) &&
                                 ((i_rs1Addr_ID == i_rdAddr_EX) || (i_rs2Addr_ID == i_rdAddr_EX)));

    assign o_stall_IF = load_hazard_detect;
    assign o_stall_ID = load_hazard_detect;

    // Flush when a branch is taken or a load introduces a bubble
    assign o_flush_ID = i_pcSrc_EX;
    assign o_flush_EX = load_hazard_detect | i_pcSrc_EX;

    //  todo: where's the rst from hazard unit??

endmodule
