module vga_controller (
    input  wire       clk_25mhz,  
    input  wire       rst_n,      
    output reg        hsync,      
    output reg        vsync,    
    output wire       video_on,  
    output wire [9:0] pixel_x,    
    output wire [9:0] pixel_y    
);

    localparam HD = 640;
    localparam HF = 16; 
    localparam HR = 96;  
    localparam HB = 48;  
    localparam HT = HD + HF + HR + HB; 

    localparam VD = 480; 
    localparam VF = 10;  
    localparam VR = 2;   
    localparam VB = 33;  
    localparam VT = VD + VF + VR + VB; 

  
    reg [9:0] h_count_reg, h_count_next; 
    reg [9:0] v_count_reg, v_count_next;


    always @(posedge clk_25mhz or negedge rst_n) begin
        if (!rst_n) begin
            h_count_reg <= 10'd0;
            v_count_reg <= 10'd0;
        end else begin
            h_count_reg <= h_count_next;
            v_count_reg <= v_count_next;
        end
    end

    
        if (h_count_reg == HT - 1) begin
            h_count_next = 10'd0;
            if (v_count_reg == VT - 1)
                v_count_next = 10'd0;
            else
                v_count_next = v_count_reg + 1'b1;
        end else begin
            h_count_next = h_count_reg + 1'b1;
            v_count_next = v_count_reg;
        end
    end


    always @(posedge clk_25mhz or negedge rst_n) begin
        if (!rst_n) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            hsync <= ~((h_count_reg >= (HD + HF)) && (h_count_reg < (HD + HF + HR)));

            vsync <= ~((v_count_reg >= (VD + VF)) && (v_count_reg < (VD + VF + VR)));
        end
    end


    assign video_on = (h_count_reg < HD) && (v_count_reg < VD);
    assign pixel_x = h_count_reg;
    assign pixel_y = v_count_reg;

endmodule
