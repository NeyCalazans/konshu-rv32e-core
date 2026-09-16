//////////////////////////////////////////////////////////////////////////////
// Filename:    store_align.v
// Block:       store_align
// Description: Align store data and generate per-byte write enables.
//              Unsupported misaligned accesses disable write enables (o_we_mask = 0).
////////////////////////////////////////////////////////////////////////////////

module store_align (
    input  wire        i_mem_write_M,
    input  wire [2:0]  i_funct_3,
    input  wire [1:0]  i_addr_low,       // data_addr_M[1:0]
    input  wire [31:0] i_write_data_M,

    output reg  [3:0]  o_we_mask,
    output reg  [31:0] o_write_data_aligned
);

    always @(*) begin
        o_we_mask            = 4'b0000;
        o_write_data_aligned = 32'b0;

        if (i_mem_write_M) begin
            case (i_funct_3)
                // sb
                3'b000: begin
                    case (i_addr_low)
                        2'b00: begin
                            o_we_mask            = 4'b0001;
                            o_write_data_aligned = {24'b0, i_write_data_M[7:0]};
                        end
                        2'b01: begin
                            o_we_mask            = 4'b0010;
                            o_write_data_aligned = {16'b0, i_write_data_M[7:0], 8'b0};
                        end
                        2'b10: begin
                            o_we_mask            = 4'b0100;
                            o_write_data_aligned = {8'b0,  i_write_data_M[7:0], 16'b0};
                        end
                        2'b11: begin
                            o_we_mask            = 4'b1000;
                            o_write_data_aligned = {i_write_data_M[7:0], 24'b0};
                        end
                    endcase
                end

                // sh
                3'b001: begin
                    case (i_addr_low)
                        2'b00: begin
                            o_we_mask            = 4'b0011;
                            o_write_data_aligned = {16'b0, i_write_data_M[15:0]};
                        end
                        2'b10: begin
                            o_we_mask            = 4 meb1100;
                            o_write_data_aligned = {i_write_data_M[15:0], 16'b0};
                        end
                        default: begin 
                            o_we_mask            = 4'b0000;
                            o_write_data_aligned = 32'b0;
                        end
                    endcase
                end
                
                // sw
                3'b010: begin
                    if (i_addr_low == 2'b00) begin
                        o_we_mask            = 4'b1111;
                        o_write_data_aligned = i_write_data_M;
                    end 
                    else begin 
                        o_we_mask            = 4'b0000;
                        o_write_data_aligned = 32'b0;
                    end
                end

                default: begin
                    o_we_mask            = 4'b0000;
                    o_write_data_aligned = 32'b0;
                end
            endcase
        end
    end

endmodule