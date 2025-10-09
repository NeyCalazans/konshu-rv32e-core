# `op_decoder` Validation Report

## 📅 Date
September 28, 2025

---

## 🔎 Context

This report summarizes the validation of the **`op_decoder`** module of the **Konshu RV32E** core, executed through the **`op_decoder_tb.sv`** testbench.  
The testbench covered all **37 base instructions** implemented in the RV32E subset.

---

## ✅ Results Summary

### ✔️ Instructions validated with no divergences
- **LUI**

### ⚠️ Identified divergences (confirmed RTL bugs)
- **ECALL / EBREAK** → `reg_write` should be `0`, but is currently `1`.  
- **`result_src` undefined (X)** for instructions with no write-back (expected: fixed or don't-care).

### 🔸 Divergences due to encoding mismatches (`alu_op`)
- **Arithmetic operations (ADD/SUB, etc.):**  
  DUT returns `alu_op = 100` (generic mode), while the TB expected distinct codes.  
- **Branches:**  
  DUT returns `alu_op = 11` vs. TB expected `alu_op = 1`.  
  → These are considered **semantic differences**, not functional bugs.

### 🔹 Divergences from unhandled don’t-care conditions
- `result_src = XX` when `reg_write = 0` (affects branch, store, and fence instructions).

---

## 🧭 Next Steps

1. Update the testbench to ignore `alu_op` (`CHECK_ALU_OP = 0`) and `result_src` when `reg_write = 0`.  
2. Re-run simulations focusing only on **critical (functional)** mismatches.  
3. Prepare and send a summary report to **Rafael Oliveira** confirming verified bug cases.  
4. Align the **`alu_op` enum definitions** between the RTL and the testbench (using a shared package).

---

## 🧩 Notes

These results confirm partial compliance of the Konshu RV32E `op_decoder` with the expected RISC-V Base ISA semantics.  
Remaining differences are related to signal encoding conventions and will be resolved in future iterations.

_Last updated: October 2025_