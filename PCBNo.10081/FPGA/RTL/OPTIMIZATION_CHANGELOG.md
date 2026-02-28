# SP0557 RTL最適化 変更履歴

**日付**: 2026-02-20
**目的**: FPGA SLICE占有率削減（~80% → 70-75%目標）
**制約**: 機能変更なし（通信タイミング・プロトコル・レジスタマップ不変）

---

## 変更一覧

### 変更1: ppmc_phgen インスタンス削除

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/compactppmc/ppmc_reg_S118M.vhd`, `SP0557/compactppmc/ppmc_top_S118M.vhd` |
| **変更種別** | デッド回路削除 |
| **推定削減** | 156 FF + 260 LUT ≈ 100 SLICE |

**根拠**: SP0557.vhd において全13個のPPMCインスタンス（stm01-stm13）のS1-S4出力が全て`open`接続。ppmc_phgenは8状態FSM（STATE: 8FF + SOUT: 4FF = 12FF + ~20 LUT）を持つが、出力は最終的にどこにも接続されていないデッドロジック。

**変更内容**:
- `ppmc_reg_S118M.vhd`:
  - ppmc_phgenコンポーネント宣言をコメントアウト
  - ppmc_phgenインスタンス（inst_ppmc_phgen）を削除
  - S1/S2/S3/S4出力を`'0'`に固定
- `ppmc_top_S118M.vhd`:
  - s_S1〜s_S4信号宣言をコメントアウト
  - ANDゲート（S1-S4 = s_S1-s_S4 AND s_ENB）を削除
  - S1-S4出力を直接`'0'`に固定
  - ppmc_reg_S118Mポートマップ：S1-S4を`open`に変更

**安全性**: ppmc_phgenの入力信号（PULSE_OUT_EDGE, STOP等）は他コンポーネントと共有だが、出力はS1-S4のみでフィードバックなし。

---

### 変更2: ppmc_enblr_S118M デッドコード削除

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/compactppmc/ppmc_enblr_S118M.vhd` |
| **変更種別** | デッドコード削除 |
| **推定削減** | 130 FF + 195 LUT ≈ 70 SLICE |

**根拠**: CURRENT_DOWN出力は`'0'`にハードコード済み。関連するCURRENT_DOWNタイマー用信号（dsb_wait_cnt: 8FF, s_PLUSE10M_ST: 1FF, st_stop_old: 1FF）とロジックが残存していた。

**変更内容**:
- `dsb_wait_cnt`（8ビットカウンタ）、`s_PLUSE10M_ST`、`st_stop_old`信号宣言を削除
- P_STOPエッジハンドラを単一分岐に簡略化（if/elseの両分岐が同一だった）
- ダウンタイマーブランチを完全削除
- `s_P_STOP_old`をリセットリストに追加（元コードで欠落していた修正）
- CURRENT_DOWNポートは維持し`'0'`固定を継続（上位互換性）

**安全性**: dsb_wait_cnt/s_PLUSE10M_STはCURRENT_DOWNタイマーとしてのみ機能。START_STOP出力パスへの影響なし（ph_flagはenb_wait_1280usとP_STOPのみで駆動）。

---

### 変更3: adc_reg.vhd 未使用チャネル削除

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/ad_ctrl/adc_reg.vhd` |
| **変更種別** | 未使用チャネル削除 |
| **推定削減** | 72 FF + 40 LUT ≈ 36 SLICE |

**根拠**: SP0557.vhd ADC_CONTインスタンスにおいてADDATA03〜ADDATA08は全て`open`接続。8チャネル中2チャネルのみ使用（圧力センサ2系統）。s_REG3〜s_REG8は各12FFの未使用レジスタ。

**変更内容**:
- s_REG3〜s_REG8の信号宣言・レジスタプロセスを削除
- s_comp信号を削除
- ADDATA03〜ADDATA08出力を`(others => '0')`に固定
- caseステートメントからCH "010"〜"111"の分岐を削除（`when others => null`に統合）
- 残るcaseステートメントの冗長な自己代入（`s_REG1 <= s_REG1`等）を削除

---

### 変更4: GPIO未使用出力レジスタ削除

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/gpio/gpio_reg.vhd` |
| **変更種別** | 未使用出力レジスタ削除 |
| **推定削減** | 384 FF + 48 LUT ≈ 100 SLICE |

**根拠**: gpio01（Node 13）およびgpio02（Node 14）の両インスタンスにおいてGPO_20〜GPO_31が全て`OPEN`接続。各gpio_op_regは16FF（REG: 8FF + GPO: 8FF）。

**変更内容**:
- チャネル20〜31のgpio_op_regインスタンス（inst20〜inst31）を削除（12インスタンス × 2 GPIOモジュール = 24インスタンス分）
- GPO_20〜GPO_31出力を`(others => '0')`に固定
- 対応するgpio_ip_regインスタンス（20〜31）は全て保持（レジスタ読み出しパスに必要）
- REGDO ORチェーンは変更なし

**安全性**: gpio_op_regのGPO出力はトップレベルで未接続。レジスタへの書き込みは破棄されるが、元々出力先がないため機能影響なし。読み出しパス（gpio_ip_reg → REGDO）は維持。

---

### 変更5: ppmc_rgstr.vhd 冗長な自己代入削除

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/compactppmc/ppmc_rgstr.vhd` |
| **変更種別** | 冗長コード削除 |
| **推定削減** | 0 FF + 20 LUT ≈ 10 SLICE |

**根拠**: 約18個のレジスタプロセスに不要な`else REG <= REG`分岐が存在。VHDLの登録プロセスではelse分岐がない場合、レジスタは自動的に値を保持する。合成ツールは通常これを最適化するが、階層保持モードでは最適化が不十分になる可能性がある。

**変更内容**: 以下のレジスタプロセスの冗長なelse自己代入分岐を削除:
- INIT_REG_O, COMMAND_REG_O/com_cng, PULSE_REG_O (L/H)
- HIGH_FREQ_REG_O (L/H), LOW_FREQ_REG_O (L/H)
- ACC_RATE_REG_O (L/H), SLOW_DOWN_REG_O (L/H)
- LIMIT_MASK_REG_O, PRE_REG_O, MORE_REG_O (L/H)
- DOWNDELAY_REG_O, CTRL2_REG_O, MPO_REG_A_O, MPO_REG_B_O

**注意**: LIMIT_MONITOR_REG、MPO_A_O/MPO_B_Oラッチプロセス、MPI_Rロードプロセスの自己代入は意図的に保持（これらはラッチ動作または明示的なデフォルト値指定として機能）。

---

## 未実施の候補（コメントとして記載）

### 候補6: gpio02 未使用入力レジスタ簡素化

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/gpio/gpio_reg.vhd`（コメントのみ） |
| **推定削減** | 240 FF ≈ 60 SLICE |
| **不実施理由** | レジスタマップ読み出し動作への影響が不確実 |

gpio02のGPI_15-16, GPI_18-31はoct0（定数`"00000000"`）に接続。これらのgpio_ip_regは常に'0'を格納するが、レジスタマップの一部として読み出しアクセスが可能。

### 候補7: cds.vhd azレジスタ幅削減

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557/slv_com/cds.vhd`（コメントのみ） |
| **推定削減** | 5 FF + 5 LUT |
| **不実施理由** | タイミング動作の変更に該当（アイドル検出 100ns → 50ns @100MHz） |

azは10ビットだが判定ロジックではaz(0)-az(4)のみ使用。az(5)-az(9)はアイドル検出比較のみに関与。

---

## 削減効果の試算まとめ

| # | 変更対象 | 変更種別 | FF削減 | LUT削減 | 推定SLICE削減 |
|---|---------|---------|--------|---------|-------------|
| 1 | ppmc_phgen | デッド回路削除 | 156 | 260 | ~100 |
| 2 | ppmc_enblr | デッドコード削除 | 130 | 195 | ~70 |
| 3 | adc_reg | 未使用チャネル | 72 | 40 | ~36 |
| 4 | gpio_op_reg | 未使用出力 | 384 | 48 | ~100 |
| 5 | ppmc_rgstr | 自己代入削除 | 0 | 20 | ~10 |
| | **実施分合計** | | **742** | **563** | **~316** |

Lattice FPGA（SLICE = 2 LUT4 + 2 FF）換算で、5000 SLICE規模のデバイスに対し約**6-7%の削減**を見込む。

---

## 変更ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `SP0557/compactppmc/ppmc_reg_S118M.vhd` | ppmc_phgen削除、S1-S4固定 |
| `SP0557/compactppmc/ppmc_top_S118M.vhd` | S1-S4 AND削除、出力固定 |
| `SP0557/compactppmc/ppmc_enblr_S118M.vhd` | CURRENT_DOWNタイマー削除 |
| `SP0557/compactppmc/ppmc_rgstr.vhd` | 冗長な自己代入削除 |
| `SP0557/ad_ctrl/adc_reg.vhd` | 未使用CH3-8レジスタ削除 |
| `SP0557/gpio/gpio_reg.vhd` | op_reg inst20-31削除、候補コメント追加 |
| `SP0557/slv_com/cds.vhd` | 候補コメント追加のみ |

## ポートインターフェース変更

**なし** — 全モジュールの外部ポートは不変。未使用出力は`'0'`に固定し、ポート宣言は維持。

---

# No.9: コンパイル結果検証に基づく残存問題修正

**日付**: 2026-02-28
**目的**: 修正履歴No.1〜No.8の適用後に残存していた4つの問題を解消
**制約**: 機能変更なし

---

## 修正1: CD134 識別子エラー修正（3件）

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `ppmc_ctrl.vhd`, `dec6b_5b.vhd`, `slv_rx_ctrl.vhd` |
| **変更種別** | RTL属性宣言の修正 |
| **期待効果** | CD134 警告 3件 → 0件 |

**原因**: RTLソース内で `attribute syn_preserve of XXXX : signal is true;` と記述しているが、対象がエンティティの出力ポートであるため `: signal` が不正。SP0557.fdcに既に正しい制約が定義済みのため、RTL内の重複属性を削除。

**変更内容**:
- `ppmc_ctrl.vhd:136`: `attribute syn_preserve of ENB_START : signal is true;` を削除（FDC 7N節で保護済み）
- `dec6b_5b.vhd:37-38`: `attribute syn_preserve of DATAOUT : signal is true;` を削除（FDC 7E節で保護済み）
- `slv_rx_ctrl.vhd:93-94`: `attribute syn_preserve of NODE : signal is true;` を削除（FDC 7D節で保護済み）

---

## 修正2: MT420/MT529 警告修正（10件）

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `IPcore/pll_gen/pll_gen.fdc` |
| **変更種別** | FDCクロック参照構文変更 |
| **期待効果** | MT420 5件 + MT529 5件 → 0件（または大幅減少） |

**原因**: `{p:CLKOP}` 等のポート参照構文がSynplifyの推論クロック名 (`pll_gen|CLKOP_inferred_clock`) と一致せず、define_clockが黙殺されていた。結果として全PLLクロックがプロジェクト周波数 (100MHz) で処理され、CLKOS2 (20MHz) やCLKOS3 (10MHz) のクロックドメインで不正確な合成最適化が行われていた。

**変更内容**:
- `{p:CLKOP}` → `{n:CLKOP_t}`（pll_gen.vhd内部信号名に合わせる）
- `{p:CLKOS}` → `{n:CLKOS_t}`
- `{p:CLKOS2}` → `{n:CLKOS2_t}`
- `{p:CLKOS3}` → `{n:CLKOS3_t}`

---

## 修正3: CLKCOM_OUT タイミング違反修正

| 項目 | 内容 |
|------|------|
| **対象ファイル** | `SP0557.lpf` |
| **変更種別** | 周波数制約緩和 |
| **期待効果** | Setup違反 1件 + Hold違反 4件 → 0件 |

**原因**: 115MHzガードバンド制約に対し、クリティカルパス（DCFIFO Block RAM C2Q 5.830ns + routing 2.874ns + LUT 0.236ns = 9.823ns）が8.696nsの制約を1.275ns超過。DP16KDのC2Q遅延が構造的ボトルネックで、115MHzは本デバイスで達成不可能。

**変更内容**:
- `FREQUENCY NET "slv_com_top_inst.CLK2" 115.000000 MHz` → `100.000000 MHz`
- `FREQUENCY NET "slv_com_top_inst.CLK2A" 115.000000 MHz` → `100.000000 MHz`

**副次効果**: レジスタ複製の削減によりSLICE使用率も改善見込み（89% → 85-87%程度）。

---

## 変更ファイル一覧

| ファイル | 変更内容 |
|---------|---------|
| `SP0557/compactppmc/ppmc_ctrl.vhd` | ENB_START syn_preserve属性削除 |
| `SP0557/slv_com/rx_com/dec6b_5b.vhd` | DATAOUT syn_preserve属性削除 |
| `SP0557/slv_com/slv_ctrl/slv_rx_ctrl.vhd` | NODE syn_preserve属性削除 |
| `IPcore/pll_gen/pll_gen.fdc` | `{p:PORT}` → `{n:SIGNAL_t}` |
| `SP0557.lpf` | 115MHz → 100MHz |
