# op_decoder — Identified Issues and Fixes

> **Purpose:** Document all necessary adjustments to align the `op_decoder` behavior with the expected semantics of the **RISC-V RV32E/RV32I Base ISA**.

---

## 1️⃣ JALR writes PC+4 instead of memory data

- **Expected:** `rd = PC + 4`, jump target = `(rs1 + imm) & ~1`.  
- **Observed:** Writeback path incorrectly configured to `LOAD`.  
- **Fix applied:** Writeback multiplexer now selects `pc_plus_4` for JALR; signal `o_jump_ID` properly asserted.

---

## 2️⃣ LUI misinterpreted as JALR

- **Expected:** `LUI` loads `imm << 12` into `rd` with **no jump**.  
- **Observed:** Incorrect jump/control signaling.  
- **Fix applied:** Introduced separate opcode decoding; jump signals disabled for LUI.

---

## 3️⃣ ADD vs. SUB (`funct7` distinction)

- **Expected:** `SUB` uses `funct7 = 0100000` (bit 30 = 1).  
- **Observed:** Both operations were handled as `ADD`.  
- **Fix applied:** Decoder now checks `funct7` and selects the correct SUB operation.

---

## 4️⃣ ECALL / EBREAK

- **Expected (Konshu specification):** These instructions should **not** write back to any register (they trigger external side-effects only).  
- **Observed:** `reg_write` signal was still active.  
- **Fix applied:** Disabled `reg_write` for ECALL and EBREAK.

---

_Last updated: October 2025_