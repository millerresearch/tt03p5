`default_nettype none

module tt_um_millerresearch_top (
	input  wire [7:0] ui_in,	// Dedicated inputs
	output wire [7:0] uo_out,	// Dedicated outputs
	input  wire [7:0] uio_in,	// IOs: Input path
	output wire [7:0] uio_out,	// IOs: Output path
	output wire [7:0] uio_oe,	// IOs: Enable path (active high: 0=input, 1=output)
	input  wire       ena,
	input  wire       clk,
	input  wire       rst_n
);

	assign uio_oe[7:0] = 8'b11110000;

	spinet #(.N(4)) SPINET (
		.clk(clk),
		.rst(^rst_n),

		.SS     ({ui_in[0],  ui_in[3],  ui_in[6],   uio_in[1]}),
		.SCLK   ({ui_in[1],  ui_in[4],  ui_in[7],   uio_in[2]}),
		.MOSI   ({ui_in[2],  ui_in[5],  uio_in[0],  uio_in[3]}),

		.MISO   ({uo_out[0], uo_out[3], uo_out[6],  uio_out[5]}),
		.txready({uo_out[1], uo_out[4], uo_out[7],  uio_out[6]}),
		.rxready({uo_out[2], uo_out[5], uio_out[4], uio_out[7]}) 
	);

endmodule
