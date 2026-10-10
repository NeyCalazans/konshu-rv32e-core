//////////////////////////////////////////////////////////////////////////////
// Filename:    store_align.v
// Block:       store_align
// Description: Align store data and generate per-byte write enables.
//              Unsupported misaligned accesses disable write enables (o_we_mask = 0).
////////////////////////////////////////////////////////////////////////////////

module store_align (
    i_mem_write_M,
    i_funct_3,
    o_bw_M,
    o_hw_M
);

    // ------------------------------------------
    // IO declaration
    // ------------------------------------------

    input  wire        i_mem_write_M;
    input  wire [2:0]  i_funct_3;

    output reg o_bw_M;
    output reg o_hw_M;

    // ------------------------------------------
    // Logic
    // ------------------------------------------
   
    always @(*) begin
        
        o_bw_M = 1'b0; 
        o_hw_M = 1'b0;

        if (i_mem_write_M) begin
            case (i_funct_3)

                // sb
                3'b000: begin
                    o_bw_M = 1'b1;
                    o_hw_M = 1'b0;
                end

                // sh
                3'b001: begin
                    o_bw_M = 1'b0;
                    o_hw_M = 1'b1; 
                end

                // sw
                3'b010: begin
                    o_bw_M = 1'b0;
                    o_hw_M = 1'b0;
                end

                default: begin
                    o_bw_M = 1'b0;
                    o_hw_M = 1'b0;
                end
            endcase
        end
    end

endmodule