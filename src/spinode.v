module spinode #(parameter WIDTH=16, ABITS=3, ADDRESS=0) (
	input clk,
	input rst,
	input [WIDTH-1:0] fromring,
	output [WIDTH-1:0] toring,
	output txready, rxready,
	input SCLK, SS, MOSI,
	output MISO
);

	wire [15:0] txdata, rxdata;
	wire mosivalid, mosiack, misovalid, misoack;
		ringnode #(.WIDTH(WIDTH), .ABITS(ABITS), .ADDRESS(ADDRESS)) NODE (
			.clk(clk),
			.rst(rst),
			.fromring(fromring),
			.toring(toring),
			.fromclient({rxdata[15:14],rxdata[12:11],rxdata[9:8],rxdata[7:0]}),
			.toclient({txdata[13:12],1'b0,txdata[11:10],1'b0,txdata[7:0]}),
			.txready(txready),
			.rxready(rxready),
			.misovalid(misovalid),
			.misoack(misoack),
			.mosivalid(mosivalid),
			.mosiack(mosiack)
		);
		ringspi #(.WIDTH(16)) SPI (
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
