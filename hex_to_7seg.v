module hex_to_7seg (
    input  wire [3:0] hex,
    output reg  [7:0] seg
);  
    always @(*) begin
        case (hex)
            4'h0: seg = 8'b0000001_1; // 0
            4'h1: seg = 8'b1001111_1; // 1
            4'h2: seg = 8'b0010010_1; // 2
            4'h3: seg = 8'b0000110_1; // 3
            4'h4: seg = 8'b1001100_1; // 4
            4'h5: seg = 8'b0100100_1; // 5
            4'h6: seg = 8'b0100000_1; // 6
            4'h7: seg = 8'b0001111_1; // 7
            4'h8: seg = 8'b0000000_1; // 8
            4'h9: seg = 8'b0000100_1; // 9
            4'hA: seg = 8'b0001000_1; // A
            4'hB: seg = 8'b1100000_1; // b
            4'hC: seg = 8'b0110001_1; // C
            4'hD: seg = 8'b1000010_1; // d
            4'hE: seg = 8'b0110000_1; // E
            4'hF: seg = 8'b0111000_1; // F
            default: seg = 8'b1111111_1; // Пусто
        endcase
    end
endmodule
