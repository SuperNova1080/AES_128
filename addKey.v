module addKey(
    input  [127:0] key,
    input  [127:0] state,
    output [127:0] add_key_state
);
    
    assign add_key_state = {
        {key[127:96]^state[127:96]},
        {key[ 95:64]^state[ 95:64]},
        {key[ 63:32]^state[ 63:32]},
        {key[ 31: 0]^state[ 31: 0]}
    };
    
endmodule
