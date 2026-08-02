module controller (
	clk,
	rst,
	compute_vote,
	forest_vote,
	valid_data,
	data
);
	input wire clk;
	input wire rst;
	input wire valid_data;

	input wire [575:0] data;

	output reg [1:0] forest_vote;
	output reg compute_vote;

	wire compute_vote0;
	wire compute_vote1;
	wire compute_vote2;
	wire compute_vote3;

	wire [3:0] voted_class0;
	wire [3:0] voted_class1;
	wire [3:0] voted_class2;
	wire [3:0] voted_class3;

	wire [2:0] sum_class0;
	wire [2:0] sum_class1;
	wire [2:0] sum_class2;
	wire [2:0] sum_class3;

	wire [2:0] w_forest_vote;

	tree0 tree0(
		.clk(clk),
		.rst(rst),
		.data(data),
		.valid_data(valid_data),
		.voted_class(voted_class0),
		.compute_vote(compute_vote0) 
	);

	tree1 tree1(
		.clk(clk),
		.rst(rst),
		.data(data),
		.valid_data(valid_data),
		.voted_class(voted_class1),
		.compute_vote(compute_vote1) 
	);

	tree2 tree2(
		.clk(clk),
		.rst(rst),
		.data(data),
		.valid_data(valid_data),
		.voted_class(voted_class2),
		.compute_vote(compute_vote2) 
	);

	tree3 tree3(
		.clk(clk),
		.rst(rst),
		.data(data),
		.valid_data(valid_data),
		.voted_class(voted_class3),
		.compute_vote(compute_vote3) 
	);

	adder adder0(
		.sum(sum_class0),
		.vote0(voted_class0[0]),
		.vote1(voted_class1[0]),
		.vote2(voted_class2[0]),
		.vote3(voted_class3[0]) 
	);

	adder adder1(
		.sum(sum_class1),
		.vote0(voted_class0[1]),
		.vote1(voted_class1[1]),
		.vote2(voted_class2[1]),
		.vote3(voted_class3[1]) 
	);

	adder adder2(
		.sum(sum_class2),
		.vote0(voted_class0[2]),
		.vote1(voted_class1[2]),
		.vote2(voted_class2[2]),
		.vote3(voted_class3[2]) 
	);

	adder adder3(
		.sum(sum_class3),
		.vote0(voted_class0[3]),
		.vote1(voted_class1[3]),
		.vote2(voted_class2[3]),
		.vote3(voted_class3[3]) 
	);

	majority majority(
		.voted(w_forest_vote),
		.class0_votes(sum_class0),
		.class1_votes(sum_class1),
		.class2_votes(sum_class2),
		.class3_votes(sum_class3) 
	);

	always @(posedge clk) begin 
		if (compute_vote0 && compute_vote1 && compute_vote2 && compute_vote3) begin
			forest_vote <= w_forest_vote;
			compute_vote <= 1'b1;
 		end
		else begin
			compute_vote <= 1'b0;
 		end
 	end
endmodule