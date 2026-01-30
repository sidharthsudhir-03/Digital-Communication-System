/*module Gilbert (
    input logic clk,           // Clock signal
    input logic reset,         // Asynchronous reset
    output logic channel_state // Output: 1 for Good, 0 for Bad
);

    typedef enum logic {GOOD, BAD} state_t;
    state_t current_state, next_state;

    // LFSR for pseudo-random number generation
    reg [15:0] lfsr;
    wire feedback = lfsr[15] ^ lfsr[14] ^ lfsr[12] ^ lfsr[3];  // Example polynomial for maximal length

    // Threshold values based on a max value of 65535 (16-bit LFSR)
    localparam integer THRESHOLD_GB = 3277;  // Approximately 5% of 65535 3277
    localparam integer THRESHOLD_BG = 13107; // Approximately 20% of 65535

    // LFSR update and state transition logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 16'hACE1;  // Non-zero seed
            current_state <= GOOD; // Default state
        end else begin
            lfsr <= {lfsr[14:0], feedback}; // Shift LFSR
            // Determine the next state based on thresholds
            case (current_state)
                GOOD: next_state = (lfsr < THRESHOLD_GB) ? BAD : GOOD;
                BAD: next_state = (lfsr < THRESHOLD_BG) ? GOOD : BAD;
            endcase
        end
    end

    // Update current state and output based on the state
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= GOOD;
            channel_state <= 1;  // Good channel
        end else begin
            current_state <= next_state;
            channel_state <= (current_state == GOOD);
        end
    end

endmodule
*/

module Gilbert #(
    parameter  P_GB = 50,  // Probability of going from Good to Bad
    parameter  P_BG = 200   // Probability of going from Bad to Good
)(
    
    input logic clk,
    input logic reset,
    output logic channel_state  // Output: 1 for Good, 0 for Bad
);

    typedef enum logic {GOOD, BAD} state_t;
    state_t current_state, next_state;
    reg [9:0] random_number;

    // State transition and output logic within a single sequential block
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= GOOD;  // Default to Good on reset
            channel_state <= 1'b1;  // Output high for good channel
        end else begin
            // Transition logic
            case (current_state)
                GOOD: next_state = (random_number < (P_GB )) ? BAD : GOOD;
                BAD: next_state = (random_number < (P_BG )) ? GOOD : BAD;
            endcase
            
            // Update the current state based on the next state logic
            current_state <= next_state;

            // Set output based on the new current state
            channel_state <= (current_state == GOOD) ? 1'b1 : 1'b0;
        end
    end


    random_number_generator Random(
    .clk(clk),
    .reset(reset),
    .rnd_number(random_number) // 10-bit output for numbers 0-999
);

endmodule



module random_number_generator (
    input logic clk,        // Clock input
    input logic reset,      // Asynchronous reset
    output reg [9:0] rnd_number // Output random number, 10 bits to cover up to 1023
);

    reg [9:0] lfsr;         // 10-bit Linear Feedback Shift Register
    wire feedback;          // Feedback tap for LFSR

    // Polynomial: x^10 + x^3 + 1, chosen for maximal LFSR length
    assign feedback = lfsr[9] ^ lfsr[2];

    // LFSR update logic
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            lfsr <= 10'b1; // Initialize with a non-zero value to avoid getting stuck at 0
        end else begin
            lfsr <= {lfsr[8:0], feedback}; // Shift left and insert feedback
        end
    end

    // Assign the output, limiting the range to 0-999
    always_ff @(posedge clk) begin
        if (lfsr <= 999) begin
            rnd_number <= lfsr; // Use the LFSR value if within range
        end else begin
            rnd_number <= lfsr % 1000; // Wrap around if above 999
        end
    end

endmodule



