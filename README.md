# AES-128 ECB Encryption Core — FPGA Implementation

A hardware implementation of the AES-128 ECB encryption algorithm written in Verilog, validated against NIST FIPS 197 test vectors.

---

## Overview

This project implements the AES-128 (Advanced Encryption Standard) block cipher in Verilog using an iterative architecture. The core performs a full 128-bit encryption in a single clock domain.

The implementation is validated against the official NIST FIPS 197 test vectors:

| Parameter | Value |
|---|---|
| Plaintext | `3243f6a8885a308d313198a2e0370734` |
| Key | `2b7e151628aed2a6abf7158809cf4f3c` |
| Ciphertext | `3925841d02dc09fbdc118597196a0b32` |

---

## Architecture

The design follows a modular, iterative architecture. A top-level FSM controls dataflow through the four AES round operations, reusing the same hardware for all 10 rounds.

```
                    ┌─────────────────────────────────────┐
  plaintext ──────▶ │              top.v                  │
  key       ──────▶ │                                     │ ──▶ cipher
  start     ──────▶ │  [keyExpansion] → [round logic]     │
                    │                                     │ ──▶ done
                    └─────────────────────────────────────┘
```

### Top-Level FSM States

```
IDLE → KEY_EXP → INIT_STATE → SUB_BYTES → SHIFT_ROW → MIX_COL → ADD_RKEY
                                  ▲                               │
                                  └───────────────────────────────┘
                                         (rounds 1–9 loop)
```

The final round (round 10) skips MixColumns, transitioning directly from SHIFT_ROW to ADD_RKEY.

---

## Module Description

| Module | File | Description |
|---|---|---|
| Top level | `top.v` | FSM, dataflow control, module instantiation |
| Key Expansion | `keyExpansion.v` | Iterative AES-128 key schedule, generates all 11 round keys |
| SubBytes | `subBytes.v` | 16-byte parallel S-Box substitution |
| ShiftRows | `shiftRows.v` | Cyclic row shift — pure combinational rewiring |
| MixColumns | `mixColumns.v` | Column mixing using GF(2⁸) arithmetic |
| AddRoundKey | `addKey.v` | 128-bit XOR of state with round key |
| Functions | `functions_header.vh` | Shared functions: sbox_lookup, rcon_lookup, mul2, mul3, gfunc |

### Key Expansion

The key expansion module uses a 7-state FSM to iteratively compute all 44 32-bit words of the AES key schedule:

```
IDLE → G_FUNC → XOR0 → XOR1 → XOR2 → XOR3 → SAVE → (loop back)
```

All 11 round keys are precomputed and stored in a 44-word register array before encryption begins. The top-level FSM requests round keys by index.

### SubBytes

Implemented as 16 parallel combinational S-Box lookups. The S-Box is hardcoded as a 256-entry LUT, synthesized as distributed LUTs on the FPGA. All 16 byte substitutions occur simultaneously in a single clock cycle.

### ShiftRows

Pure combinational rewiring — no logic gates required. Implemented as a single assign statement that rearranges the 128-bit state according to the AES ShiftRows specification.

### MixColumns

Implemented using GF(2⁸) arithmetic. Multiplication by 2 (`mul2`) uses the xtime operation — shift left with conditional XOR by `0x1b`. Multiplication by 3 (`mul3`) is `mul2(x) XOR x`. No general multiplier is required.

---

## File Structure

```
.
├── top.v                  — Top-level AES core and FSM
├── keyExpansion.v         — Key schedule
├── subBytes.v             — SubBytes transformation
├── shiftRows.v            — ShiftRows transformation
├── mixColumns.v           — MixColumns transformation
├── addKey.v               — AddRoundKey transformation
└── functions_header.vh    — Shared Verilog functions (S-Box, RCON, GF arithmetic)
```

---

## Simulation

### Dependencies

- [Icarus Verilog](https://bleyer.org/icarus) — simulation
- [GTKWave](http://gtkwave.sourceforge.net) — waveform viewing

### Running the Simulation

```bash
iverilog -o sim top.v keyExpansion.v subBytes.v shiftRows.v mixColumns.v addKey.v top_tb.v
vvp sim
gtkwave wave.vcd
```

### Expected Output

```
Ciphertext: 3925841d02dc09fbdc118597196a0b32
```

This matches the NIST FIPS 197 Appendix B test vector exactly.

---

## Validation

Each module was independently validated against NIST FIPS 197 intermediate values before integration:

- Key expansion validated against all 44 words from FIPS 197 Appendix A.1
- SubBytes, ShiftRows, MixColumns, AddRoundKey each validated against Appendix B round-by-round intermediate states
- Full encryption validated against Appendix B final ciphertext

---

## Design Decisions

**Iterative architecture** — the same round logic hardware is reused across all 10 rounds, trading throughput for area efficiency. One 128-bit block takes approximately 100 clock cycles to encrypt at 100 MHz.

**Precomputed key schedule** — all 11 round keys are computed once at startup and stored in registers. This adds latency before the first encryption but simplifies the datapath during encryption rounds.

**Parallel SubBytes** — all 16 S-Box lookups are performed simultaneously using combinational logic, keeping SubBytes to a single clock cycle despite operating on 16 bytes.

**MSB-first byte ordering** — byte 0 of the AES state (as defined in FIPS 197) maps to bits [127:120] of the Verilog bus, consistent throughout all modules.

---

## References

- [NIST FIPS 197 — AES Specification](https://csrc.nist.gov/publications/detail/fips/197/final)
- [NIST Cryptographic Algorithm Validation Program — Test Vectors](https://csrc.nist.gov/projects/cryptographic-algorithm-validation-program/block-ciphers)
