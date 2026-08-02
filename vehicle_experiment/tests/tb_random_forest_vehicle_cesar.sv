`timescale 1ns/1ps

module tb_random_forest_vehicle_cesar;

    localparam integer SAMPLE_COUNT = 169;
    localparam integer FEATURE_COUNT = 18;
    localparam integer TREE_WORD_COUNT = 60;

    reg clk;
    reg reset;


    reg [4:0] feature_addr;
    reg [31:0] feature_data_in;
    reg feature_we;

    reg start;
    wire ready;
    wire [31:0] result;

    reg [31:0] tree_data_in;
    reg [7:0] tree_addr;
    reg tree_we;

    reg [31:0] tree_words [0:TREE_WORD_COUNT - 1];

    reg [31:0] feature_words [
        0:SAMPLE_COUNT * FEATURE_COUNT - 1
    ];

    reg [31:0] expected_words [0:SAMPLE_COUNT - 1];

    integer index;
    integer sample_index;
    integer feature;
    integer errors;
    integer cycles_waited;

    random_forest_vehicle dut (
        .clk(clk),
        .reset(reset),

        .feature_addr(feature_addr),
        .feature_data_in(feature_data_in),
        .feature_we(feature_we),

        .start(start),
        .ready(ready),
        .result(result),

        .tree_data_in(tree_data_in),
        .tree_addr(tree_addr),
        .tree_we(tree_we)
    );

    always #5 clk = ~clk;

    /*
     * Write one word into the accelerator's tree memory.
     *
     * Values are prepared on a falling edge and captured by
     * the accelerator on the following rising edge.
     */
    task write_tree_word;
        input integer address;
        input [31:0] value;

        begin
            @(negedge clk);

            tree_addr = address[7:0];
            tree_data_in = value;
            tree_we = 1'b1;

            @(negedge clk);

            tree_we = 1'b0;
        end
    endtask

    /*
     * Write one of the 18 input features.
     *
     * The HEX file already contains feature * 2.
     */
    task write_feature;
        input integer address;
        input [31:0] value;

        begin
            @(negedge clk);

            feature_addr = address[4:0];
            feature_data_in = value;
            feature_we = 1'b1;

            @(negedge clk);

            feature_we = 1'b0;
        end
    endtask

    /*
     * Produce a one-cycle start pulse.
     */
    task start_inference;
        begin
            @(negedge clk);
            start = 1'b1;

            @(negedge clk);
            start = 1'b0;
        end
    endtask

    initial begin
        clk = 1'b0;
        reset = 1'b1;


        feature_addr = 5'd0;
        feature_data_in = 32'd0;
        feature_we = 1'b0;

        start = 1'b0;

        tree_data_in = 32'd0;
        tree_addr = 8'd0;
        tree_we = 1'b0;

        errors = 0;
        cycles_waited = 0;

        $readmemh(
            "exports/cesar_vehicle/vehicle_tree_memory.hex",
            tree_words
        );

        $readmemh(
            "exports/cesar_vehicle/vehicle_features_x2.hex",
            feature_words
        );

        $readmemh(
            "exports/cesar_vehicle/vehicle_expected.hex",
            expected_words
        );

        /*
         * Hold reset for a few clock cycles.
         */
        repeat (3) begin
            @(posedge clk);
        end

        @(negedge clk);
        reset = 1'b0;

        /*
         * Load the 60 words representing the four trees.
         *
         * This happens once, just as it will in the firmware.
         */
        for (
            index = 0;
            index < TREE_WORD_COUNT;
            index = index + 1
        ) begin
            write_tree_word(
                index,
                tree_words[index]
            );
        end

        $display(
            "Memoria das arvores carregada: %0d palavras",
            TREE_WORD_COUNT
        );

        /*
         * Test all 169 samples.
         */
        for (
            sample_index = 0;
            sample_index < SAMPLE_COUNT;
            sample_index = sample_index + 1
        ) begin
            /*
             * Load the 18 features of the current sample_index.
             */
            for (
                feature = 0;
                feature < FEATURE_COUNT;
                feature = feature + 1
            ) begin
                write_feature(
                    feature,
                    feature_words[
                        sample_index * FEATURE_COUNT + feature
                    ]
                );
            end

            if (ready !== 1'b1) begin
                $display(
                    "ERRO: acelerador nao estava pronto antes da amostra %0d",
                    sample_index
                );

                errors = errors + 1;
            end

            start_inference();

            /*
             * After start is accepted, ready must become zero.
             */
            if (ready !== 1'b0) begin
                $display(
                    "ERRO: ready nao baixou na amostra %0d",
                    sample_index
                );

                errors = errors + 1;
            end

            cycles_waited = 0;

            while (
                ready !== 1'b1 &&
                cycles_waited < 20
            ) begin
                @(posedge clk);
                #1;

                cycles_waited = cycles_waited + 1;
            end

            if (cycles_waited >= 20) begin
                $display(
                    "ERRO: timeout na amostra %0d",
                    sample_index
                );

                errors = errors + 1;
            end
            else if (
                result[1:0] !==
                expected_words[sample_index][1:0]
            ) begin
                $display(
                    "ERRO amostra %0d: Verilog=%0d esperado=%0d ciclos=%0d",
                    sample_index,
                    result[1:0],
                    expected_words[sample_index][1:0],
                    cycles_waited
                );

                errors = errors + 1;
            end
        end

        $display("");
        $display(
            "Equivalencia acelerador Cesar Vehicle x Python: %0d/%0d",
            SAMPLE_COUNT - errors,
            SAMPLE_COUNT
        );

        if (errors == 0) begin
            $display("RESULTADO: PASSOU");
        end
        else begin
            $display(
                "RESULTADO: FALHOU com %0d erros",
                errors
            );
        end

        $finish;
    end

endmodule
