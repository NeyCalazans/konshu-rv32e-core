//////////////////////////////////////////////////////////////////////////////
// Filename:    load_extend.v
// Block:       load_extend
// Description: For a word-organized data memory, extracts the targeted byte
//              or half-word out of the full word read from memory (using
//              the low 2 address bits) and sign/zero-extends it per funct3
//              (lb/lh/lw/lbu/lhu).
////////////////////////////////////////////////////////////////////////////////

module load_extend #(
    parameter DATA_WIDTH = 32
) (
    i_funct_3,
    i_addr_low,
    i_read_data_M,
    o_result_data_WB
);

    input wire [2:0]            i_funct_3;
    input wire [1:0]            i_addr_low;      // byte offset within the read word
    input wire [DATA_WIDTH-1:0] i_read_data_M;

    output reg [DATA_WIDTH-1:0] o_result_data_WB;

    reg [7:0]  byte_sel;
    reg [15:0] half_sel;

    always @(*) begin
        case (i_addr_low)
            2'b00:   byte_sel = i_read_data_M[7:0];
            2'b01:   byte_sel = i_read_data_M[15:8];
            2'b10:   byte_sel = i_read_data_M[23:16];
            2'b11:   byte_sel = i_read_data_M[31:24];
            default: byte_sel = 8'b0;
        endcase

        case (i_addr_low[1])
            1'b0:    half_sel = i_read_data_M[15:0];
            1'b1:    half_sel = i_read_data_M[31:16];
            default: half_sel = 16'b0;
        endcase
        
        case (i_funct_3)
            3'b000:  o_result_data_WB = {{24{byte_sel[7]}},  byte_sel};    // lb
            3'b001:  o_result_data_WB = {{16{half_sel[15]}}, half_sel};   // lh
            3'b010:  o_result_data_WB = i_read_data_M;                     // lw
            3'b100:  o_result_data_WB = {24'b0, byte_sel};                 // lbu
            3'b101:  o_result_data_WB = {16'b0, half_sel};                // lhu
            default: o_result_data_WB = i_read_data_M;
        endcase
    end

endmodule
