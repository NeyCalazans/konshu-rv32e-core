# Testbench Usage Guide

This guide describes how to **run** and **interpret** the testbench used to validate the `op_decoder` module of the Konshu RV32E core.

---

## ⚙️ Overview

- **Top module:** `op_decoder_tb`  
- **Simulation tool:** Vivado **XSim 2025.1**  
- **Execution script:** `scripts/vivado/run_tb.tcl`

---

## 🧪 Running the Testbench

To execute the simulation, open **Vivado 2025.1** and run:

```tcl
cd $::env(HOME)/konshu-rv32e-core-verify/scripts/vivado
source run_tb.tcl
````

The script automatically compiles the DUT and testbench, launches XSim, and prints a summary of the results.

---

## 🧾 Log Convention

The console output follows this format:

1. Prints the **instruction name** and its decoded fields.
2. If applicable, lists any **errors** or mismatches found during validation.
3. At the end of the run, displays a **summary** with total counts of PASS and FAIL cases.

Example output:

```
[TEST] add x1, x2, x3
PASS
[TEST] ebreak
ERROR: reg_write should be 0
---
Summary: 36 PASS / 1 FAIL
```

---

## 🪄 Notes

* All messages are printed directly to the **Vivado Tcl Console**.
* Log output can be redirected to a file if persistent records are needed for automated analysis.
* The `result_src`, `alu_op`, and `reg_write` signals are the primary indicators for correctness in current validation runs.

---

*Last updated: October 2025*