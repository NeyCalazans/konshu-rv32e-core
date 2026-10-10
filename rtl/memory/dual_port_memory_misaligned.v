//////////////////////////////////////////////////////////////////////////////
// Filename:    dual_port_memory.v
// Block:       dual_port_memory
// Description: Dual read-port, word-organized memory for simulation and
//              FPGA.
////////////////////////////////////////////////////////////////////////////////

module dual_port_memory_misaligned #(
    parameter DATA_WIDTH   = 32,
    parameter NUM_BYTES    = 16384,
    parameter INIT_FILE    = "",
    parameter LIMIT_A      = 32'h00002000
) (
    clk,
    i_we,
    i_bw,
    i_hw,
    i_addr_A,
    i_addr_B,
    i_data,
    o_data_A,
    o_data_B
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input  wire        clk;
    input  wire        i_we;          // write enable
    input  wire        i_bw;          // byte enable
    input  wire        i_hw;          // half enable
    input  wire [31:0] i_addr_A;      // word address (instruction fetch)
    input  wire [31:0] i_addr_B;      // word address (data access)
    input  wire [31:0] i_data;        // write data, already positioned by store_align

    output reg [DATA_WIDTH-1:0] o_data_A;
    output reg [DATA_WIDTH-1:0] o_data_B;

    // ------------------------------------------
    // Storage
    // ------------------------------------------

    reg [7:0] mem [0:NUM_BYTES-1];
    integer i;

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(posedge clk) begin
        if(i_we && i_addr_B >= LIMIT_A) begin
            if(i_bw == 1'b0 && i_hw == 1'b0) begin
                mem[i_addr_B ] <= i_data[7:0];
                mem[i_addr_B + 1] <= i_data[15:8];
                mem[i_addr_B + 2] <= i_data[23:16];
                mem[i_addr_B + 3] <= i_data[31:24];
            end
            else if (i_bw == 1'b0 && i_hw == 1'b1) begin
                mem[i_addr_B] <= i_data[7:0];
                mem[i_addr_B + 1] <= i_data[15:8];
            end
            else if (i_bw == 1'b1 && i_hw == 1'b0) begin
                mem[i_addr_B] <= i_data[7:0];
            end
        end
    end


    always @(*) begin
        o_data_A[7:0]   = mem[i_addr_A];
        o_data_A[15:8]  = mem[i_addr_A + 1];
        o_data_A[23:16] = mem[i_addr_A + 2];
        o_data_A[31:24] = mem[i_addr_A + 3];

        o_data_B[7:0]   = mem[i_addr_B];
        o_data_B[15:8]  = mem[i_addr_B + 1];
        o_data_B[23:16] = mem[i_addr_B + 2];
        o_data_B[31:24] = mem[i_addr_B + 3];

    end

endmodule
