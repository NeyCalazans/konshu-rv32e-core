`timescale 1ns/1ps

module op_decoder_tb;

  // DUT inputs
  logic [31:0] inst;
  logic [4:0]  i_op;
  logic [2:0]  i_funct_3;
  logic        i_funct_7_5;

  // DUT outputs
  logic [1:0]  o_result_src_ID;
  logic [2:0]  o_imm_src_ID;
  logic [2:0]  o_alu_op;
  logic        o_alu_src_ID;
  logic        o_addr_src_ID;
  logic        o_mem_write_ID;
  logic        o_reg_write_ID;
  logic        o_jump_ID;
  logic        o_branch_ID;
  logic        o_fence_ID;

  // === Instância do DUT (ajuste o nome/portas se diferirem aí) ===
  op_decoder dut (
    .i_op            (i_op),
    .i_funct_3       (i_funct_3),
    .i_funct_7_5     (i_funct_7_5),
    .o_result_src_ID (o_result_src_ID),
    .o_imm_src_ID    (o_imm_src_ID),
    .o_alu_op        (o_alu_op),
    .o_alu_src_ID    (o_alu_src_ID),
    .o_addr_src_ID   (o_addr_src_ID),
    .o_mem_write_ID  (o_mem_write_ID),
    .o_reg_write_ID  (o_reg_write_ID),
    .o_jump_ID       (o_jump_ID),
    .o_branch_ID     (o_branch_ID),
    .o_fence_ID      (o_fence_ID)
  );

  // === Encodes (alinhados com o DUT) ===
  localparam logic [2:0] IMM_I = 3'b000;
  localparam logic [2:0] IMM_S = 3'b001;
  localparam logic [2:0] IMM_B = 3'b010;
  localparam logic [2:0] IMM_J = 3'b011;
  localparam logic [2:0] IMM_U = 3'b100;

  localparam logic [1:0] RS_ALU   = 2'b00;
  localparam logic [1:0] RS_PC4   = 2'b01;
  localparam logic [1:0] RS_MEM   = 2'b10;
  localparam logic [1:0] RS_AUIPC = 2'b11;

  localparam logic [2:0] OP_ADD     = 3'b000;
  localparam logic [2:0] OP_ADD_SUB = 3'b001;
  localparam logic [2:0] OP_ARITH   = 3'b010;
  localparam logic [2:0] OP_SHIFT   = 3'b011;
  localparam logic [2:0] OP_SLT     = 3'b100;
  localparam logic [2:0] OP_XOR     = 3'b101;
  localparam logic [2:0] OP_OR      = 3'b110;
  localparam logic [2:0] OP_AND     = 3'b111;

  // === Dirige o DUT a partir do instruction word ===
  task automatic drive_from_inst(input logic [31:0] x);
    begin
      inst        = x;
      i_op        = x[6:2];
      i_funct_3   = x[14:12];
      i_funct_7_5 = x[30];
      #1; // combinacional assenta
    end
  endtask

  // === Vetor de teste: nome + inst + expectativas ===
  typedef struct {
    string       name;
    logic [31:0] inst;
    struct packed {
      logic [2:0] imm_src;
      logic       addr_src;
      logic [2:0] alu_op;
      logic       alu_src;
      logic [1:0] result_src;
      logic       branch;
      logic       jump;
      logic       reg_write;
      logic       mem_write;
      logic       fence;
    } exp;
  } vec_t;

  vec_t V [$]; // lista dinâmica de vetores

  // === Impressão no formato pedido: INSTR primeiro, depois divergências (se houver) ===
  task automatic check(input vec_t v);
    string mism;
    begin
      drive_from_inst(v.inst);

      mism = "";
      if (o_imm_src_ID    !== v.exp.imm_src   ) mism = {mism, " imm_src"};
      if (o_addr_src_ID   !== v.exp.addr_src  ) mism = {mism, " addr_src"};
      if (o_alu_op        !== v.exp.alu_op    ) mism = {mism, " alu_op"};
      if (o_alu_src_ID    !== v.exp.alu_src   ) mism = {mism, " alu_src"};
      if (o_result_src_ID !== v.exp.result_src) mism = {mism, " result_src"};
      if (o_branch_ID     !== v.exp.branch    ) mism = {mism, " branch"};
      if (o_jump_ID       !== v.exp.jump      ) mism = {mism, " jump"};
      if (o_reg_write_ID  !== v.exp.reg_write ) mism = {mism, " reg_write"};
      if (o_mem_write_ID  !== v.exp.mem_write ) mism = {mism, " mem_write"};
      if (o_fence_ID      !== v.exp.fence     ) mism = {mism, " fence"};

      if (mism == "") begin
        $display("%-6s 0x%08h  ok", v.name, v.inst);
      end else begin
        $display("%-6s 0x%08h  divergências:%s", v.name, v.inst, mism);
        $display("         exp: imm=%0b addr=%0b aluop=%0b alusrc=%0b res=%0b br=%0b j=%0b rw=%0b mw=%0b fc=%0b",
                 v.exp.imm_src, v.exp.addr_src, v.exp.alu_op, v.exp.alu_src, v.exp.result_src,
                 v.exp.branch, v.exp.jump, v.exp.reg_write, v.exp.mem_write, v.exp.fence);
        $display("         got: imm=%0b addr=%0b aluop=%0b alusrc=%0b res=%0b br=%0b j=%0b rw=%0b mw=%0b fc=%0b",
                 o_imm_src_ID, o_addr_src_ID, o_alu_op, o_alu_src_ID, o_result_src_ID,
                 o_branch_ID, o_jump_ID, o_reg_write_ID, o_mem_write_ID, o_fence_ID);
      end
    end
  endtask

  // (helpers para debug, se quiser)
  function automatic [4:0] opcode5(input logic [31:0] x); opcode5 = x[6:2]; endfunction
  function automatic [2:0] funct3 (input logic [31:0] x); funct3  = x[14:12]; endfunction
  function automatic        funct7b5(input logic [31:0] x); funct7b5 = x[30]; endfunction

  // === Programa de teste: cobre as 37+ instruções do RV32I/E ===
  initial begin
    // U-type
    V.push_back('{name:"LUI",   inst:32'h123450b7, exp:'{imm_src:3'b100, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"AUIPC", inst:32'h00010097, exp:'{imm_src:3'b100, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b11, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});

    // Jumps
    V.push_back('{name:"JAL",   inst:32'h000800ef, exp:'{imm_src:3'b011, addr_src:1'b0, alu_op:3'b000, alu_src:1'b0, result_src:2'b01, branch:1'b0, jump:1'b1, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"JALR",  inst:32'h004302e7, exp:'{imm_src:3'b000, addr_src:1'b1, alu_op:3'b000, alu_src:1'b1, result_src:2'b01, branch:1'b0, jump:1'b1, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});

    // Branches
    V.push_back('{name:"BEQ",   inst:32'h01031c63, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"BNE",   inst:32'h01031ce3, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"BLT",   inst:32'h01035463, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"BGE",   inst:32'h01035563, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"BLTU",  inst:32'h01035663, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"BGEU",  inst:32'h01035763, exp:'{imm_src:3'b010, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b1, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});

    // Loads
    V.push_back('{name:"LB",    inst:32'h00830283, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b10, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"LH",    inst:32'h00831283, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b10, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"LW",    inst:32'h00832283, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b10, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"LBU",   inst:32'h00834283, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b10, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"LHU",   inst:32'h00835283, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b10, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});

    // Stores
    V.push_back('{name:"SB",    inst:32'h00c300a3, exp:'{imm_src:3'b001, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b1, fence:1'b0}});
    V.push_back('{name:"SH",    inst:32'h00c311a3, exp:'{imm_src:3'b001, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b1, fence:1'b0}});
    V.push_back('{name:"SW",    inst:32'h00c322a3, exp:'{imm_src:3'b001, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b1, fence:1'b0}});

    // I-type ALU
    V.push_back('{name:"ADDI",  inst:32'h00530293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLTI",  inst:32'h00531293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b100, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLTIU", inst:32'h00532293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b100, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"XORI",  inst:32'h00534293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b101, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"ORI",   inst:32'h00536293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b110, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"ANDI",  inst:32'h00537293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b111, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLLI",  inst:32'h00131293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SRLI",  inst:32'h00135293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SRAI",  inst:32'h40135293, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});

    // R-type ALU
    V.push_back('{name:"ADD",   inst:32'h007303b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b000, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SUB",   inst:32'h407303b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b001, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLL",   inst:32'h007313b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLT",   inst:32'h007323b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b100, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SLTU",  inst:32'h007333b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b100, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"XOR",   inst:32'h007343b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b101, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SRL",   inst:32'h007353b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"SRA",   inst:32'h407353b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b011, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"OR",    inst:32'h007363b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b110, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"AND",   inst:32'h007373b3, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b111, alu_src:1'b0, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b1, mem_write:1'b0, fence:1'b0}});

    // Miscelânea
    V.push_back('{name:"FENCE", inst:32'h0003000f, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b001, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b1}});
    V.push_back('{name:"ECALL", inst:32'h00000073, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b010, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});
    V.push_back('{name:"EBREAK",inst:32'h00100073, exp:'{imm_src:3'b000, addr_src:1'b0, alu_op:3'b010, alu_src:1'b1, result_src:2'b00, branch:1'b0, jump:1'b0, reg_write:1'b0, mem_write:1'b0, fence:1'b0}});

    // Roda
    $display("=== op_decoder TB ===");
    foreach (V[i]) begin
      check(V[i]);
    end
    $display("=== done ===");
    #1 $finish;
  end

endmodule