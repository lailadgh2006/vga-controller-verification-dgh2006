`timescale 1ns/1ps

module tb_vga_controller;
    reg clk_25mhz;
    reg rst_n;
    wire hsync;
    wire vsync;
    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;


    vga_controller uut (
        .clk_25mhz(clk_25mhz),
        .rst_n(rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .video_on(video_on),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y)
    );

    // Tạo xung Clock 25MHz (Chu kỳ T = 40ns -> Đảo trạng thái mỗi 20ns)
    always #20 clk_25mhz = ~clk_25mhz;

    initial begin
        // Ghi dữ liệu dạng sóng ra file .vcd
        $dumpfile("sim/vga_sim.vcd");
        $dumpvars(0, tb_vga_controller);

        clk_25mhz = 0;
        rst_n = 0; // Reset ban đầu
        #100;
        rst_n = 1; // Thả Reset

        // Mô phỏng chạy trong 35ms (đủ để quét gần 2 khung hình VGA)
        #35000000;
        
        $display("Simulation finished successfully!");
        $finish;
    end
endmodule
