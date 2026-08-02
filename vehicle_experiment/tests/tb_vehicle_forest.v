`timescale 1ns/1ps

module tb_vehicle_forest;

    localparam SAMPLE_COUNT = 169;
    localparam FEATURE_COUNT = 18;

    reg clock;

    reg [31:0] feature0;
    reg [31:0] feature1;
    reg [31:0] feature2;
    reg [31:0] feature3;
    reg [31:0] feature4;
    reg [31:0] feature5;
    reg [31:0] feature6;
    reg [31:0] feature7;
    reg [31:0] feature8;
    reg [31:0] feature9;
    reg [31:0] feature10;
    reg [31:0] feature11;
    reg [31:0] feature12;
    reg [31:0] feature13;
    reg [31:0] feature14;
    reg [31:0] feature15;
    reg [31:0] feature16;
    reg [31:0] feature17;

    wire [1:0] forest_vote;
    wire valid;

    reg [31:0] features [0:SAMPLE_COUNT * FEATURE_COUNT - 1];
    reg [1:0] expected [0:SAMPLE_COUNT - 1];

    integer sample;
    integer errors;

    vehicle_forest_top dut (
        .clock(clock),

        .feature0(feature0),
        .feature1(feature1),
        .feature2(feature2),
        .feature3(feature3),
        .feature4(feature4),
        .feature5(feature5),
        .feature6(feature6),
        .feature7(feature7),
        .feature8(feature8),
        .feature9(feature9),
        .feature10(feature10),
        .feature11(feature11),
        .feature12(feature12),
        .feature13(feature13),
        .feature14(feature14),
        .feature15(feature15),
        .feature16(feature16),
        .feature17(feature17),

        .forest_vote(forest_vote),
        .valid(valid)
    );

    always #5 clock = ~clock;

    task load_sample;
        input integer index;
        integer base;
        begin
            base = index * FEATURE_COUNT;

            feature0  = features[base + 0];
            feature1  = features[base + 1];
            feature2  = features[base + 2];
            feature3  = features[base + 3];
            feature4  = features[base + 4];
            feature5  = features[base + 5];
            feature6  = features[base + 6];
            feature7  = features[base + 7];
            feature8  = features[base + 8];
            feature9  = features[base + 9];
            feature10 = features[base + 10];
            feature11 = features[base + 11];
            feature12 = features[base + 12];
            feature13 = features[base + 13];
            feature14 = features[base + 14];
            feature15 = features[base + 15];
            feature16 = features[base + 16];
            feature17 = features[base + 17];
        end
    endtask

    initial begin
        clock = 1'b0;
        errors = 0;

        feature0 = 0;
        feature1 = 0;
        feature2 = 0;
        feature3 = 0;
        feature4 = 0;
        feature5 = 0;
        feature6 = 0;
        feature7 = 0;
        feature8 = 0;
        feature9 = 0;
        feature10 = 0;
        feature11 = 0;
        feature12 = 0;
        feature13 = 0;
        feature14 = 0;
        feature15 = 0;
        feature16 = 0;
        feature17 = 0;

        $readmemh(
            "exports/verilog/vehicle_features.hex",
            features
        );

        $readmemh(
            "exports/verilog/vehicle_expected.hex",
            expected
        );

        /*
         * Primeiro clock para inicializar os registradores das árvores.
         */
        @(negedge clock);
        load_sample(0);

        /*
         * Na primeira subida, as árvores registram os votos da amostra 0.
         * Na segunda subida, forest_vote registra a maioria desses votos.
         */
        @(posedge clock);
        @(posedge clock);
        #1;

        if (forest_vote !== expected[0]) begin
            $display(
                "ERRO amostra 0: Verilog=%0d esperado=%0d",
                forest_vote,
                expected[0]
            );
            errors = errors + 1;
        end

        for (sample = 1; sample < SAMPLE_COUNT; sample = sample + 1) begin
            @(negedge clock);
            load_sample(sample);

            @(posedge clock);
            @(posedge clock);
            #1;

            if (forest_vote !== expected[sample]) begin
                $display(
                    "ERRO amostra %0d: Verilog=%0d esperado=%0d",
                    sample,
                    forest_vote,
                    expected[sample]
                );
                errors = errors + 1;
            end
        end

        $display("");
        $display(
            "Equivalencia Verilog x Python: %0d/%0d",
            SAMPLE_COUNT - errors,
            SAMPLE_COUNT
        );

        if (errors == 0) begin
            $display("RESULTADO: PASSOU");
        end
        else begin
            $display("RESULTADO: FALHOU");
        end

        $finish;
    end

endmodule