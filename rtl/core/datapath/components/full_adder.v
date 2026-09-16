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
// Project:     OSIRIS I
// Block:       alu
// Description: RISC V Full Adder module
//////////////////////////////////////////////////////////////////////////////

module full_adder (
    a, 
    b, 
    cin,
    sum, 
    cout
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire a; 
    input wire b;
    input wire cin;

    output wire sum;
    output wire cout;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (b & cin) | (a & cin);

endmodule
