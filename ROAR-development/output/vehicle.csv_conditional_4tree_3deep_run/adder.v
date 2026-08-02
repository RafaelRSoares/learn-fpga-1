module adder (
vote0,
vote1,
vote2,
vote3,
	sum
);
	input wire vote0;
	input wire vote1;
	input wire vote2;
	input wire vote3;

	output wire [1:0] sum;

	assign sum = vote0 + vote1 + vote2 + vote3;
endmodule