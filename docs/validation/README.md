# docs/ — Artefatos de Validação do Decoder

Esta pasta contém a tabela verdade canônica para o `op_decoder` e seu plano de testes.

## Arquivos
- `op_decoder_validation_matrix.csv` — matriz em formato de planilha, com as saídas de controle esperadas para cada instrução.
- `op_decoder_validation_matrix.md`  — o mesmo conteúdo em formato Markdown (visualização direta no GitHub).

## Significado das colunas (sinais de controle esperados)
- `imm_src`: qual extrator de imediato usar (R/I/S/B/U/J).
- `addr_src`: base usada para formar endereços-alvo ou entrada B da ALU (`PC`, `REG` (rs1) ou `IMM`).
- `alu_op`: operação simbólica da ALU que o decoder deve selecionar.
- `alu_src`: define se a entrada B da ALU é `RS2`, `IMM` ou `PC`.
- `result_src`: qual valor é escrito de volta em `rd` (`ALU`, `MEM`, `PC4` ou `IMM`).
- `branch` / `jump`: bits de categoria de controle de fluxo.
- `reg_write` / `mem_write`: habilitação de escrita em registrador ou memória.

## Como usar
- Trate esta matriz como a “fonte da verdade” para o testbench: para cada instrução, o TB define a palavra de instrução, decodifica e verifica se o conjunto de sinais de controle coincide com a matriz.
- Se o RTL divergir, altere o RTL ou registre uma (temporária) discrepância em uma célula de `notes` e abra um PR para discutir.
