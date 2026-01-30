module tb_Gilbert();

    logic clk;
    logic reset;
    logic channel_state;

    integer count_good = 0;
    integer count_total = 0;
    real percentage_good;

    // Instantiate the Gilbert-Elliott channel FSM
    Gilbert fsm (
        .clk(clk),
        .reset(reset),
        .channel_state(channel_state)
    );

    // Clock generation
    always #5 clk = ~clk;

    // Monitor the channel states and count the occurrences
    always_ff @(posedge clk) begin
        if (reset) begin
            // Reset counts when the system is reset
            count_good <= 0;
            count_total <= 0;
        end else begin
            // Increment total count always
            count_total <= count_total + 1;
            
            // Increment good count if the channel is good
            if (channel_state) begin
                count_good <= count_good + 1;
            end
        end
    end

    // Calculate the percentage of good channel time at the end of the simulation
    initial begin
        clk = 0;
        reset = 1;  // Reset the system
        #10;
        reset = 0;  // Release reset
        #100000;      // Run for some time to observe behavior
        
        // Calculate the percentage of good channel occurrences
        percentage_good = (count_good * 100.0) / count_total;
        
        $display("Percentage of Good Channel Time: %0.2f%%", percentage_good);
        $finish;
    end

    // Optional: Continuously display the state and counters for debug
    initial begin
        $monitor("Time=%t, Channel State (1=Good, 0=Bad): %b, Good Count: %d, Total Count: %d",
                 $time, channel_state, count_good, count_total);
    end

endmodule
