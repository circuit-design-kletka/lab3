# ============================================================
# ModelSim DO file - Simulation of moore_tb1
# Project: y = a * cuberoot(b)
# ============================================================

# Создание рабочей библиотеки
vlib work
vmap work work

# ------------------------------------------------------------
# Компиляция модулей (относительные пути от C:\lab3)
# ------------------------------------------------------------
vlog "/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/sqrt.v"
vlog "/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/mult.v"
vlog "/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/sqrt_mult_system.v"
vlog "/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/moore_tb1.v"

# ------------------------------------------------------------
# Запуск симуляции тестбенча
# ------------------------------------------------------------
vsim -voptargs="+acc" work.moore_tb1

# ------------------------------------------------------------
# Добавление сигналов в Wave
# ------------------------------------------------------------

# Верхний уровень тестбенча
add wave -divider {TESTBENCH}
add wave /moore_tb1/clk
add wave /moore_tb1/rst
add wave /moore_tb1/start
add wave -radix unsigned /moore_tb1/a
add wave -radix unsigned /moore_tb1/b
add wave -radix unsigned /moore_tb1/result
add wave /moore_tb1/done

# Основной модуль SQRT_MULT_SYSTEM (FSM)
add wave -divider {SQRT_MULT_SYSTEM FSM}
add wave /moore_tb1/dut/state
add wave /moore_tb1/dut/next_state
add wave /moore_tb1/dut/sqrt_en
add wave /moore_tb1/dut/mult_en
add wave /moore_tb1/dut/sqrt_busy
add wave /moore_tb1/dut/sqrt_done
add wave /moore_tb1/dut/mult_busy
add wave /moore_tb1/dut/mult_done
add wave -radix unsigned /moore_tb1/dut/cubert_result

# Модуль root3 (вычисление кубического корня)
add wave -divider {SQRT}
add wave /moore_tb1/dut/sqrt_inst/state
add wave /moore_tb1/dut/sqrt_inst/phase
add wave /moore_tb1/dut/sqrt_inst/busy_o
add wave /moore_tb1/dut/sqrt_inst/done_o
add wave -radix unsigned /moore_tb1/dut/sqrt_inst/x
add wave -radix unsigned /moore_tb1/dut/sqrt_inst/y
add wave -radix unsigned /moore_tb1/dut/sqrt_inst/s

# Модуль mult (умножение)
add wave -divider {MULT}
add wave /moore_tb1/dut/mult_inst/state
add wave /moore_tb1/dut/mult_inst/busy_o
add wave /moore_tb1/dut/mult_inst/done_o
add wave -radix unsigned /moore_tb1/dut/mult_inst/a_reg
add wave -radix unsigned /moore_tb1/dut/mult_inst/b_reg
add wave -radix unsigned /moore_tb1/dut/mult_inst/y_bo

# ------------------------------------------------------------
# Запуск симуляции
# ------------------------------------------------------------
# Симуляция 10 тестов, каждый тест может занять до 200 us
# Общее время ~2 ms для запаса (вычисления медленные)
run 2 ms

# Масштабирование Wave
wave zoom full

# Настройка временной шкалы
configure wave -timelineunits us

# ------------------------------------------------------------
# Информация
# ------------------------------------------------------------
echo "============================================================"
echo "Симуляция moore_tb1 завершена!"
echo "Проверьте Transcript для результатов тестов"
echo "Проверьте Wave для временных диаграмм"
echo "Всего тестов: 10"
echo "============================================================"
