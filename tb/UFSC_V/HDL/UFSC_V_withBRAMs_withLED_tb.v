// ==============================================================================
// File: top_led_tb.v
// Module: top_led_tb
// Description: Verilog testbench to validate UFSC_V with LED peripheral.
// ==============================================================================
`timescale 1ns / 1ps

module UFSC_V_withBRAMs_withLED_tb;

    reg         clock;
    reg         reset;
    wire [15:0] leds;

    // Instantiate Device Under Test (DUT)
    UFSC_V_withBRAMs_withLED uut (
        .clock(clock),
        .reset(reset),
        .leds (leds)
    );

    // Clock generation: 100 MHz (period = 10 ns)
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // Reset sequence: active high for 120 ns
    initial begin
        reset = 1'b1;
        #120;
        reset = 1'b0;
    end

endmodule

