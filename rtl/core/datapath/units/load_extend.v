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
    i_read_data_M,
    o_result_data_WB
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input wire [2:0]            i_funct_3;
    input wire [DATA_WIDTH-1:0] i_read_data_M;

    output reg [DATA_WIDTH-1:0] o_result_data_WB;

    // ------------------------------------------
    // Logic
    // ------------------------------------------

    always @(*) begin
        case (i_funct_3)
            3'b000:  o_result_data_WB = {{24{i_read_data_M[7]}}, i_read_data_M[7:0]};     // lb
            3'b001:  o_result_data_WB = {{16{i_read_data_M[15]}}, i_read_data_M[15:0]};   // lh
            3'b010:  o_result_data_WB = i_read_data_M;                                    // lw
            3'b100:  o_result_data_WB = {24'b0, i_read_data_M[7:0]};                      // lbu
            3'b101:  o_result_data_WB = {16'b0, i_read_data_M[15:0]};                     // lhu
            default: o_result_data_WB = i_read_data_M;
        endcase
    end

endmodule
