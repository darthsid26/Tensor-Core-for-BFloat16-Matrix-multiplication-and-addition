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


---
