module register(ra1, ra2, wa, rd1, rd2, wd, we, clk, n_rst);
    input  [ 2:0] ra1, ra2, wa; // アドレス (番号)
    output [31:0] rd1, rd2;     // 読み出しデータ
    input  [31:0] wd;           // 書き込みデータ
    input         we;           // ライト・イネーブル
    input         clk, n_rst;
    integer       i;
    reg [31:0] rf [0:7]; // 32-bit x 8-word レジスタ・ファイル本体

    always @(posedge clk  or negedge n_rst) begin
        if (n_rst == 0)
          for (i = 0; i < 8; i = i + 1)
            rf[i] <= 0;
        else if (we == 1)
          rf[wa] <= wd;         // 書き込み
    end

    assign  rd1 = rf[ra1];      // 読み出し
    assign  rd2 = rf[ra2];      // 読み出し

endmodule // register
