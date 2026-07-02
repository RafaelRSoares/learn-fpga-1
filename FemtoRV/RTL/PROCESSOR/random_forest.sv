// Random Forest Classifier Module for FemtoRV
// Implements a decision tree ensemble for classification
// Single instruction: RF_PREDICT reads tree data and outputs classification

module random_forest(
    input clk,
    input reset,
    
    // RISC-V instruction interface
    input [31:0] instruction,      // RF_PREDICT instruction
    input [31:0] x1,               // Feature vector input (register)
    input [31:0] x2,               // Feature vector input (register)
    input [31:0] x3,               // Feature vector input (register)
    input [31:0] x4,               // Feature vector input (register)
    
    // Control signals
    input start,                   // Start RF prediction
    output reg ready,              // Result ready
    output reg [31:0] result,      // Classification result
    
    // Memory interface (for tree data)
    input [31:0] tree_data_in,     // Tree parameters
    input [7:0] tree_addr,         // Tree parameter address
    input tree_we                  // Tree write enable
);

    // Constants for tree structure
    localparam TREE_COUNT = 4;     // Number of trees in ensemble
    localparam DEPTH = 3;          // Depth of each tree
    localparam NODES_PER_TREE = 15; // 2^4 - 1 nodes

    // Tree node structure: [feature_idx(3b), threshold(13b), left_class(8b), right_class(8b)]
    reg [31:0] tree_memory [TREE_COUNT * NODES_PER_TREE - 1:0];
    
    // Internal signals
    reg [31:0] features [3:0];
    reg [7:0] tree_predictions [TREE_COUNT - 1:0];
    integer tree_idx, node_idx, bit_idx;
    integer i, j;
    
    // Store feature inputs
    always @(posedge clk) begin
        features[0] <= x1;
        features[1] <= x2;
        features[2] <= x3;
        features[3] <= x4;
    end
    
    // Tree memory write interface
    always @(posedge clk) begin
        if (tree_we) begin
            tree_memory[tree_addr] <= tree_data_in;
        end
    end
    
    // Traverse decision tree
    task traverse_tree;
        input [7:0] tree_id;
        output [7:0] prediction;
        
        integer node_id, feature_idx, threshold, current_node;
        reg [31:0] node_data, feature_val;
        
        begin
            node_id = 0; // Start at root
            
            // Traverse depth levels
            repeat (DEPTH) begin
                current_node = tree_id * NODES_PER_TREE + node_id;
                node_data = tree_memory[current_node];
                
                // Decode node: [feature_idx(3b), threshold(13b), left_class(8b), right_class(8b)]
                feature_idx = node_data[31:29];
                threshold = node_data[28:16];
                
                // Get feature value
                feature_val = features[feature_idx[1:0]];
                
                // Decide left or right
                if (feature_val < {{19{threshold[12]}}, threshold}) begin
                    node_id = node_id * 2 + 1;  // Go left
                end else begin
                    node_id = node_id * 2 + 2;  // Go right
                end
            end
            
            // Get leaf class
            current_node = tree_id * NODES_PER_TREE + node_id;
            node_data = tree_memory[current_node];
            prediction = node_data[15:8];
        end
    endtask
    
    // Main RF prediction logic
    reg [1:0] rf_state;
    localparam STATE_IDLE = 2'b00;
    localparam STATE_PREDICT = 2'b01;
    localparam STATE_AGGREGATE = 2'b10;
    localparam STATE_DONE = 2'b11;
    
    always @(posedge clk) begin
        if (reset) begin
            rf_state <= STATE_IDLE;
            ready <= 1'b1;
            result <= 32'h0;
        end else begin
            case (rf_state)
                STATE_IDLE: begin
                    if (start && ready) begin
                        ready <= 1'b0;
                        rf_state <= STATE_PREDICT;
                    end
                end
                
                STATE_PREDICT: begin
                    // Get predictions from all trees
                    for (tree_idx = 0; tree_idx < TREE_COUNT; tree_idx = tree_idx + 1) begin
                        traverse_tree(tree_idx, tree_predictions[tree_idx]);
                    end
                    rf_state <= STATE_AGGREGATE;
                end
                
                STATE_AGGREGATE: begin
                    // Majority voting: count class occurrences
                    result <= aggregate_predictions();
                    rf_state <= STATE_DONE;
                end
                
                STATE_DONE: begin
                    ready <= 1'b1;
                    rf_state <= STATE_IDLE;
                end
            endcase
        end
    end
    
    // Majority voting function
    function [31:0] aggregate_predictions;
        integer vote_count [3:0];
        integer max_votes, max_class, i;
        
        begin
            // Initialize vote counters
            for (i = 0; i < 4; i = i + 1) begin
                vote_count[i] = 0;
            end
            
            // Count votes from each tree
            for (i = 0; i < TREE_COUNT; i = i + 1) begin
                vote_count[tree_predictions[i][1:0]] = 
                    vote_count[tree_predictions[i][1:0]] + 1;
            end
            
            // Find class with most votes
            max_votes = 0;
            max_class = 0;
            for (i = 0; i < 4; i = i + 1) begin
                if (vote_count[i] > max_votes) begin
                    max_votes = vote_count[i];
                    max_class = i;
                end
            end
            
            aggregate_predictions = max_class;
        end
    endfunction

endmodule
