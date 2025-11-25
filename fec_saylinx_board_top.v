module fec_saylinx_board_top
(
    input           CLK,
    input           RST_N,

    input           KEY2_N,
    input           KEY3_N,
    input           KEY4_N,

    output [3:0]    LED,

    output [7:0] SEG_DATA,
    output [7:0] SEG_SEL,

    output [16:0] GPIO_0_out_zero_value,
    input  [16:0] GPIO_0_input_pullup,
	 
	output [16:0] GPIO_1_out_zero_value,
    input  [16:0] GPIO_1_input_pullup
);

    // Порт / синхронизированные сигналы
    wire clk   = CLK;
    wire rst   = ~RST_N; 
    
    // Кнопки
    wire [2:0] keys_raw = ~{ KEY2_N, KEY3_N, KEY4_N };

    // Дебустинг кнопок
    localparam integer DEBOUNCE_CLKS = 1_000_000;

    wire key2_posedge, key3_posedge, key4_posedge;

    debounce_button db2 (
        .clk      (clk),
        .rst      (rst),
        .in       (keys_raw[2]),
        .pos_edge (key2_posedge)
    );

    debounce_button db3 (
        .clk      (clk),
        .rst      (rst),
        .in       (keys_raw[1]),
        .pos_edge (key3_posedge)
    );

    debounce_button db4 (
        .clk      (clk),
        .rst      (rst),
        .in       (keys_raw[0]),
        .pos_edge (key4_posedge)
    );

    // Данные с GPIO (инверсия входов)
    wire [7:0] gpio_a = ~GPIO_0_input_pullup[7:0];    // a: младшие 8 бит
    wire [7:0] gpio_b = ~GPIO_0_input_pullup[15:8];   // b: след. 8 бит

    // Расширение b до 32 бит для модуля вычислений
    wire [31:0] b32 = {24'd0, gpio_b};
    wire [7:0]  a8  = gpio_a;

    
    // Старт вычисления
    reg start_calc_q;
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            start_calc_q <= 1'b0;
        end else begin
            // стартовая кнопка — key3 (как у вас)
            start_calc_q <= key3_posedge ? 1'b1 : 1'b0;
        end
    end

    
    // Вызов вычислительного блока
    wire [15:0] calc_result;
    wire        calc_done;

    sqrt_mult_system calc_unit (
        .clk_i   (clk),
        .rst_i   (rst),
        .start_i (start_calc_q),
        .a_bi    ({24'd0, a8}), // расширим a до 32, как ожидал модуль
        .b_bi    (b32),
        .result  (calc_result),
        .done    (calc_done)
    );

    // Режимы отображения и хранение последнего результата
    localparam [1:0]
        DISP_RESULT = 2'd0,
        DISP_A      = 2'd1,
        DISP_B      = 2'd2;


    reg [1:0]  disp_mode_q;
    reg [31:0] last_result_q;
    reg [7:0]  calc_done_count;

    wire blank_leading = (disp_mode_q == DISP_A) || (disp_mode_q == DISP_B);

    reg [31:0] disp_value_q;

    seg_display_ctrl seg_ctrl (
        .clk                 (clk),
        .rst                 (rst),
        .value               (disp_value_q),
        .blank_leading_zeros (blank_leading),
        .seg_data            (SEG_DATA),
        .seg_sel             (SEG_SEL)
    );

    


    always @(posedge clk or posedge rst) begin
        if (rst) begin
            disp_mode_q       <= DISP_RESULT;
            disp_value_q      <= 32'd0;
            last_result_q     <= 32'd0;
            calc_done_count   <= 8'd0;
        end else begin
            // Обновление последнего результата по сигналу done
            if (calc_done) begin
                last_result_q   <= {16'd0, calc_result}; 
                disp_mode_q     <= DISP_RESULT;
                calc_done_count <= calc_done_count + 1'b1;
            end

            // Переключения режимов
            if (key2_posedge) begin
                disp_mode_q <= DISP_A;
            end else if (key4_posedge) begin
                disp_mode_q <= DISP_B;
            end else if (key3_posedge) begin
                disp_mode_q <= DISP_RESULT;
            end

            // Выбор значения для отображения
            case (disp_mode_q)
                DISP_A:     disp_value_q <= {24'd0, a8};                   // показываем a
                DISP_B:     disp_value_q <= {24'd0, gpio_b};               // показываем b
                DISP_RESULT: begin
                    // сформируем отладочный 32-бит: [7:0]=a, [15:8]=b, [31:16]=результат
                    disp_value_q <= {calc_result, gpio_b, a8};
                end
                default:    disp_value_q <= last_result_q;
            endcase
        end
    end

    // LED-индикация
    assign LED[0] = (disp_mode_q == DISP_A);
    assign LED[1] = (disp_mode_q == DISP_B);
    assign LED[2] = (disp_mode_q == DISP_RESULT);
    assign LED[3] = |calc_done_count; // хоть раз завершилось

    // Выходы GPIO оставляем нулями (как в оригинале)
    assign GPIO_0_out_zero_value = {17{1'b0}};
    assign GPIO_1_out_zero_value = {17{1'b0}};

endmodule


