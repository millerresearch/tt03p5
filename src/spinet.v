module spinet #(parameter N=8, WIDTH=16, ABITS=3) (
	input clk,
	input rst,
	output [N-1:0] txready,
	output [N-1:0] rxready,
	input [N-1:0] MOSI, SCLK, SS,
	output [N-1:0] MISO
	);

	wire [WIDTH-1:0] r[N-1:0];
	genvar i;
	generate for (i = 0; i < N; i = i+1) begin
		spinode #(.WIDTH(WIDTH), .ABITS(ABITS), .ADDRESS(i)) NODE (
			.clk(clk),
			.rst(rst),
			.fromring(r[(i+N-1)%N]),
			.toring(r[i]),
			.txready(txready[i]),
			.rxready(rxready[i]),
			.MOSI(MOSI[i]),
			.SCLK(SCLK[i]),
			.SS(SS[i]),
			.MISO(MISO[i])
		);
	end endgenerate
endmodule
