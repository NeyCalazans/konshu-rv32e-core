// ==============================================================================
// File: perif_led.v
// Module: perif_led
// Description: Memory-mapped I/O peripheral driving 16 LEDs for Nexys A7.
//              Base Address: 0x10008000
// ==============================================================================
`timescale 1ns / 1ps

module perif_led (
    input  wire        clk,
    input  wire        rst,

    // Bus interface with UFSC_V_withBRAMs (CPU side)
    input  wire        ce_CPU,         // '1' when CPU performs memory access
    input  wire        rw_CPU,         // '1' = Read, '0' = Write
    input  wire        bw_CPU,         // '1' = Byte write (sb)
    input  wire        hw_CPU,         // '1' = Halfword write (sh)
    input  wire [31:0] d_address_CPU,  // Data address requested by CPU
    input  wire [31:0] data_out_CPU,   // Aligned write data from CPU

    // Bus interface to UFSC_V_withBRAMs (Peripheral response)
    output wire [31:0] data_out_Per,   // Read data returned to CPU
    output wire        suspend,        // Stall request to CPU (inactive = 0)
    output wire        ce_Per,         // Peripheral RAM access enable (inactive = 0)
    output wire        rw_Per,         // Peripheral RAM read/write (default = 1)
    output wire        bw_Per,         // Peripheral RAM byte write (0)
    output wire        hw_Per,         // Peripheral RAM halfword write (0)
    output wire [31:0] d_address_Per,  // Peripheral RAM address (0)

    // External physical outputs (Nexys A7 LEDs / Testbench)
    output reg  [15:0] leds
);

    // Address decoding: 0x10008000 to 0x10008003
    wire sel_led = ce_CPU && (d_address_CPU[31:2] == 32'h00007F00 >> 2);

    // Register write logic
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            leds <= 16'h0000;
        end 
        else if (sel_led && !rw_CPU) begin
            if (bw_CPU) begin
                // Byte write (sb)
                case (d_address_CPU[1:0])
                    2'b00: leds[7:0]  <= data_out_CPU[7:0];
                    2'b01: leds[15:8] <= data_out_CPU[7:0];
                    default: ;
                endcase
            end 
            else if (hw_CPU) begin
                // Halfword write (sh)
                leds <= data_out_CPU[15:0];
            end 
            else begin
                // Word write (sw)
                leds <= data_out_CPU[15:0];
            end
        end
    end

    // Register read logic (lw, lh, lbu...)
    assign data_out_Per = (sel_led && rw_CPU) ? {16'h0000, leds} : 32'h00000000;

    // Tie-offs for unused DMA / Bus master signals
    assign suspend       = 1'b0;
    assign ce_Per        = 1'b0;
    assign rw_Per        = 1'b1;
    assign bw_Per        = 1'b0;
    assign hw_Per        = 1'b0;
    assign d_address_Per = 32'h00000000;

endmodule

