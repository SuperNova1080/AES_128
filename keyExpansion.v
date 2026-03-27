`include "functions_header.vh"

module keyExpansion(
    input          reset,
    input          clk,
    input          start_key_exp,
    input  [ 3: 0] round,
    input  [127:0] key,
    output [127:0] round_key,
    output reg     done
);
    
    reg [31:0] key_mem  [0:43]; 
    reg [31:0] word     [0:3];   
    reg [32:0] temp_word;
    reg [ 3:0] count;
    reg [ 2:0] state, next_state;
    integer i;
    
    localparam IDLE   = 3'b000,
               G_FUNC = 3'b001,
               XOR0   = 3'b010,
               XOR1   = 3'b011,
               XOR2   = 3'b100,
               XOR3   = 3'b101,
               SAVE   = 3'b110;
              
    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            count <= 4'b0001;
            done  <= 1'b0;
            for (i = 0; i < 44; i = i + 1) 
                key_mem[i] <= 32'b0;
        end
        else begin
            state <= next_state;
            
            if (state == IDLE && start_key_exp && count < 10) begin
                word[3] <= key[31:0];
                word[2] <= key[63:32];
                word[1] <= key[95:64];
                word[0] <= key[127:96];

                key_mem[3] <= key[31:0];
                key_mem[2] <= key[63:32];
                key_mem[1] <= key[95:64];
                key_mem[0] <= key[127:96];
                end
                
            if (state == G_FUNC) 
                temp_word <= gfunc(word[3], count);
          
            if (state == XOR0) 
                word[0] <= word[0]^temp_word[31:0];
            
            if (state == XOR1)
                word[1] <= word[1]^word[0];
            
            if (state == XOR2)
                word[2] <= word[2]^word[1];
            
            if (state == XOR3)
                word[3] <= word[3]^word[2];
                
            if (state == SAVE) begin
                key_mem[4*count]     <= word[0];
                key_mem[4*count + 1] <= word[1];
                key_mem[4*count + 2] <= word[2];
                key_mem[4*count + 3] <= word[3];
                count <= count + 1;
                
                if (count == 10)
                    done <= 1'b1;
                end
        end
    end
    
    always @(*) begin
        next_state = IDLE;

        case(state)
        IDLE: begin
                if (start_key_exp && count < 10)
                    next_state = G_FUNC;
                else
                    next_state = IDLE;
              end
       
      G_FUNC: begin
                if (temp_word[32] == 1'b1)
                    next_state = XOR0;
                else
                    next_state = G_FUNC;
              end
       
        XOR0: begin
                next_state = XOR1;
              end 
        
        XOR1: begin
                next_state = XOR2;
              end 
              
        XOR2: begin
                next_state = XOR3;
              end 
        
        XOR3: begin
                next_state = SAVE;
              end 
        
        SAVE: begin
                if (count < 10)
                    next_state = G_FUNC;
                else
                    next_state = IDLE;
              end            
        endcase
    end
    
    assign round_key = done ? {key_mem[4*round], key_mem[4*round+1], key_mem[4*round+2], key_mem[4*round+3]} : 128'bx;
    
endmodule
