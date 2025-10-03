# Relatório de Validação do `op_decoder`

## 📅 Data
28/09/2025

## 🔎 Contexto
Validação do módulo `op_decoder` do core Konshu RV32E através do testbench `op_decoder_tb.sv`.  
Foram rodados testes cobrindo as 37 instruções da ISA base implementadas.

## ✅ Resultados

- **Instruções validadas sem divergências:**  
  - LUI

- **Divergências identificadas (reais bugs no RTL):**  
  - ECALL/EBREAK → `reg_write` deveria ser 0, mas está em 1.  
  - `result_src` indefinido (X) em instruções sem write-back (esperado: fixo ou don’t-care).

- **Divergências por diferença de codificação (`alu_op`):**  
  - ADD/SUB e demais aritméticas → DUT devolve `alu_op=100` (modo genérico),  
    enquanto a TB esperava códigos distintos.  
  - Branches → `alu_op=11` no DUT vs. `alu_op=1` esperado na TB.  
  → Consideramos divergências de **semântica**, não bugs.

- **Divergências por don’t-care não tratado:**  
  - `result_src=xx` quando `reg_write=0` (branches, stores, fence).

## 📝 Próximos passos
1. Atualizar TB para ignorar `alu_op` (CHECK_ALU_OP=0) e `result_src` quando `reg_write=0`.  
2. Rodar novamente para focar só nos erros “quentes”.  
3. Preparar e enviar resumo para Rafael confirmando os casos de bug.  
4. Depois alinhar enums do `alu_op` entre RTL e TB (package compartilhado).