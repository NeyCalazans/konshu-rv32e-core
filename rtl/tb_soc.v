//////////////////////////////////////////////////////////////////////////////
// Filename:    tb_soc.v
// Description: Testbench para o SoC RV32E. Carrega um programa na memoria de
//              instrucao, executa por um numero fixo de ciclos e imprime o
//              estado final dos registradores e da memoria de dados.
////////////////////////////////////////////////////////////////////////////////

module tb_soc;

    localparam CLK_PERIOD  = 10;
    localparam RESET_CYCLES = 3;
    localparam NUM_CYCLES  = 80;


    reg clk;
    reg rst;

    integer cycle_count;
    integer i;

    soc #(
        .DATA_WIDTH(32),
        .IMEM_FILE ("program.hex")
    ) U_SOC (
        .clk(clk),
        .rst(rst)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end


    initial begin
        rst = 1'b1;

        @(posedge clk);
        @(posedge clk);
        @(posedge clk);

        rst = 1'b0;

        for (cycle_count = 0; cycle_count < NUM_CYCLES; cycle_count = cycle_count + 1)
            @(posedge clk);

        print_results;
        $finish;
    end

    task print_results;
        begin
            $display("");
            $display("--- Registradores ---");
            for (i = 0; i < 16; i = i + 1) begin
                $display("  x%0d = %0d (0x%08x)",
                         i,
                         U_SOC.U_CORE.U_DATAPATH.U_STAGE_DECODE.U_REGISTER_FILE.registers[i],
                         U_SOC.U_CORE.U_DATAPATH.U_STAGE_DECODE.U_REGISTER_FILE.registers[i]);
            end

            $display("");
            $display("--- Memoria de dados (primeiras 8 palavras) ---");
            for (i = 0; i < 8; i = i + 1) begin
                $display("  mem[%0d] = %0d (0x%08x)",
                         i,
                         // Currently, the data memory starts at the address 1024
                         U_SOC.U_DUAL_PORT_MEM.mem[i+1024],
                         U_SOC.U_DUAL_PORT_MEM.mem[i+1024]);
            end
        end
    endtask


    initial begin
        $dumpfile("tb_soc.vcd");
        $dumpvars(0, tb_soc);
    end

endmodule