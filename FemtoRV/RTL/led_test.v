module led_test(
    input wire pclk,
    output wire D1,
    output wire D2,
    output wire D3,
    output wire D4,
    output wire D5,
    input wire RESET
);

reg [31:0] counter = 0;

always @(posedge pclk) begin
    counter <= counter + 1;
end

assign D1 = counter[24];
assign D2 = counter[25];
assign D3 = counter[26];
assign D4 = counter[27];
assign D5 = 1'b0;

endmodule