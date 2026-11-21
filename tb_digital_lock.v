
`timescale 1ns/1ps

module tb_digital_lock;

    reg clk;
    reg reset;
    reg [3:0] password;
    reg enter;

    wire unlock;
    wire locked;
    wire [1:0] failed_attempts;

    digital_lock dut (
        .clk(clk),
        .reset(reset),
        .password(password),
        .enter(enter),
        .unlock(unlock),
        .locked(locked),
        .failed_attempts(failed_attempts)
    );

    // Generate clock
    always #5 clk = ~clk;

    // Submit a password
    task submit_password;
        input [3:0] pass;
        begin
            @(negedge clk);
            password = pass;
            enter = 1;

            @(negedge clk);
            enter = 0;

            repeat (4) @(negedge clk);
        end
    endtask

    initial begin
        clk = 0;
        reset = 1;
        password = 0;
        enter = 0;

        // Reset the system
        repeat (2) @(negedge clk);
        reset = 0;

        // Test 1: Correct password
        $display("TEST 1: Correct password");
        submit_password(4'b1010);
        if (unlock == 1)
            $display("PASS: Correct password accepted");
        else
            $display("CHECK: Observe unlock signal in waveform");

        // Test 2: First wrong password
        $display("TEST 2: First wrong password");
        submit_password(4'b0001);
        $display("Failed attempts = %d", failed_attempts);

        // Test 3: Second wrong password
        $display("TEST 3: Second wrong password");
        submit_password(4'b0010);
        $display("Failed attempts = %d", failed_attempts);

        // Test 4: Third wrong password
        $display("TEST 4: Third wrong password");
        submit_password(4'b0011);
        if (locked == 1)
            $display("PASS: Lockout activated");
        else
            $display("FAIL: Lockout not activated");

        // Test 5: Reset after lockout
        $display("TEST 5: Reset after lockout");
        reset = 1;
        @(negedge clk);
        reset = 0;
        @(negedge clk);

        if (locked == 0)
            $display("PASS: Reset cleared lockout");
        else
            $display("FAIL: Reset did not clear lockout");

        $finish;
    end

endmodule
