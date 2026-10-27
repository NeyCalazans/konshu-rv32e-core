//////////////////////////////////////////////////////////////////////////////
// Filename:    load_extend.v
// Block:       load_extend
// Description: For a word-organized data memory, extracts the targeted byte
//              or half-word out of the full word read from memory (using
//              the low 2 address bits) and sign/zero-extends it per funct3
//              (lb/lh/lw/lbu/lhu).
////////////////////////////////////////////////////////////////////////////////

module load_extend #(
    parameter DATA_WIDTH = 32) (
    i_funct_3,
    i_byte_offset,
    i_read_data_M,
    o_result_data_WB
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [2:0]            i_funct_3;
    input wire [1:0]            i_byte_offset;
    input wire [DATA_WIDTH-1:0] i_read_data_M;

    output reg [DATA_WIDTH-1:0] o_result_data_WB;

    // ------------------------------------------
    // Internal signals
    // ------------------------------------------

    reg [7:0]  selected_byte;
    reg [15:0] selected_half;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(*) begin
        // Select byte according to byte offset within the word
        case (i_byte_offset)
            2'b00: selected_byte = i_read_data_M[7:0];
            2'b01: selected_byte = i_read_data_M[15:8];
            2'b10: selected_byte = i_read_data_M[23:16];
            2'b11: selected_byte = i_read_data_M[31:24];
        endcase

        // Select halfword according to halfword offset within the word
        case (i_byte_offset[1])
            1'b0: selected_half = i_read_data_M[15:0];
            1'b1: selected_half = i_read_data_M[31:16];
        endcase

        case (i_funct_3)
            3'b000:  o_result_data_WB = {{24{selected_byte[7]}}, selected_byte};     // lb
            3'b001:  o_result_data_WB = {{16{selected_half[15]}}, selected_half};   // lh
            3'b010:  o_result_data_WB = i_read_data_M;                                // lw
            3'b100:  o_result_data_WB = {24'b0, selected_byte};                      // lbu
            3'b101:  o_result_data_WB = {16'b0, selected_half};                     // lhu
            default: o_result_data_WB = i_read_data_M;
        endcase
    end

endmodule
