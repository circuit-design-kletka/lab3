module seg_display_ctrl (
    input  wire        clk,
    input  wire        rst,
    input  wire [31:0] value,     // 8 hex-цифр
    input  wire        blank_leading_zeros, // Гасить ведущие нули
    output reg  [7:0]  seg_data,  // {a,b,c,d,e,f,g,dp}, активный низкий
    output reg  [7:0]  seg_sel    // выбор разряда, активный НИЗКИЙ
);

    reg [15:0] scan_cnt;
    reg [2:0]  digit_idx; // номер текущего разряда 0..7

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            scan_cnt  <= 16'd0;
            digit_idx <= 3'd0;
        end else begin
            if (scan_cnt == 16'd49999) begin
                scan_cnt  <= 16'd0;
                digit_idx <= digit_idx + 3'd1;
            end else begin
                scan_cnt <= scan_cnt + 16'd1;
            end
        end
    end

    // Выбор соответствующей тетрады из value[31:0]
    wire [3:0] curr_nibble;
    assign curr_nibble = (digit_idx == 3'd0) ? value[3:0]   :
                         (digit_idx == 3'd1) ? value[7:4]   :
                         (digit_idx == 3'd2) ? value[11:8]  :
                         (digit_idx == 3'd3) ? value[15:12] :
                         (digit_idx == 3'd4) ? value[19:16] :
                         (digit_idx == 3'd5) ? value[23:20] :
                         (digit_idx == 3'd6) ? value[27:24] :
                                               value[31:28];

    // Генератор кодов сегментов
    wire [7:0] hex_seg;
    hex_to_7seg u_hex_to_7seg (
        .hex(curr_nibble),
        .seg(hex_seg)
    );

    // Определяем старший значащий разряд
    wire [2:0] msb_pos;
    assign msb_pos = (value[31:28] != 0) ? 3'd7 :
                     (value[27:24] != 0) ? 3'd6 :
                     (value[23:20] != 0) ? 3'd5 :
                     (value[19:16] != 0) ? 3'd4 :
                     (value[15:12] != 0) ? 3'd3 :
                     (value[11:8]  != 0) ? 3'd2 :
                     (value[7:4]   != 0) ? 3'd1 : 3'd0;

    // Комбинаторика для seg_data и seg_sel
    always @(*) begin
        if (blank_leading_zeros && (digit_idx > msb_pos) && (curr_nibble == 4'd0)) begin
            seg_data = 8'b11111111; // Все сегменты выключены
        end else begin
            seg_data = hex_seg;
        end

        // По умолчанию все разряды выключены (активный низкий)
        seg_sel = 8'b1111_1111;
        case (digit_idx)
            3'd0: seg_sel[0] = 1'b0; // младший разряд
            3'd1: seg_sel[1] = 1'b0;
            3'd2: seg_sel[2] = 1'b0;
            3'd3: seg_sel[3] = 1'b0;
            3'd4: seg_sel[4] = 1'b0;
            3'd5: seg_sel[5] = 1'b0;
            3'd6: seg_sel[6] = 1'b0;
            3'd7: seg_sel[7] = 1'b0; // старший разряд
            default: seg_sel = 8'b1111_1111;
        endcase
    end

endmodule
