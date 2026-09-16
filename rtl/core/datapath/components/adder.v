//////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2023 Group of Open-Source Research in RISC-V Architectures for
// Integrated Systems. All rights reserved.
//
// Use, copy or distribution of this code is free without Group of Open-Source
// Research in RISC-V Architectures for Integrated Systems explicit written a 
// consent.
//////////////////////////////////////////////////////////////////////////////
// Filename:    alu.v
// Date:        17/03/2024
// Reviewer:    Luis Spader @LuisSpader
// Revision:    1.0
///////////////////////////;///////////////////////////////////////////////////
// Company:     Group OSIRIS
// Project:     OSIRIS i
// Block:       alu
// Description: RISC V Adder module
//////////////////////////////////////////////////////////////////////////////

module adder #(
    parameter WIDTH = 32
) (
    cin,
    a,
    b,
    sum
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire           cin;
    input wire [WIDTH-1:0] a;
    input wire [WIDTH-1:0] b;

    output wire [WIDTH-1:0] sum;

    // ------------------------------------------
    // Signals deinitions
    // ------------------------------------------

    wire [WIDTH-1:0] internal_sum;
    wire [WIDTH-1:0] carry;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    genvar i;
    assign sum = internal_sum;

    generate
        for (i = 0; i < WIDTH; i = i + 1) begin
            if (i == 0) begin  // first FA
                full_adder FA0 (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(cin),
                    .sum(internal_sum[i]),
                    .cout(carry[i])
                );
            end  // last bit
            else if (i == WIDTH - 1) begin  // Last FA
                assign internal_sum[i] = a[i] ^ b[i] ^ carry[i-1];
            end 
            else begin  // Middle FAs
                full_adder FAs_middle (
                    .a(a[i]),
                    .b(b[i]),
                    .cin(carry[i-1]),
                    .sum(internal_sum[i]),
                    .cout(carry[i])
                );
            end
        end
    endgenerate


endmodule
