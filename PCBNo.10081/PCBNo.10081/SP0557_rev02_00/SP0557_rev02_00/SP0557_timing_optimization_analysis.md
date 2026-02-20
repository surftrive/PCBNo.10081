# SP0557 FPGA Timing Constraint Optimization Analysis

## 1. Current Resource Utilization Summary

| Resource | Used | Available | Utilization |
|----------|------|-----------|-------------|
| **SLICE** | **10,133** | **12,144** | **83% (Critical)** |
| Registers (PFU) | 8,692 | 24,288 | 36% |
| Registers (PIO) | 83 | 591 | 14% |
| LUT4 (Logic) | 9,188 | 24,288 | 38% |
| LUT4 (Ripple/Carry) | 5,978 | - | - |
| CCU2C (Carry Chain) | 2,989 | - | - |
| PIO | 127 | 197 | 64% |
| Block RAM (EBR) | 4 | 56 | 7% |
| PLL | 1 | 2 | 50% |
| DSP | 0 | 56 | 0% |

**Problem**: SLICE utilization 83% causes routing congestion and leaves minimal room for design changes.

---

## 2. Clock Domain Analysis

### 2.1 Clock Tree

All PLL outputs are derived from external `UP_CLK` (20MHz) via single EHXPLLL:

| Clock Net | Source | Frequency | Loads | Setup Slack | Status |
|-----------|--------|-----------|-------|-------------|--------|
| `s_PLL_CLK20M` | CLKOS2 | 20 MHz | 4,645 | 29.2 ns | Excessive margin |
| `slv_com_top_inst.CLK1` | CLKOS3 | 10 MHz | 327 | OK | |
| `slv_com_top_inst.CLKCOM_OUT` | CLKOP | 100 MHz | 163 | **0.244 ns** | **Critical** |
| `slv_com_top_inst/CLK2A` | CLKOS | 100 MHz | 16 | 6.1 ns | OK |
| `CLK20M_c` | External pin | 20 MHz | 9 | N/A | PLL ref only |
| `UP_CLK_c` | External pin | 20 MHz | 1 | N/A | PLL ref only |

### 2.2 Cross-Domain Transfers (TWR Report)

| Source Domain | Dest Domain | Transfers | Analysis Constraint |
|---------------|-------------|-----------|-------------------|
| s_PLL_CLK20M | CLK1 | 2,393 | 10 MHz (CLK1) |
| CLK1 | s_PLL_CLK20M | 85 | 20 MHz (s_PLL_CLK20M) |
| CLK1 | CLKCOM_OUT | 23 | 100 MHz (CLKCOM_OUT) |
| CLKCOM_OUT | CLK1 | 59 | 10 MHz (CLK1) |
| CLKCOM_OUT | CLK2A | 4 | 100 MHz (CLK2A) |
| CLK2A | CLKCOM_OUT | 2 | 100 MHz (CLKCOM_OUT) |

**Key finding**: 2,393 paths from s_PLL_CLK20M to CLK1 dominate cross-domain analysis.

---

## 3. Occupancy Root Cause Analysis

### 3.1 Major Resource Consumers (by Module)

| Module | Instances | Estimated SLICEs | Dominant Resource |
|--------|-----------|-----------------|-------------------|
| **stm01-stm13** (ppmc_top_S118M) | 13 | ~4,000-5,000 | Carry chains (speed/pulse/timer counters), registers |
| **gpio01** (gpio_top) | 1 | ~500-700 | 20 output registers x 8-16bit, CE fanout 125 |
| **gpio02** (gpio_top) | 1 | ~400-600 | 20 output registers, CE fanout 73 |
| **ENC_inst** (enc_func_top) | 1 (13ch) | ~1,500-2,000 | 13 encoder channels, comparators, limit detection |
| **slv_com_top_inst** | 1 | ~1,000-1,500 | 8b10b, CRC, CDC FIFO logic, address decode |
| **sp_conv_inst** | 1 | ~200-300 | SPI master, shift registers |
| **Other** (ADC, DAC, LED, etc.) | 5 | ~500-800 | I2C, SPI controllers |

### 3.2 High-Utilization Root Causes

1. **13x Stepper Motor Controllers (stm01-stm13)**: Each ppmc_top_S118M includes pulse counter (ppmc_pls_cnt), speed counter (ppmc_speed_cnt), timer counter (ppmc_timer_cnt), and accelerator (ppmc_acc_tim_gen). These contain numerous carry chains (CCU2C: 2,989 total), which are the primary driver of SLICE consumption.

2. **High-Fanout Control Signals**:
   - `ENC_inst.enc_func.1.un16_p_enc_stm`: fanout **438**, route delay **7.4ns**
   - `s_ENC_MODE[1]`: fanout **116**, route delay **3.4ns**
   - `gpio01/N_60_i`: CE fanout **125**
   - `gpio01/N_332_i`: CE fanout **74**

3. **Reset Network Pressure**: 5 PPMC reset signals (`nMRST_i_1`) each with 136-137 loads, consuming primary clock routing resources.

4. **Clock Enable Explosion**: 723 clock enables, mostly from GPIO register write enables and PPMC control logic.

---

## 4. Proposed LPF Timing Constraints

### 4.1 Added Constraints (in SP0557.lpf)

#### A. Explicit Frequency Constraints
```
FREQUENCY NET "s_PLL_CLK20M" 20.000000 MHz ;
FREQUENCY NET "slv_com_top_inst.CLK1" 10.000000 MHz ;
FREQUENCY NET "slv_com_top_inst.CLKCOM_OUT" 100.000000 MHz ;
FREQUENCY NET "slv_com_top_inst/CLK2A" 100.000000 MHz ;
FREQUENCY NET "UP_CLK_c" 20.000000 MHz ;
```
**Rationale**: Synplify auto-detects PLL clocks, but explicit constraints ensure consistency between synthesis and P&R, and prevent Synplify from using overaggressive 200MHz default constraints (seen in synplify LPF comments).

#### B. FALSE_PATH: CLK20M_c <-> PLL Output Clocks
```
BLOCK PATH FROM CLKNET "CLK20M_c" TO CLKNET "s_PLL_CLK20M" ;
BLOCK PATH FROM CLKNET "CLK20M_c" TO CLKNET "slv_com_top_inst.CLK1" ;
... (8 paths total)
```
**Rationale**: `CLK20M_c` is an external clock that feeds only the PLL input. No functional data transfer exists between the CLK20M_c clock domain (9 loads) and any PLL output domain. Any apparent paths are through the PLL itself and are not real data paths. Blocking these eliminates unnecessary timing analysis and frees router from optimizing non-existent paths.

**Expected Impact**: Minor SLICE reduction, but improves P&R runtime and prevents routing congestion from phantom paths.

#### C. MULTICYCLE_PATH: s_PLL_CLK20M <-> CLK1
```
MULTICYCLE FROM CLKNET "s_PLL_CLK20M" TO CLKNET "slv_com_top_inst.CLK1" 2 X ;
MULTICYCLE FROM CLKNET "slv_com_top_inst.CLK1" TO CLKNET "s_PLL_CLK20M" 2 X ;
```
**Rationale**: s_PLL_CLK20M (20MHz) and CLK1 (10MHz) are from the same PLL with a 2:1 frequency ratio. Data launched from the 20MHz domain is captured by the 10MHz domain, which samples every other 20MHz cycle. The effective transfer window is 2 source clock periods (100ns), not 1 (50ns).

**Expected Impact**: **High**. Relaxes **2,478 cross-domain paths** (2,393 + 85), significantly reducing routing pressure in the P&R tool. This is the single highest-impact constraint.

#### D. BLOCK PATH: s_PLL_CLK20M <-> CLKCOM_OUT/CLK2A
```
BLOCK PATH FROM CLKNET "s_PLL_CLK20M" TO CLKNET "slv_com_top_inst.CLKCOM_OUT" ;
BLOCK PATH FROM CLKNET "s_PLL_CLK20M" TO CLKNET "slv_com_top_inst/CLK2A" ;
... (4 paths total)
```
**Rationale**: The 20MHz system domain and the 100MHz communication domain are separated by DCFIFO IP blocks (dcfifo_rx_b1, dcfifo_rx_b2, dcfifo_tx_b1, dcfifo_tx_b2) which handle CDC internally. Direct timing analysis between these domains is both unnecessary and harmful - it forces the P&R to optimize paths that are already safely handled by the FIFO architecture.

**Expected Impact**: **High**. Prevents over-constraining of DCFIFO-bridged paths, allowing the router more freedom.

---

## 5. Additional Optimization Recommendations

### 5.1 Synplify SDC Constraints (for .sdc/.fdc file, if applicable)

If a separate SDC/FDC file is used for Synplify, consider adding:

```tcl
# Prevent timing-driven replication on low-criticality paths
# (Synplify added 18 extra registers for replication)
define_attribute {stm*} syn_replicate {0}
define_attribute {gpio*} syn_replicate {0}
define_attribute {ENC_inst} syn_replicate {0}
```

### 5.2 Synplify Synthesis Options (in .prj or strategy)

- **syn_effort**: Set to "area" instead of default "timing" for stm/gpio/encoder modules
- **syn_sharing**: Enable resource sharing for arithmetic operators in PPMC modules
- **syn_ramstyle**: Consider block_ram for large register files in gpio modules

### 5.3 Future RTL Considerations (if RTL changes become acceptable)

1. **PPMC Counter Sharing**: The 13 PPMC instances each have independent counters. If motor control timing allows, time-multiplexing 2-3 motors per controller could reduce SLICE count by ~30-40%.

2. **Encoder Channel Reduction**: The 10-level combinational path from gpio01 to ENC_inst (fanout 438) suggests the encoder mode selection logic could benefit from pipelining.

3. **Block RAM Migration**: With only 4/56 EBRs used, GPIO register banks (20 registers x 8-16 bits x 2 GPIO instances) could be moved to block RAM, freeing ~200-300 SLICEs.

---

## 6. Expected Results

| Metric | Before | After (Expected) |
|--------|--------|-------------------|
| SLICE Utilization | 83% | **75-78%** |
| Cross-domain paths analyzed | ~2,500 | ~0 (blocked/multicycle) |
| P&R Runtime | ~3m 18s | ~2m 30s (estimated) |
| CLKCOM_OUT Slack | 0.244 ns | 0.3-0.5 ns (improved routing) |
| s_PLL_CLK20M Slack | 29.2 ns | ~29 ns (unchanged) |

**Note**: SLICE reduction of 5-8% (500-1000 SLICEs) is expected primarily from:
- Elimination of routing congestion that forces sub-optimal SLICE packing
- Reduced timing-driven logic replication
- More efficient placement when router has fewer constraints to satisfy

---

## 7. Verification Checklist

After rebuilding with new constraints:

- [ ] Timing closure: all 0 timing errors (check .twr)
- [ ] SLICE utilization: verify reduction from 83%
- [ ] CLKCOM_OUT domain: verify slack >= 0.2ns (critical path)
- [ ] Hold time: verify no new hold violations
- [ ] Functional verification: confirm DCFIFO CDC paths still work correctly
- [ ] Bitstream generation: successful .bit file creation
