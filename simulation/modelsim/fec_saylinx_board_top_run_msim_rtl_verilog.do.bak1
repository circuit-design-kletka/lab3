transcript on
if {[file exists rtl_work]} {
	vdel -lib rtl_work -all
}
vlib rtl_work
vmap work rtl_work

vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/fec_saylinx_board_top.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/debounce_button.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/sqrt_mult_system.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/sqrt.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/mult.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/seg_display_ctrl.v}
vlog -vlog01compat -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/hex_to_7seg.v}

vlog -sv -work work +incdir+/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3 {/media/ra/_work/ra/ITMO/COURSE_3/FUCSCHEM/lab3/fec_saylinx_board_top_tb.v}

vsim -t 1ps -L altera_ver -L lpm_ver -L sgate_ver -L altera_mf_ver -L altera_lnsim_ver -L cycloneive_ver -L rtl_work -L work -voptargs="+acc"  fec_saylinx_board_top_tb

add wave *
view structure
view signals
run -all
