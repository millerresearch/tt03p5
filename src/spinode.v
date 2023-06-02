module spinode #(parameter WIDTH=16, ABITS=3, ADDRESS=0) (
	input clk,
	input rst,
	input [WIDTH-1:0] fromring,
	output [WIDTH-1:0] toring,
	output txready, rxready,
	input SCLK, SS, MOSI,
	output MISO
);

	wire [WIDTH-1:0] txdata, rxdata;
	wire mosivalid, mosiack, misovalid, misoack;
		ringnode #(.WIDTH(WIDTH), .ABITS(ABITS), .ADDRESS(ADDRESS)) NODE (
			.clk(clk),
			.rst(rst),
			.fromring(fromring),
			.toring(toring),
			.fromclient(rxdata),
			.toclient(txdata),
			.txready(txready),
			.rxready(rxready),
			.misovalid(misovalid),
			.misoack(misoack),
			.mosivalid(mosivalid),
			.mosiack(mosiack)
		);
		ringspi #(.WIDTH(WIDTH)) SPI (
			.rst(rst),
			.txdata(txdata),
			.rxdata(rxdata),
			.misovalid(misovalid),
			.misoack(misoack),
			.mosivalid(mosivalid),
			.mosiack(mosiack),
			.MOSI(MOSI),
			.SCLK(SCLK),
			.SS(SS),
			.MISO(MISO)
		);
endmodule
