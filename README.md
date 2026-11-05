# VGA Controller Verification (640x480 @ 60Hz)

Môi trường kiểm thử (Design Verification) cho DUT **VGA timing controller** 640×480 @ 60Hz viết bằng Verilog. Dự án tập trung vào **xây dựng verification plan, testbench, checker và assertion** để chứng minh DUT đúng timing chuẩn VGA, thay vì chỉ soi dạng sóng bằng mắt.

## Mục tiêu Verification

- Xây dựng verification plan truy vết được từ spec → check → kết quả
- Chuyển từ Directed Testbench sang **Self-Checking Testbench** (tự động PASS/FAIL)
- Kiểm tra timing HSYNC/VSYNC bằng **SVA (SystemVerilog Assertions)**
- Đo functional coverage cho các vùng timing và trạng thái reset

## DUT

| Mục | Giá trị |
|-----|---------|
| Module | `vga_controller` (Verilog-2001) |
| Pixel clock | 25MHz (T = 40ns) |
| Reset | Bất đồng bộ, Active-Low (`rst_n`) |
| Output | `hsync`, `vsync` (Active-Low, registered), `video_on`, `pixel_x[9:0]`, `pixel_y[9:0]` |

### Spec Timing (nguồn tham chiếu cho checker)

| Trục | Active | Front Porch | Sync Pulse (Active-Low) | Back Porch | Tổng |
|------|--------|-------------|-------------------------|------------|------|
| Ngang (pixel) | 640 | 16 | 96 | 48 | 800 |
| Dọc (line)    | 480 | 10 | 2  | 33 | 525 |

## Verification Plan

| ID | Tính năng | Điều cần kiểm tra | Phương pháp | Trạng thái |
|----|-----------|-------------------|-------------|------------|
| V-01 | Reset | Sau `rst_n=0`: `hsync=vsync=1`, bộ đếm = 0 | Directed + Assertion | ☐ |
| V-02 | Chu kỳ dòng | Mỗi dòng đúng 800 clock | Checker / SVA | ☐ |
| V-03 | Chu kỳ khung | Mỗi khung đúng 800×525 clock | Checker / SVA | ☐ |
| V-04 | HSYNC | Xung mức 0 rộng đúng 96 clock, bắt đầu ở pixel 656 | SVA | ☐ |
| V-05 | VSYNC | Xung mức 0 rộng đúng 2 dòng, bắt đầu ở line 490 | SVA | ☐ |
| V-06 | `video_on` | =1 khi và chỉ khi `pixel_x<640` và `pixel_y<480` | Scoreboard / Reference model | ☐ |
| V-07 | Toạ độ | `pixel_x` wrap 799→0, `pixel_y` wrap 524→0 đúng thời điểm | Reference model | ☐ |
| V-08 | Glitch-free | `hsync`/`vsync` chỉ đổi giá trị tại sườn lên clock | SVA | ☐ |
| V-09 | Reset giữa chừng | Reset ở thời điểm ngẫu nhiên → DUT về trạng thái ban đầu | Constrained-random | ☐ |

## Kiến trúc Testbench

```
 ┌──────────┐   ┌─────────┐   ┌───────────────┐
 │ Clk/Rst  │──▶│   DUT   │──▶│ Monitor/Checker│──▶ PASS/FAIL
 │ Driver   │   └─────────┘   │ + Ref Model    │
 └──────────┘        │        └───────────────┘
                     └──▶ SVA bind module  ──▶ Coverage
```

## Cấu trúc thư mục

```
.
├── rtl/
│   └── vga_controller.v          # DUT
├── tb/
│   ├── tb_vga_controller.v       # Directed testbench (hiện tại)
│   ├── vga_checker.sv            # Self-checking / reference model (kế hoạch)
│   └── vga_assertions.sv         # SVA bind module (kế hoạch)
├── sim/                          # Output mô phỏng, không commit
├── .gitignore
└── README.md
```

## Chạy mô phỏng

```bash
mkdir -p sim
iverilog -o sim/vga_sim.out rtl/vga_controller.v tb/tb_vga_controller.v
vvp sim/vga_sim.out
gtkwave sim/vga_sim.vcd
```

Mô phỏng 35ms (> 2 khung hình). Tương thích Icarus Verilog, ModelSim/QuestaSim, Vivado Simulator; SVA yêu cầu simulator hỗ trợ SystemVerilog (QuestaSim, VCS, Verilator).

## Tiến độ

- [x] DUT `vga_controller.v`
- [x] Directed testbench: clock 25MHz, reset bất đồng bộ 100ns, xuất VCD
- [ ] Self-checking testbench (tự động báo lỗi, kết thúc bằng PASS/FAIL)
- [ ] SVA cho V-01 → V-08
- [ ] Functional coverage (covergroup cho vùng timing, reset)
- [ ] Constrained-random reset injection
- [ ] Báo cáo coverage & kết quả regression
- [ ] Nâng cấp lên UVM (agent, monitor, scoreboard)

## Kỹ năng thể hiện

Verification planning · Self-checking testbench · SVA (`|->`, `|=>`) · Reference model · Functional coverage · Constrained-random · Waveform debug (GTKWave/ModelSim)

## License

MIT
