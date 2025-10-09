# `op_decoder` Validation Overview

The file **`op_decoder_validation_matrix.md`** defines the **expected control signal behavior** for each instruction in the **RISC-V RV32E Base ISA**.

This matrix acts as the **reference truth table** used by the `op_decoder_tb` testbench to compare the **DUT** (`rtl/op_decoder.v`) outputs against the **expected golden model** behavior.

---

## 🧩 Purpose

During simulation, each instruction from the validation matrix is instantiated and decoded by the DUT.  
The testbench then checks that the control signals generated match the expected configuration defined in the matrix.

This approach ensures functional equivalence between the **hardware decoder logic** and the **ISA specification**.

---

## 📋 Verified Fields

| Signal | Description |
|:--------|:-------------|
| `imm_src` | Immediate source format (R / I / S / B / U / J). |
| `addr_src` | Address source (PC / REG / IMM). |
| `alu_op` | Arithmetic or logical operation code. |
| `alu_src` | Second ALU operand source. |
| `result_src` | Writeback data source (ALU / MEM / PC+4 / IMM). |
| `branch` / `jump` / `reg_write` / `mem_write` | Basic control flags. |

---

## 🧠 Notes

- The validation matrix currently covers **37 base instructions** from the RV32E subset.  
- Don’t-care conditions (`X` values) are intentionally allowed for non-relevant fields when `reg_write = 0`.  
- Consistency between this table and the DUT is key for detecting control-path mismatches.

_Last updated: October 2025_