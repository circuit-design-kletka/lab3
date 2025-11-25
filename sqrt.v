module sqrt (
    input clk_i,
    input rst_i,

    input [7:0] x_bi,
    input start_i,

    output busy_o,
    output reg [7:0] y_bo
);

    localparam IDLE = 1'b0;
    localparam WORK = 1'b1;

    reg state;
    reg [7:0] x;        // Текущее значение
    reg [7:0] y;        // результат  
    reg [7:0] m;        // Маска
    reg [7:0] b;        // временная переменная

    assign busy_o = state;

    always @(posedge clk_i) begin
        if (rst_i) begin
            state <= IDLE;
            
            x <= 0;
            y <= 0;
            m <= 0;
            y_bo <= 0;

        end else begin
            case (state)
                IDLE: 
                    begin
                        if (start_i) begin
                            state <= WORK;
                            x <= x_bi;          
                            y <= 0;             
                            m <= 8'b01000000;   // m = 1 << (N - 2); N = 8
                            y_bo <= 0;
                        end
                    end
                
                WORK: 
                    begin
                        if (m != 0) begin
                            b = y | m;
                            y = y >> 1;
                            if (x >= b) begin
                                x = x - b;   
                                y = y | m;   
                            end
                            m = m >> 2;
                        end else begin
                            state <= IDLE;
                            y_bo = {8'b0, y};
                        end
                    end
            endcase
        end
    end

endmodule