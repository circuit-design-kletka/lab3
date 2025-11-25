`timescale 1ns/1ps

module fec_saylinx_board_top_tb;

    // Тактовый сигнал и сброс
    reg         CLK;
    reg         RST_N;

    // Кнопки (активный ноль на плате)
    reg         KEY2_N;
    reg         KEY3_N;
    reg         KEY4_N;

    // GPIO
    reg  [16:0] GPIO_0_input_pullup;
    wire [16:0] GPIO_0_out_zero_value;
    reg  [16:0] GPIO_1_input_pullup;
    wire [16:0] GPIO_1_out_zero_value;

    // Выходы
    wire [3:0]  LED;
    wire [7:0]  SEG_DATA;
    wire [7:0]  SEG_SEL;

    // Инстанс тестируемого top-модуля
    
    fec_saylinx_board_top dut (
        .CLK                 (CLK),
        .RST_N               (RST_N),
        .KEY2_N              (KEY2_N),
        .KEY3_N              (KEY3_N),
        .KEY4_N              (KEY4_N),
        .LED                 (LED),
        .SEG_DATA            (SEG_DATA),
        .SEG_SEL             (SEG_SEL),
        .GPIO_0_out_zero_value (GPIO_0_out_zero_value),
        .GPIO_0_input_pullup   (GPIO_0_input_pullup),
        .GPIO_1_out_zero_value (GPIO_1_out_zero_value),
        .GPIO_1_input_pullup   (GPIO_1_input_pullup)
    );

    
    // Генератор тактового сигнала 50 МГц (период 20 нс)

    initial begin
        CLK = 1'b0;
        forever #10 CLK = ~CLK;  // 20 ns период
    end

    // Таски для "нажатия" кнопок (с учётом дебаунса 1_000_000 тактов)
    
    // Имитация нажатия KEY2_N (показ 'a')
    task press_key2;
    begin
        $display("[%0t ns] KEY2 pressed (show A)", $time);
        KEY2_N = 1'b0;                    // нажали (активный 0)
        repeat (1100000) @(posedge CLK);  // держим дольше, чем 1_000_000 тактов (~22 ms)
        KEY2_N = 1'b1;                    // отпустили
        repeat (100000) @(posedge CLK);   // пауза после (~2 ms)
    end
    endtask

    // Имитация нажатия KEY3_N (старт вычисления)
    task press_key3;
    begin
        $display("[%0t ns] KEY3 pressed (start calculation)", $time);
        KEY3_N = 1'b0;
        repeat (1100000) @(posedge CLK);
        KEY3_N = 1'b1;
        repeat (100000) @(posedge CLK);
    end
    endtask

    // Имитация нажатия KEY4_N (показ 'b')
    task press_key4;
    begin
        $display("[%0t ns] KEY4 pressed (show B)", $time);
        KEY4_N = 1'b0;
        repeat (1100000) @(posedge CLK);
        KEY4_N = 1'b1;
        repeat (100000) @(posedge CLK);
    end
    endtask


    
    // Такска запуска тестового сценария
    //  a, b — входные значения для вычисления y = a * cuberoot(b)
    task run_case(input [7:0] a, input [7:0] b, input [15:0] expected);
    begin
        $display("\n========================================");
        $display("TEST: %0d * cuberoot(%0d) = %0d (expected)", a, b, expected);
        $display("========================================");
        
        // Установка значений a и b:
        GPIO_0_input_pullup[7:0]   = ~a;
        GPIO_0_input_pullup[15:8]  = ~b;
        GPIO_0_input_pullup[16]    = 1'b1; 
        
        // Небольшая пауза после установки GPIO
        repeat (1000) @(posedge CLK);
        
        // Показать 'a'
        press_key2;
        $display("[CHECK] After KEY2: a_value = %0d, display_mode = %0d", 
                 dut.a8, dut.disp_mode_q);
        
        // Показать 'b'
        press_key4;
        $display("[CHECK] After KEY4: b_value = %0d, display_mode = %0d", 
                 dut.b32, dut.disp_mode_q);
        
        // Запустить вычисление
        press_key3;
        
        // Подождать, пока появится результат (calc_done_counter увеличится)
        $display("[WAIT] Waiting for calculation to complete...");
        
        // Ждем до 10 000 000 тактов (200 ms)
        repeat (10000000) @(posedge CLK);
        
        // Проверяем результат
        $display("[RESULT] calc_result = %0d (0x%04h)", dut.calc_result, dut.calc_result);
        $display("[RESULT] last_result = %0d (0x%04h)", dut.last_result_q[15:0], dut.last_result_q[15:0]);
        $display("[RESULT] display_value = 0x%08h", dut.disp_value_q);
        
        if (dut.last_result_q[15:0] == expected) begin
            $display("[PASS] Test PASSED: Result = %0d", dut.last_result_q[15:0]);
        end else begin
            $display("[FAIL] Test FAILED: Expected %0d, got %0d", 
                     expected, dut.last_result_q[15:0]);
        end
        
        // Небольшой промежуток между сценариями
        repeat (500000) @(posedge CLK);
    end
    endtask

    // Основная последовательность теста
    initial begin
        $display("\n====================================================");
        $display("  TESTBENCH FOR fec_saylinx_board_top");
        $display("  Testing: y = a * cuberoot(b)");
        $display("  Clock: 50 MHz (period 20 ns)");
        $display("====================================================\n");
        
        RST_N               = 1'b0;  
        KEY2_N              = 1'b1;
        KEY3_N              = 1'b1;
        KEY4_N              = 1'b1;
        GPIO_0_input_pullup = 17'h1FFFF; // все "отпущены" (1)
        GPIO_1_input_pullup = 17'h1FFFF;

        // Немного подержать сброс
        repeat (10) @(posedge CLK);
        RST_N = 1'b1;  // снимаем сброс
        $display("[%0t ns] Reset released", $time);

        // Подождать, пока всё инициализируется
        repeat (1000) @(posedge CLK);

        // ========= ТЕСТ 1 =========
        run_case(8'd5, 8'd9, 16'd15);

        // ========= ТЕСТ 2 =========
        run_case(8'd10, 8'd4, 16'd20);

        // ========= ТЕСТ 3 =========
        run_case(8'd7, 8'd16, 16'd28);


        repeat (500000) @(posedge CLK);
        
        $display("\n====================================================");
        $display("  SIMULATION COMPLETED");
        $display("====================================================\n");
        
        $stop;
    end

    // Опционально: текстовый монитор для отладки

    initial begin
        $display("Time(us)\tLED\tstate\ta_val\tb_val\tresult");
        $display("========\t===\t=====\t=====\t=====\t======");
    end
    
    // Периодический вывод состояния каждые 10 ms
    always @(posedge CLK) begin
        if ($time % 10000000 == 0) begin  // Каждые 10 ms
            $display("%0.3f\t%b\t%0d\t%0d\t%0d\t%0d",
                     $time/1000.0, LED, dut.calc_unit.state, 
                     dut.a8, dut.b32, dut.calc_result);
        end
    end

endmodule
