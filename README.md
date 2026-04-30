# Tensor Core Architecture (BF16 MMA Unit)

## Overview
This repository contains the design and implementation of a **Tensor Core–style fused matrix multiply-and-accumulate (MMA) unit** for a custom GPU architecture. The unit is optimized for **BF16 (bfloat16)** precision and is compatible with CUDA-style execution models. It serves as the fundamental computational block for accelerating deep learning and high‑performance computing workloads.

---

## What Are Tensor Cores?
Tensor Cores are specialized hardware units found in modern NVIDIA GPUs. They accelerate matrix‑intensive operations by performing **fused matrix multiply‑and‑accumulate (MMA)** computations in a single step, significantly increasing throughput compared to traditional CUDA cores.

### Key Features
- **Fused MMA operations:** Performs `D = A × B + C` in one hardware instruction.
- **Mixed‑precision compute:** Supports FP16, BF16, INT8 with higher‑precision accumulation (e.g., FP32).
- **High throughput:** Designed for massively parallel matrix operations.
- **Library integration:** Used extensively through cuDNN, cuBLAS, and TensorRT.

### Common Use Cases
- Deep learning training and inference (CNNs, RNNs, Transformers)
- HPC workloads involving large‑scale linear algebra
- Any GEMM‑dominated GPU compute task

---

## Project Purpose
The goal of this project is to design a **custom Tensor Core unit** capable of accelerating BF16 matrix operations within a GPU pipeline. This unit enables efficient execution of parallel workloads in AI, scientific computing, and numerical applications.

---

## MMA Operation
The core computation implemented is:



\[
D = A \times B + C
\]



### Input Format
- **Matrix A:** Row of four BF16 elements  
- **Matrix B:** Column of four BF16 elements  
- **Matrix C:** Row of four BF16 elements (accumulator)

### Output
- **Matrix D:** Result of the fused dot‑product and accumulation

### Dot‑Product Computation
The Tensor Core computes:



\[
D_i = \sum_{k=0}^{3} A_{ik} \cdot B_k + C_i
\]



This 4‑element dot product forms the **fundamental tile** used to build larger GEMM operations.

---

## Dataflow
1. Matrices **A**, **B**, and **C** are fetched from GPU memory.  
2. The Tensor Core performs the fused MMA operation internally.  
3. The resulting matrix **D** is written back to global memory.

This design supports parallel instantiation, enabling scalable matrix multiplication across many compute units.

## Repository Modules Overview

This repository contains all hardware modules required to implement the BF16 Tensor Core MMA pipeline. Each file contributes to a specific stage of the memory access, arithmetic, or top‑level integration flow.

### Memory Modules
- **A_B_mem.v / A_B_mem.xco**  
  Contains the memory blocks for **Matrix A** and **Matrix B**.  
  These modules store the BF16 input rows (A) and columns (B) used for the dot‑product operation.

- **C_mem.v / C_mem.xco**  
  Stores the **Matrix C** accumulator values.  
  These values are added to the result of the A×B multiplication to produce the final output matrix D.

### Arithmetic Units
- **bfloat16_add_stage1.v**  
  First pipeline stage for BF16 addition. Handles exponent alignment and partial mantissa processing.

- **bfloat16_add_stage2.v**  
  Second pipeline stage for BF16 addition. Finalizes normalization and rounding to produce a BF16‑accurate sum.

- **bfloat16_mult_stage1.v**  
  First pipeline stage for BF16 multiplication. Performs exponent addition and mantissa multiplication.

- **bfloat16_mult_stage2.v**  
  Second pipeline stage for BF16 multiplication. Handles normalization, rounding, and BF16 formatting.

### Matrix Multiplication Logic
- **tensor_top.v**  
  Implements the **core matrix multiplication logic**.  
  This module performs the 4‑element dot‑product between a row of A and a column of B, producing the intermediate A×B result.

### Top‑Level Integration
- **top_upper_tensor.v**  
  The **top‑most module** in the design.  
  Integrates:
  - BF16 multiplication stages  
  - BF16 addition stages  
  - Memory inputs (A, B, C)  
  - Output accumulation  
  This block completes the fused MMA operation:  
  `D = A × B + C`

### Output Aggregation
- **registerfile4.v**  
  Aggregates the **row‑based output matrix**.  
  Collects the four BF16 results produced by the Tensor Core and organizes them into the final output row

  ### Testbench
- **top_upper_tensor_tb.v**  
  This is the **testbench for the Tensor Core**.  
  It verifies the full fused MMA pipeline implemented in `top_upper_tensor.v`, including:
  - Memory reads from A, B, and C memory blocks  
  - BF16 multiplication (stage 1 and stage 2)  
  - BF16 addition (stage 1 and stage 2)  
  - Dot‑product accumulation  
  - Output aggregation through `registerfile4.v`  


---
