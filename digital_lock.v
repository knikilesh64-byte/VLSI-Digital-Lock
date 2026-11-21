
module digital_lock (
    input clk,
    input reset,
    input [3:0] password,
    input enter,
    output reg unlock,
    output reg locked,
    output reg [1:0] failed_attempts
);

    parameter IDLE = 3'b000,
              CHECK = 3'b001,
              OPEN = 3'b010,
              WRONG = 3'b011,
              LOCKOUT = 3'b100;

    reg [2:0] state, next_state;
    reg [3:0] password_reg;

    always @(posedge clk) begin
        if (reset) begin
            state <= IDLE;
            password_reg <= 4'b0000;
            failed_attempts <= 0;
        end
        else begin
            state <= next_state;

            if (state == IDLE && enter)
                password_reg <= password;

            if (state == CHECK && password_reg == 4'b1010)
                failed_attempts <= 0;
            else if (state == WRONG)
                failed_attempts <= failed_attempts + 1'b1;
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE:
                if (enter)
                    next_state = CHECK;

            CHECK:
                if (password_reg == 4'b1010)
                    next_state = OPEN;
                else
                    next_state = WRONG;

            OPEN:
                next_state = IDLE;

            WRONG:
                if (failed_attempts == 2)
                    next_state = LOCKOUT;
                else
                    next_state = IDLE;

            LOCKOUT:
                next_state = LOCKOUT;

            default:
                next_state = IDLE;
        endcase
    end

    always @(*) begin
        unlock = (state == OPEN);
        locked = (state == LOCKOUT);
    end

endmodule
