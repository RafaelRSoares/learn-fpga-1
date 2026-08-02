module vehicle_forest_top (
    input wire clock,

    input wire [31:0] feature0,
    input wire [31:0] feature1,
    input wire [31:0] feature2,
    input wire [31:0] feature3,
    input wire [31:0] feature4,
    input wire [31:0] feature5,
    input wire [31:0] feature6,
    input wire [31:0] feature7,
    input wire [31:0] feature8,
    input wire [31:0] feature9,
    input wire [31:0] feature10,
    input wire [31:0] feature11,
    input wire [31:0] feature12,
    input wire [31:0] feature13,
    input wire [31:0] feature14,
    input wire [31:0] feature15,
    input wire [31:0] feature16,
    input wire [31:0] feature17,

    output reg [1:0] forest_vote,
    output reg valid
);

    wire [3:0] voted_class0;
    wire [3:0] voted_class1;
    wire [3:0] voted_class2;
    wire [3:0] voted_class3;

    wire [2:0] sum_class0;
    wire [2:0] sum_class1;
    wire [2:0] sum_class2;
    wire [2:0] sum_class3;

    wire [1:0] majority_vote;

    tree0 u_tree0 (
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
        .clock(clock),
        .voted_class(voted_class0)
    );

    tree1 u_tree1 (
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
        .clock(clock),
        .voted_class(voted_class1)
    );

    tree2 u_tree2 (
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
        .clock(clock),
        .voted_class(voted_class2)
    );

    tree3 u_tree3 (
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
        .clock(clock),
        .voted_class(voted_class3)
    );

    adder u_adder0 (
        .vote0(voted_class0[0]),
        .vote1(voted_class1[0]),
        .vote2(voted_class2[0]),
        .vote3(voted_class3[0]),
        .sum(sum_class0)
    );

    adder u_adder1 (
        .vote0(voted_class0[1]),
        .vote1(voted_class1[1]),
        .vote2(voted_class2[1]),
        .vote3(voted_class3[1]),
        .sum(sum_class1)
    );

    adder u_adder2 (
        .vote0(voted_class0[2]),
        .vote1(voted_class1[2]),
        .vote2(voted_class2[2]),
        .vote3(voted_class3[2]),
        .sum(sum_class2)
    );

    adder u_adder3 (
        .vote0(voted_class0[3]),
        .vote1(voted_class1[3]),
        .vote2(voted_class2[3]),
        .vote3(voted_class3[3]),
        .sum(sum_class3)
    );

    majority u_majority (
        .voted(majority_vote),
        .class0_votes(sum_class0),
        .class1_votes(sum_class1),
        .class2_votes(sum_class2),
        .class3_votes(sum_class3)
    );

    /*
     * As árvores registram seus votos em uma borda de subida.
     * Nesta mesma borda, os somadores ainda enxergam os votos antigos.
     * Portanto, a saída válida corresponde à amostra aplicada no
     * ciclo anterior.
     */
    always @(posedge clock) begin
        forest_vote <= majority_vote;
        valid <= 1'b1;
    end

endmodule