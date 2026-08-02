module tree1 (
	feature0,
	feature1,
	feature2,
	feature3,
	feature4,
	feature5,
	feature6,
	feature7,
	feature8,
	feature9,
	feature10,
	feature11,
	feature12,
	feature13,
	feature14,
	feature15,
	feature16,
	feature17,
	clock,
	voted_class
);
	function IEEE754_comparator (
		input [31:0] a,
		input [31:0] b
	);
		IEEE754_comparator = (a[31] == 0 && b[31] == 1) || (a == b) ||
							 (a[31] == b[31] && a[30:23] > b[30:23]) ||
							 (a[31] == b[31] && a[30:23] == b[30:23] && a[22:0] > b[22:0] && a[31] == 0) ||
							 (a[31] == b[31] && a[30:23] == b[30:23] && a[22:0] < b[22:0] && a[31] == 1);
	endfunction

	input wire clock;

	input wire [31:0] feature0;
	input wire [31:0] feature1;
	input wire [31:0] feature2;
	input wire [31:0] feature3;
	input wire [31:0] feature4;
	input wire [31:0] feature5;
	input wire [31:0] feature6;
	input wire [31:0] feature7;
	input wire [31:0] feature8;
	input wire [31:0] feature9;
	input wire [31:0] feature10;
	input wire [31:0] feature11;
	input wire [31:0] feature12;
	input wire [31:0] feature13;
	input wire [31:0] feature14;
	input wire [31:0] feature15;
	input wire [31:0] feature16;
	input wire [31:0] feature17;

	output reg [3:0] voted_class;

	parameter class0 = 4'b0001;
	parameter class1 = 4'b0010;
	parameter class2 = 4'b0100;
	parameter class3 = 4'b1000;

	always @(posedge clock) begin
		if (IEEE754_comparator(32'b01000011110000000100000000000000, feature11)) begin
			if (IEEE754_comparator(32'b01000010101011110000000000000000, feature0)) begin
				if (IEEE754_comparator(32'b01000001100101000000000000000000, feature8)) begin
					voted_class <= class0;
				end 
				else begin
					voted_class <= class2;
				end
			end 
			else begin
				if (IEEE754_comparator(32'b01000011001001011000000000000000, feature3)) begin
					voted_class <= class0;
				end 
				else begin
					voted_class <= class2;
				end
			end
		end 
		else begin
			if (IEEE754_comparator(32'b01000000111100000000000000000000, feature5)) begin
				if (IEEE754_comparator(32'b01000010011110100000000000000000, feature4)) begin
					voted_class <= class2;
				end 
				else begin
					voted_class <= class2;
				end
			end 
			else begin
				if (IEEE754_comparator(32'b01000010110011110000000000000000, feature0)) begin
					voted_class <= class3;
				end 
				else begin
					voted_class <= class1;
				end
			end
		end
	end
endmodule