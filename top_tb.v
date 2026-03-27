`timescale 1ns/1ps
module keyExpansion_tb();
    reg         clk, reset, start;
    reg  [127:0] key;
    reg  [127:0] plaintext;
    wire [127:0] cipher;
    integer i;
    
    top uut(
        .clk           (clk),
        .reset         (reset),
        .start         (start),
        .key           (key),
        .plaintext     (plaintext),
        .cipher        (cipher)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, uut);

        clk = 0; reset = 1; start = 0;
        plaintext = 128'h3243f6a8885a308d313198a2e0370734;
        key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
        #15 reset = 0;
        #10 start = 1;
        #10 start = 0;
        
        #1000000 $display("%0h", uut.cipher);
        #1 $finish;
    end
endmodule
