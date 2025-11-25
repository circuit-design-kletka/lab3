module debounce_button #( parameter integer CLKS = 1_000_000 ) (
    input  wire clk,
    input  wire rst,
    input  wire in,
    output reg  pos_edge
);
    localparam integer CNTW = $clog2(CLKS+1);
    reg [CNTW-1:0] cnt;
    reg stable;
    reg stable_prev;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt         <= {CNTW{1'b0}};
            stable      <= 1'b0;
            stable_prev <= 1'b0;
            pos_edge    <= 1'b0;
        end else begin
            if (in != stable) begin
                if (cnt == CLKS-1) begin
                    stable <= in;
                    cnt <= {CNTW{1'b0}};
                end else begin
                    cnt <= cnt + 1'b1;
                end
            end else begin
                cnt <= {CNTW{1'b0}};
            end

            stable_prev <= stable;
            pos_edge <= (stable & ~stable_prev); 
        end
    end
endmodule
