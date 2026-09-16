//////////////////////////////////////////////////////////////////////////////
// Filename:    dual_port_memory.v
// Block:       dual_port_memory
// Description: Dual read-port, word-organized memory for simulation and
//              FPGA.
////////////////////////////////////////////////////////////////////////////////

module dual_port_memory #(
    parameter DATA_WIDTH   = 32,
    parameter NUM_WORDS    = (1024 + 2048),
    parameter INIT_FILE    = ""
) (
    clk,
    i_we,
    i_addr_A,
    i_addr_B,
    i_data,
    o_data_A,
    o_data_B
);
    // ------------------------------------------
    // Localparams
    // ------------------------------------------

    localparam ADDR_WIDTH = $clog2(NUM_WORDS);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input  wire                  clk;
    input  wire [3:0]            i_we;          // byte-lane write enable, already positioned by store_align
    input  wire [ADDR_WIDTH-1:0] i_addr_A;      // word address (instruction fetch)
    input  wire [ADDR_WIDTH-1:0] i_addr_B;      // word address (data access)
    input  wire [DATA_WIDTH-1:0] i_data;        // write data, already positioned by store_align

    output reg [DATA_WIDTH-1:0] o_data_A;
    output reg [DATA_WIDTH-1:0] o_data_B;

    // ------------------------------------------
    // Storage
    // ------------------------------------------

    reg [DATA_WIDTH-1:0] mem [0:NUM_WORDS-1];
    integer i;

    initial begin
        if (INIT_FILE != "")
            $readmemh(INIT_FILE, mem);
    end

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(posedge clk) begin
        for (i = 0; i < 4; i = i + 1) begin
            if (i_we[i]) begin
                mem[i_addr_B][8*i +: 8] <= i_data[8*i +: 8];
            end
        end
    end

    always @(*) begin
        o_data_A = mem[i_addr_A];
        o_data_B = mem[i_addr_B];
    end

endmodule
