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

    output wire [2:0] sum;

    assign sum =
        {2'b00, vote0} +
        {2'b00, vote1} +
        {2'b00, vote2} +
        {2'b00, vote3};

endmodule