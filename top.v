module top(
    input             reset,
    input             clk,
    input             start,
    input      [127:0]key,
    input      [127:0]plaintext,
    output reg [127:0]cipher
);
    
    reg [2:0]state, next_state;
    reg [3:0]round;
    
    reg  start_key_exp;
    wire key_exp_done; 
    wire [127:0]round_key;//for key expansion
    
    reg  [127:0]init_out;
    
    reg  [127:0]sub_bytes_input_reg;
    wire [127:0]sub_bytes_state;//subbytes
    reg  [127:0]sub_bytes_state_reg;
    
    wire [127:0]shift_state;//shiftrows
    reg  [127:0]shift_state_reg;
    
    wire [127:0]mix_col_state;//mixcol
    reg  [127:0]mix_col_state_reg;

    wire [127:0]add_key_state;//addkey
    
    localparam IDLE       = 3'b000,
               KEY_EXP    = 3'b001,
               INIT_STATE = 3'b010,
               SUB_BYTES  = 3'b011,
               SHIFT_ROW  = 3'b100,
               MIX_COL    = 3'b101,
               ADD_RKEY   = 3'b110;
               
    
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            round <= 3'b000;
        end
        else begin
            state <= next_state;
            
            if (round == 3'b000)
                sub_bytes_input_reg <= init_out;
            else
                sub_bytes_input_reg <= add_key_state;
                
            if (state == SUB_BYTES && next_state == SHIFT_ROW)
                sub_bytes_state_reg <= sub_bytes_state;
            
            if (state == SHIFT_ROW && next_state == MIX_COL)
                shift_state_reg <= shift_state;
            else if (state == SHIFT_ROW && next_state == ADD_RKEY && round == 10)
                mix_col_state_reg <= shift_state;
                
            if (state == MIX_COL && next_state == ADD_RKEY)
                mix_col_state_reg <= mix_col_state;
            
            if (state == KEY_EXP && next_state == INIT_STATE)
                init_out <= plaintext ^ round_key;
            
            if (state == INIT_STATE && next_state == SUB_BYTES)
                round <= 3'b001;
            
            if (state == ADD_RKEY)
                round <= round + 1'b1;
                
            if (state == ADD_RKEY && round == 10)
                cipher <= add_key_state;
        end
    end
    
    always @(*) begin
        start_key_exp = 1'b0;
        next_state    = IDLE;
        case (state)
        IDLE: begin
                if (start)
                    next_state = KEY_EXP;
                else
                    next_state = IDLE;
              end
        
     KEY_EXP: begin
                start_key_exp = 1'b1;
                if (key_exp_done && !round)
                    next_state = INIT_STATE;
                else if (key_exp_done)
                    next_state = SUB_BYTES;
                else
                    next_state = KEY_EXP;
              end   
             
  INIT_STATE: begin
                next_state = SUB_BYTES;
              end     
              
   SUB_BYTES: begin //TODO: Make a valid-ish signal since mem access takes long time
                next_state = SHIFT_ROW;
              end  
   
   SHIFT_ROW: begin
                next_state = (round == 10)? ADD_RKEY : MIX_COL;
              end
   
     MIX_COL: begin
                next_state = ADD_RKEY;
              end
              
    ADD_RKEY: begin
                next_state = (round == 10)? IDLE : SUB_BYTES;
              end
        endcase
    end
    
    
    keyExpansion module1(
        .reset(reset),
        .clk(clk),
        .start_key_exp(start_key_exp),
        .round(round),
        .key(key),
        .round_key(round_key),
        .done(key_exp_done)
    );
    
    subBytes module2(
        .state(sub_bytes_input_reg),
        .sub_bytes_state(sub_bytes_state)
    );
    
    shiftRows module3(
        .state(sub_bytes_state_reg),////////
        .shift_state(shift_state)
    );
    
    mixColumns module4(
        .state(shift_state_reg),////////
        .mix_col_state(mix_col_state)
    );
    
    addKey module5(
        .key(round_key),
        .state(mix_col_state_reg),////////
        .add_key_state(add_key_state)
    );
    
endmodule
