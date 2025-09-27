module mem_byte #(
    parameter DATA_WIDTH = 32,
    parameter MEM_SIZE   = 64   // in KB
) (
    input  wire                  clk,       // Clock
    input  wire                  rst,       // Reset
    input  wire [          15:0] wb_adr_i,  // 16-bit byte address input
    input  wire [DATA_WIDTH-1:0] wb_dat_i,  // Wishbone data input
    input  wire [           3:0] wb_sel_i,  // Wishbone byte select input
    input  wire                  wb_we_i,   // Wishbone write enable
    input  wire                  wb_stb_i,  // Wishbone strobe
    input  wire                  wb_cyc_i,  // Wishbone cycle
    output reg  [DATA_WIDTH-1:0] wb_dat_o,  // Wishbone data output
    output reg                   wb_ack_o   // Wishbone acknowledge
);
    // xxx -> instr -> LSB 
    // 0000000000000001 10

    // Calculate the memory depth (number of entries)
    localparam MEM_DEPTH = (MEM_SIZE * 1024) / (DATA_WIDTH / 8);

    // Define the memory array with calculated depth
    reg [DATA_WIDTH-1:0] mem[0:MEM_DEPTH-1];

    // Word address calculation (byte address divided by 4)
    wire [$clog2(MEM_DEPTH)-1:0] word_addr = wb_adr_i[15:2];

    integer i;

    always @(posedge clk) begin
        if (rst) begin
            wb_ack_o <= 0;
            wb_dat_o <= {DATA_WIDTH{1'b0}};
            // Reset all memory contents to zero
            for (i = 0; i < MEM_DEPTH; i = i + 1) begin
                mem[i] <= {DATA_WIDTH{1'b0}};
            end
        end else begin
            wb_ack_o <= 0;  // Deassert ack by default
            if (wb_cyc_i && wb_stb_i) begin
                wb_ack_o <= 1;  // Acknowledge the transaction
                if (wb_we_i) begin
                    // Write operation with byte enables
                    if (wb_sel_i[0]) mem[word_addr][7:0] <= wb_dat_i[7:0];
                    if (wb_sel_i[1]) mem[word_addr][15:8] <= wb_dat_i[15:8];
                    if (wb_sel_i[2]) mem[word_addr][23:16] <= wb_dat_i[23:16];
                    if (wb_sel_i[3]) mem[word_addr][31:24] <= wb_dat_i[31:24];
                end else begin
                    // Read operation
                    wb_dat_o <= mem[word_addr];
                end
            end
        end
    end

endmodule
