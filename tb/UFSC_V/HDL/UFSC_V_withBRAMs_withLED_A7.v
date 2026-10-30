// ==============================================================================
// File: top_led.v
// Module: top_led
// Description: Top-level system integrating UFSC_V_withBRAMs (VHDL) and 
//              perif_led (Verilog).
//              Target: Nexys A7 FPGA & Vivado Simulation.
// ==============================================================================
`timescale 1ns / 1ps

module UFSC_V_withBRAMs_withLED_A7 (
    input  wire        clock,
    input  wire        reset,
    output wire [15:0] leds
);

    // Interconnect wires between CPU and Peripheral
    wire        suspend_sig;
    wire        suspend_ack_sig;
    wire        ce_Per_sig;
    wire        rw_Per_sig;
    wire        bw_Per_sig;
    wire        hw_Per_sig;
    wire [31:0] d_address_Per_sig;
    wire [31:0] data_out_Per_sig;

    wire        ce_CPU_sig;
    wire        rw_CPU_sig;
    wire        bw_CPU_sig;
    wire        hw_CPU_sig;
    wire [31:0] d_address_CPU_sig;
    wire [31:0] data_out_CPU_sig;
    
    // Clocking signals
    wire clk_25mhz;
    wire locked;
    
    
    clk_wiz_0 u_clk_wiz (
        .clk_in1 (clock),       // 100 MHz 
        .clk_out1(clk_25mhz),   // 25 MHz 
        .locked  (locked)
    );

    // Subsystem: UFSC_V core with BRAMs (VHDL entity instantiated in Verilog)
    UFSC_V_withBRAMs U_UFSC_V_withBRAMs (
        .clock        (clk_25mhz),
        .reset        (reset),
        .sel_CPU      (1'b0),
        .reset_CPU    (),
        .suspend      (suspend_sig),
        .ce_Per       (ce_Per_sig),
        .rw_Per       (rw_Per_sig),
        .bw_Per       (bw_Per_sig),
        .hw_Per       (hw_Per_sig),
        .d_address_Per(d_address_Per_sig),
        .data_out_Per (data_out_Per_sig),
        .suspend_ack  (suspend_ack_sig),
        .ce_CPU       (ce_CPU_sig),
        .rw_CPU       (rw_CPU_sig),
        .bw_CPU       (bw_CPU_sig),
        .hw_CPU       (hw_CPU_sig),
        .d_address_CPU(d_address_CPU_sig),
        .data_out_CPU (data_out_CPU_sig),
        .data_out_RAM ()
    );

    // Peripheral: 16 LEDs (Verilog)
    perif_led U_PERIF_LED (
        .clk          (clk_25mhz),
        .rst          (reset),
        .ce_CPU       (ce_CPU_sig),
        .rw_CPU       (rw_CPU_sig),
        .bw_CPU       (bw_CPU_sig),
        .hw_CPU       (hw_CPU_sig),
        .d_address_CPU(d_address_CPU_sig),
        .data_out_CPU (data_out_CPU_sig),
        .data_out_Per (data_out_Per_sig),
        .suspend      (suspend_sig),
        .ce_Per       (ce_Per_sig),
        .rw_Per       (rw_Per_sig),
        .bw_Per       (bw_Per_sig),
        .hw_Per       (hw_Per_sig),
        .d_address_Per(d_address_Per_sig),
        .leds         (leds)
    );

endmodule

