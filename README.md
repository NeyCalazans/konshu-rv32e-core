# konshu-rv32e-core-verify

Repositório para **testbenches** e **scripts** de verificação do CORE RV32E do projeto Konshu.

## Como rodar a testbench do `op_decoder`
1. Abra o Vivado.
2. No Tcl Console:
cd $::env(HOME)/konshu-rv32e-core-verify/scripts/vivado
source run_tb.tcl
3. O script compila `rtl/op_decoder.v` + `tb/unit/op_decoder_tb.sv`, roda a simulação e imprime `PASS/FAIL`.

## Estrutura
- `rtl/` – RTL sob teste (DUT).
- `tb/` – Testbenches (unit e/ou system).
- `scripts/` – TCL e utilidades.
- `docs/` – documentação (issues do decoder, guia da TB, changelog).

## Autores
Mateus Mendes Sodré
Rodrigo Vinícius Mendonça Pereira
Ney Calazans