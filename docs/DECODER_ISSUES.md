# op_decoder – inconsistências encontradas

> Objetivo: registrar cada ajuste necessário, com base no comportamento **esperado** do RV32E/RV32I.

## 1) JALR escreve PC+4 (não dado de memória)
- **Esperado:** `rd = PC + 4`, salto para `(rs1 + imm) & ~1`.
- **Observado:** caminho de writeback configurado como LOAD.
- **Correção aplicada:** mux de writeback seleciona `pc_plus_4` para JALR; `o_jump_ID` ativado.

## 2) LUI confundido com JALR
- **Esperado:** LUI carrega `imm << 12` em `rd` sem salto.
- **Observado:** sinalização de salto/controle incorreta.
- **Correção aplicada:** decodificação de opcode distinta; desativar sinais de jump para LUI.

## 3) ADD vs SUB (funct7)
- **Esperado:** `SUB` tem `funct7=0100000` (bit 30 = 1).
- **Observado:** ambos tratados como `ADD`.
- **Correção aplicada:** teste de `funct7` e seleção de operação SUB.

## 4) ECALL/EBREAK
- **Esperado (Konshu):** não escrevem registrador (side-effects externos).
- **Observado:** writeback habilitado.
- **Correção aplicada:** `reg_write=0` para ECALL/EBREAK.