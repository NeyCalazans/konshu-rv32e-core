# Konshu RV32E Core Verification

This repository contains **testbenches** and **automation scripts** used to verify the **RV32E core** developed under the **Konshu Project** at UFSC.

---

## 🧠 Purpose

The main objective of this environment is to validate the **`op_decoder`** module against the expected behavior defined by the **RISC-V RV32E Base ISA**.
The verification process ensures that all **control signals** are correctly generated for each instruction, following the canonical truth table defined in the validation matrix.

---

## ▶️ Running the `op_decoder` Testbench

1. Open **Vivado 2025.1**.

2. In the **Tcl Console**, execute the following commands:

   ```tcl
   cd $::env(HOME)/konshu-rv32e-core-verify/scripts/vivado
   source run_tb.tcl
   ```

3. The script automatically:

   * Compiles `rtl/op_decoder.v` and `tb/op_decoder_tb.sv`.
   * Runs the simulation using **XSim**.
   * Prints **PASS/FAIL** results to the console.

---

## 📁 Repository Structure

| Folder     | Description                                        |
| ---------- | -------------------------------------------------- |
| `rtl/`     | RTL under test (Device Under Test — DUT).          |
| `tb/`      | Unit and/or system-level testbenches.              |
| `scripts/` | Tcl scripts and simulation utilities.              |
| `docs/`    | Documentation, validation reports, and issue logs. |

---

## 📄 Documentation Highlights

The `docs/` folder includes:

* `DECODER_ISSUES.md` — List of inconsistencies found in the decoder.
* `reports/op_decoder_report.md` — Validation report summarizing current results.
* `validation/op_decoder_validation_matrix.md` — Canonical control signal matrix used as the reference truth table.
* `TB_GUIDE.md` — Instructions for running and interpreting the testbench logs.

---

## 👩‍💻 Authors

* **Mateus Mendes Sodré**
* **Rodrigo Vinícius Mendonça Pereira**
* **Ney Laert Vilar Calazans**

---

## 📜 License

To be defined according to the **APCI/UFSC project policy**.

---

### 🧩 Notes

This repository is part of the **RISC-V compliance and validation initiative** carried out by the **APCI research group** at the **Federal University of Santa Catarina (UFSC)**.
All content herein aims to support reproducible verification and academic research in open-source RISC-V hardware design.

---
