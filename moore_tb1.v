`timescale 1ns/1ps

module moore_tb1;

    reg         clk   = 1'b0;
    reg         rst   = 1'b1;
    reg         start = 1'b0;
    reg  [7:0]  a     = 8'd0;
    reg  [31:0] b     = 32'd0;
    wire [15:0] result;
    wire        done;

    sqrt_mult_system dut (
        .clk_i  (clk),
        .rst_i  (rst),
        .start_i(start),
        .a_bi   (a),
        .b_bi   (b),
        .result (result),
        .done   (done)
    );

    always #5 clk = ~clk;

    localparam integer MAX_WAIT_CYCLES = 2000;

    task automatic pulse_start;
        begin
            @(posedge clk); start <= 1'b1;
            @(posedge clk); start <= 1'b0;
        end
    endtask

    task automatic run_case(
        input [7:0]  ta,
        input [31:0] tb,
        input [15:0] expected,
        input integer num
    );
        integer w;
        begin
            a <= ta; b <= tb;
            pulse_start();

            w = 0;
            while (!done && w < MAX_WAIT_CYCLES) begin
                @(posedge clk); w = w + 1;
            end

            if (!done) begin
                $display("%2d: TIMEOUT  a=%0d, b=%0d", num, ta, tb);
            end else begin
                @(posedge clk);
                if (result === expected)
                    $display("%2d: %0d*sqrt(%0d) = %0d  [OK]",   num, ta, tb, result);
                else
                    $display("%2d: %0d*sqrt(%0d) = %0d  exp %0d  [FAIL]",
                             num, ta, tb, result, expected);
            end

            repeat (2) @(posedge clk);
        end
    endtask

    initial begin
        $display("==== Start simulation ====");

        repeat (3) @(posedge clk);
        rst <= 1'b0;
        @(posedge clk);

        run_case(8'd5 , 32'd27     , 16'd15 , 1);   // 5 * 3   = 15
        run_case(8'd10, 32'd8      , 16'd20 , 2);   // 10 * 2  = 20
        run_case(8'd7 , 32'd64     , 16'd28 , 3);   // 7 * 4   = 28
        run_case(8'd3 , 32'd125    , 16'd15 , 4);   // 3 * 5   = 15
        run_case(8'd12, 32'd1      , 16'd12 , 5);   // 12 * 1  = 12
        run_case(8'd2 , 32'd1000   , 16'd20 , 6);   // 2 * 10  = 20 
        run_case(8'd9 , 32'd216    , 16'd54 , 7);   // 9 * 6   = 54
        run_case(8'd4 , 32'd343    , 16'd28 , 8);   // 4 * 7   = 28
        run_case(8'd15, 32'd729    , 16'd135, 9);   // 15 * 9  = 135
        run_case(8'd6 , 32'd1000000, 16'd600, 10);  // 6 * 100 = 600

        repeat (5) @(posedge clk);
        $display("==== Simulation finished ====");
        $finish;
    end

endmodule