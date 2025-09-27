`timescale 10us / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 26.09.2025 08:36:47
// Design Name: 
// Module Name: op_decoder_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module op_decoder_tb;

  // ====== DUT I/O ======
  logic [4:0] i_op;
  logic [2:0] i_funct_3;
  logic       i_funct_7_5;

  logic        o_jump_ID, o_branch_ID, o_reg_write_ID, o_mem_write_ID, o_alu_src_ID, o_addr_src_ID, o_fence_ID;
  logic [1:0]  o_result_src_ID;
  logic [2:0]  o_imm_src_ID, o_alu_op;

  // Ajustar o nome/portas do módulo
  op_decoder dut (
    .i_op(i_op),
    .i_funct_3(i_funct_3),
    .i_funct_7_5(i_funct_7_5),
    .o_jump_ID(o_jump_ID),
    .o_branch_ID(o_branch_ID),
    .o_reg_write_ID(o_reg_write_ID),
    .o_result_src_ID(o_result_src_ID),
    .o_mem_write_ID(o_mem_write_ID),
    .o_alu_src_ID(o_alu_src_ID),
    .o_imm_src_ID(o_imm_src_ID),
    .o_alu_op(o_alu_op),
    .o_addr_src_ID(o_addr_src_ID),
    .o_fence_ID(o_fence_ID)
  );

  // ====== Convenções (esperado) ======
  // result_src_ID:
  //   00 = ALU
  //   01 = PC+4
  //   10 = MemData
  //   11 = PC+imm
  //
  // imm_src_ID:
  //   000 = I  | 001 = S | 010 = B | 011 = J | 100 = U
  //
  // alu_op (classes internas do decoder):
  localparam [2:0] OP_LUI     = 3'b000;
  localparam [2:0] OP_ARITH   = 3'b001; // lógicas/arit. (AND/OR/XOR/shift/SLT… e I-ALU)
  localparam [2:0] OP_ADD_SUB = 3'b010; // somas endereços / SUB
  localparam [2:0] OP_BRANCH  = 3'b011;
  localparam [2:0] OP_ADD     = 3'b100; // PC+4 / PC+imm / ADD puro

  // ====== Vetor e máscara por campo (permite don't care) ======
  typedef struct {
    // Entrada (instr completa para extrair campos + sanity)
    logic [31:0] inst;
    string       name;

    // Esperados
    logic        exp_jump, exp_branch, exp_regw, exp_memw, exp_alusrc, exp_addrsrc, exp_fence;
    logic [1:0]  exp_result_src;
    logic [2:0]  exp_immsrc, exp_aluop;

    // Máscara (1 = checar; 0 = ignorar/don't care)
    logic m_jump, m_branch, m_regw, m_memw, m_alusrc, m_addrsrc, m_fence;
    logic [1:0] m_result_src;
    logic [2:0] m_immsrc, m_aluop;
  } vec_t;

  // ====== Helpers p/ extrair campos ======
  function automatic [4:0] get_op(input logic [31:0] inst);     return inst[6:2];  endfunction
  function automatic [2:0] get_f3(input logic [31:0] inst);     return inst[14:12]; endfunction
  function automatic       get_f7_5(input logic [31:0] inst);   return inst[30];    endfunction

  // ====== Vetores (10 instruções) ======
  vec_t V [0:9];

  initial begin
   $display("initial");

    // 0) JAL x0, 0   (opcode 1101111): jump, result = PC+4, imm = J
    V[0] = '{
      inst: 32'h0000006f, name:"JAL",
      exp_jump:1, exp_branch:0, exp_regw:1, exp_result_src:2'b01, exp_memw:0, exp_alusrc:0, exp_immsrc:3'b011,
      exp_aluop:'0, exp_addrsrc:0, exp_fence:0, // aluop don't care
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b000, m_addrsrc:1, m_fence:1
    };

    // 1) JALR x0, 0(x0) (1100111): jump, addr_src=1 (rs1+imm), result = PC+4, imm = I
    V[1] = '{
      inst: 32'h00000067, name:"JALR",
      exp_jump:1, exp_branch:0, exp_regw:1, exp_result_src:2'b01, exp_memw:0, exp_alusrc:1, exp_immsrc:3'b000,
      exp_aluop:OP_ADD, exp_addrsrc:1, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 2) LUI x5, 0 (0110111): write-back = ALU(0+immU), imm = U
    V[2] = '{
      inst: 32'h000002b7, name:"LUI",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b00, exp_memw:0, exp_alusrc:1, exp_immsrc:3'b100,
      exp_aluop:OP_LUI, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 3) AUIPC x5, 0 (0010111): write-back = PC+imm (11), imm = U
    V[3] = '{
      inst: 32'h00000297, name:"AUIPC",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b11, exp_memw:0, exp_alusrc:1, exp_immsrc:3'b100,
      exp_aluop:OP_ADD, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 4) BEQ x0,x0,0 (1100011): branch=1, imm=B
    V[4] = '{
      inst: 32'h00000063, name:"BEQ",
      exp_jump:0, exp_branch:1, exp_regw:0, exp_result_src:2'b00, exp_memw:0, exp_alusrc:0, exp_immsrc:3'b010,
      exp_aluop:OP_BRANCH, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b00, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 5) ADD  x3,x1,x2 (0110011 funct3=000 funct7=0000000): regw=1, result=ALU, aluop=ADD
    V[5] = '{
      inst: 32'h002080b3, name:"ADD",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b00, exp_memw:0, exp_alusrc:0, exp_immsrc:3'b000,
      exp_aluop:OP_ADD, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b000,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 6) SUB  x3,x1,x2 (0110011 funct3=000 funct7=0100000): regw=1, result=ALU, aluop=ADD_SUB (SUB)
    V[6] = '{
      inst: 32'h402080b3, name:"SUB",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b00, exp_memw:0, exp_alusrc:0, exp_immsrc:3'b000,
      exp_aluop:OP_ADD_SUB, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b000,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 7) AND  x3,x1,x2 (0110011 funct3=111): regw=1, result=ALU, aluop=ARITH
    V[7] = '{
      inst: 32'h0020f0b3, name:"AND",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b00, exp_memw:0, exp_alusrc:0, exp_immsrc:3'b000,
      exp_aluop:OP_ARITH, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b000,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 8) LW x5,0(x2) (0000011 funct3=010): regw=1, result=Mem, imm=I, aluop=ADD_SUB (addr calc)
    V[8] = '{
      inst: 32'h00012283, name:"LW",
      exp_jump:0, exp_branch:0, exp_regw:1, exp_result_src:2'b10, exp_memw:0, exp_alusrc:1, exp_immsrc:3'b000,
      exp_aluop:OP_ADD_SUB, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b11, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };

    // 9) SW x5,0(x2) (0100011 funct3=010): mem_write=1, imm=S, aluop=ADD_SUB (addr calc)
    V[9] = '{
      inst: 32'h00412023, name:"SW",
      exp_jump:0, exp_branch:0, exp_regw:0, exp_result_src:2'b00, exp_memw:1, exp_alusrc:1, exp_immsrc:3'b001,
      exp_aluop:OP_ADD_SUB, exp_addrsrc:0, exp_fence:0,
      m_jump:1, m_branch:1, m_regw:1, m_result_src:2'b00, m_memw:1, m_alusrc:1, m_immsrc:3'b111,
      m_aluop:3'b111, m_addrsrc:1, m_fence:1
    };
  end

  // ====== Infra de checagem ======
  int pass=0, fail=0;

  task automatic check_field(string nm, logic exp, logic got, logic m);
    if (m && (got !== exp)) begin
      $display("[FAIL] %s exp=%0b got=%0b", nm, exp, got);
      fail++;
      disable fork;
    end
  endtask

  task automatic check_field2(string nm, logic [1:0] exp, logic [1:0] got, logic [1:0] m);
    if ((m[1] && (got[1] !== exp[1])) || (m[0] && (got[0] !== exp[0]))) begin
      $display("[FAIL] %s exp=%02b got=%02b", nm, exp, got);
      fail++;
      disable fork;
    end
  endtask

  task automatic check_field3(string nm, logic [2:0] exp, logic [2:0] got, logic [2:0] m);
    if ((m[2] && (got[2] !== exp[2])) || (m[1] && (got[1] !== exp[1])) || (m[0] && (got[0] !== exp[0]))) begin
      $display("[FAIL] %s exp=%03b got=%03b", nm, exp, got);
      fail++;
      disable fork;
    end
  endtask

  task automatic check(vec_t v);
    // Sanidade: instrução de 32b deve ter inst[1:0]==2'b11
    if (v.inst[1:0] !== 2'b11) begin
      $display("[FAIL] %s: inst[1:0]!=11 (0b%b)", v.name, v.inst[1:0]);
      fail++; return;
    end

    // Drive DUT
    i_op        = get_op   (v.inst);
    i_funct_3   = get_f3   (v.inst);
    i_funct_7_5 = get_f7_5 (v.inst);
    #1ns;

    fork
      begin
        check_field ("jump"      , v.exp_jump      , o_jump_ID       , v.m_jump);
        check_field ("branch"    , v.exp_branch    , o_branch_ID     , v.m_branch);
        check_field ("reg_write" , v.exp_regw      , o_reg_write_ID  , v.m_regw);
        check_field2("result_src", v.exp_result_src, o_result_src_ID , v.m_result_src);
        check_field ("mem_write" , v.exp_memw      , o_mem_write_ID  , v.m_memw);
        check_field ("alu_src"   , v.exp_alusrc    , o_alu_src_ID    , v.m_alusrc);
        check_field3("imm_src"   , v.exp_immsrc    , o_imm_src_ID    , v.m_immsrc);
        check_field3("alu_op"    , v.exp_aluop     , o_alu_op        , v.m_aluop);
        check_field ("addr_src"  , v.exp_addrsrc   , o_addr_src_ID   , v.m_addrsrc);
        check_field ("fence"     , v.exp_fence     , o_fence_ID      , v.m_fence);
      end
    join

    if (fail==0) begin
      pass++;
      $display("[PASS] %s", v.name);
    end
  endtask

  initial begin
    // Sequência
    #1ns;
    foreach (V[i]) begin
      int fail_before = fail;
      check(V[i]);
      if (fail > fail_before) $display("  -> Vetor %0d (%s) FALHOU", i, V[i].name);
    end
    $display("==== SUMMARY: PASS=%0d FAIL=%0d ====", pass, fail);
    if (fail==0) $finish(0); else $finish(1);
  end

endmodule
