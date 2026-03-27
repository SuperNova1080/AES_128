`include "functions_header.vh"

module subBytes(
    input  [127:0] state,
    output [127:0] sub_bytes_state
);

    assign sub_bytes_state = {
        sbox_lookup(state[127:120]),
        sbox_lookup(state[119:112]),
        sbox_lookup(state[111:104]),
        sbox_lookup(state[103: 96]),
        sbox_lookup(state[ 95: 88]),
        sbox_lookup(state[ 87: 80]),
        sbox_lookup(state[ 79: 72]),
        sbox_lookup(state[ 71: 64]),
        sbox_lookup(state[ 63: 56]),
        sbox_lookup(state[ 55: 48]),
        sbox_lookup(state[ 47: 40]),
        sbox_lookup(state[ 39: 32]),
        sbox_lookup(state[ 31: 24]),
        sbox_lookup(state[ 23: 16]),
        sbox_lookup(state[ 15:  8]),
        sbox_lookup(state[  7:  0])
    };

endmodule
