# Direct-Mapped Cache Controller Design

BIL361 – Computer Architecture and Organization  
Homework 2

## Overview

This project implements a **Direct-Mapped Cache Controller** in **Verilog HDL** for a 32-bit memory system. The controller sits between the processor and the main memory, handling all memory requests while reducing memory access latency through caching.

The design follows the specifications provided in the course assignment and supports a **2 KB direct-mapped cache** with **16-byte cache lines**. The controller communicates with both the processor and main memory using the **Ready/Valid handshake protocol**.

---

## Objectives

The main objectives of this project are:

- Design a synthesizable direct-mapped cache controller
- Implement cache read and write operations
- Handle cache hits and misses correctly
- Support communication using the Ready/Valid protocol
- Analyze cache performance through simulation
- Evaluate cache hit ratio and execution time improvements

---

## Cache Specifications

The implemented cache has the following characteristics:

| Property | Value |
|----------|-------|
| Address Size | 32 bits |
| Addressing | Byte Addressable |
| Cache Organization | Direct-Mapped |
| Cache Size | 2 KB |
| Cache Line Size | 16 Bytes |
| Write Hit Policy | Write Through |
| Write Miss Policy | Write Allocate |

---

## System Architecture

The cache controller operates between the processor and main memory.

The controller determines whether each memory access results in a **cache hit** or **cache miss**, manages cache updates, and forwards requests to main memory when necessary.

---

## Features

- Direct-mapped cache implementation
- 32-bit addressing
- 16-byte cache blocks
- Ready/Valid handshake communication
- Cache hit detection
- Cache miss handling
- Write Allocate policy
- Write Through policy
- Synthesizable Verilog implementation
- Simulation-based performance evaluation

---

## Technologies Used

- Verilog HDL
- Vivado
---


## Cache Operation

### Read Operation

1. Processor sends a read request.
2. Cache controller checks the corresponding cache line.
3. If the requested block exists (**cache hit**):
   - Data is immediately returned to the processor.
4. Otherwise (**cache miss**):
   - The requested block is fetched from main memory.
   - Cache contents are updated.
   - Requested data is returned to the processor.

---

### Write Operation

The controller follows two different write policies.

#### Write Hit

If the requested address already exists in the cache:

- Cache is updated.
- Main memory is updated immediately (**Write Through**).

#### Write Miss

If the requested address is not in the cache:

- Cache allocates a new cache line (**Write Allocate**).
- Data is fetched from memory.
- Cache is updated.
- Main memory is updated.

---

## Performance Analysis

Simulation results demonstrate a significant performance improvement when using the cache.

| Configuration | Execution Time |
|--------------|---------------:|
| Without Cache | 15,564,897 ns |
| With Cache | 6,502,497 ns |

The cache reduced the execution time by approximately **2–2.5×**, showing the effectiveness of caching in reducing memory access latency.

---

## Cache Statistics

Two hardware counters were implemented for performance analysis.

| Counter | Value |
|---------|------:|
| Total Memory Accesses | 32,768 |
| Cache Misses | 2,048 |

Cache Hit Rate:

```
Hit Rate =
(Total Accesses − Cache Misses)
/ Total Accesses

= (32768 − 2048) / 32768

≈ 93.75%
```

Approximately **15 out of every 16 memory accesses** were served directly from the cache.

---

## Design Decisions

Several architectural choices contribute to the controller's performance:

- Direct-mapped organization for simple hardware implementation
- 16-byte cache lines to exploit spatial locality
- Write Allocate policy for write misses
- Write Through policy to maintain memory consistency
- Ready/Valid interfaces for processor and memory communication

---

## Locality Analysis

Simulation results indicate that the benchmark exhibits both:

### Spatial Locality

The program frequently accesses nearby memory addresses.

Using larger cache blocks allows neighboring data to be fetched together, reducing future cache misses.

### Temporal Locality

Previously accessed data is reused later during execution.

Keeping more cache lines increases the probability that frequently accessed data remains in the cache.

---

## Possible Improvements

Several modifications could further improve system performance.

- Since the program exhibits high spatial locality, using larger cache blocks increases the cache hit rate by reducing the number of requests sent to main memory, thereby improving overall performance.

- Similarly, because the program also exhibits high temporal locality, increasing the number of cache lines helps keep frequently accessed data in the cache for a longer period, resulting in a higher cache hit rate.

- Furthermore, if the cache were not direct-mapped, implementing a Least Recently Used (LRU) replacement policy would further improve the cache hit rate by evicting the least recently accessed cache block.

- Finally, replacing the Write Through policy with a Write Back policy would reduce the number of writes to main memory, leading to better overall system performance.

These improvements would reduce cache conflicts and increase the overall cache hit ratio.

---

## Learning Objectives

This project provided practical experience with:

- Cache memory organization
- Direct-mapped cache design
- Verilog HDL
- Memory hierarchy
- Cache replacement and write policies
- Ready/Valid communication protocol

---
For further information about project requirements, see `BİL361-ODEV2-BAHAR-2024-2025.pdf`.

For further information about results and visualizaiton of test results, see `rapor.pdf`.
