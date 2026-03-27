`include "functions_header.vh"
module mixColumns(
    input  [127:0]state,
    output [127:0]mix_col_state
);
    
    assign mix_col_state = {
        {mul2(state[127:120])^mul3(state[119:112])^state[111:104]^state[103:96]},//S0
        {state[127:120]^mul2(state[119:112])^mul3(state[111:104])^state[103:96]},//S1
        {state[127:120]^state[119:112]^mul2(state[111:104])^mul3(state[103:96])},//S2
        {mul3(state[127:120])^state[119:112]^state[111:104]^mul2(state[103:96])},//S3
        
        {mul2(state[95:88])^mul3(state[87:80])^state[79:72]^state[71:64]},//S4
        {state[95:88]^mul2(state[87:80])^mul3(state[79:72])^state[71:64]},//S5
        {state[95:88]^state[87:80]^mul2(state[79:72])^mul3(state[71:64])},//S6
        {mul3(state[95:88])^state[87:80]^state[79:72]^mul2(state[71:64])},//S7
        
        {mul2(state[63:56])^mul3(state[55:48])^state[47:40]^state[39:32]},//S8
        {state[63:56]^mul2(state[55:48])^mul3(state[47:40])^state[39:32]},//S9
        {state[63:56]^state[55:48]^mul2(state[47:40])^mul3(state[39:32])},//S10
        {mul3(state[63:56])^state[55:48]^state[47:40]^mul2(state[39:32])},//S11
        
        {mul2(state[31:24])^mul3(state[23:16])^state[15:8]^state[7:0]}, //S12
        {state[31:24]^mul2(state[23:16])^mul3(state[15:8])^state[7:0]},//S13
        {state[31:24]^state[23:16]^mul2(state[15:8])^mul3(state[7:0])},//S14
        {mul3(state[31:24])^state[23:16]^state[15:8]^mul2(state[7:0])}//S15   
    };
    
endmodule


