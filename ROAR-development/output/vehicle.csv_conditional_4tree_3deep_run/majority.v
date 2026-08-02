module majority (
	voted,
	class0_votes,
	class1_votes,
	class2_votes,
	class3_votes
);
	input wire [2:0] class0_votes;
	input wire [2:0] class1_votes;
	input wire [2:0] class2_votes;
	input wire [2:0] class3_votes;

	output wire [1:0] voted;

	reg [1:0] voted_reg;

	assign voted = voted_reg;

	always @(*) begin
		if ((class0_votes >= class1_votes) && (class0_votes >= class2_votes) && (class0_votes >= class3_votes)) begin
			voted_reg = 2'b00;
		end
		else if ((class1_votes >= class2_votes) && (class1_votes >= class3_votes)) begin
			voted_reg = 2'b01;
		end
		else if ((class2_votes >= class3_votes)) begin
			voted_reg = 2'b10;
		end
		else begin
			voted_reg = 2'b11;
		end
	end
endmodule