module phase_gen(input            hlt,
                 output reg [4:0] phase,
                 input            clk,
                 input            n_rst);

    reg    [2:0]         n_rst_d;

    always @(posedge clk) begin // 同期化
        n_rst_d <= {n_rst_d[1:0], n_rst};
    end

    always @(posedge clk or negedge n_rst) begin
        if (n_rst == 0)         // 非同期リセット
          phase <= 0;
        else if (hlt == 1)      // zHLT 命令による同期リセット
          phase <= 0;
        else if (n_rst_d[2:1] == 2'b01) // カウント開始
          phase <= 1;
        else
          phase <= {phase[3:0], phase[4]};
    end

endmodule
