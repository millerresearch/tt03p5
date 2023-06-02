module ringspi #(parameter WIDTH=16) (
	input rst,
	input SCLK, SS, MOSI,
	output MISO,
	input misovalid,
	output reg misoack,
	output reg mosivalid,
	input mosiack,
	output [WIDTH-1:0] rxdata,
	input [WIDTH-1:0] txdata
);

	localparam LOGWIDTH = $clog2(WIDTH);
	reg [WIDTH:0] shiftreg;
	assign MISO = shiftreg[WIDTH];
	reg [LOGWIDTH-1:0] bitcount;
	reg [WIDTH-1:0] inbuf;
	assign rxdata = inbuf;

	// capture incoming data on falling clock edge
	always @(negedge SCLK or posedge SS)
		if (SS) begin
			bitcount <= 0;
			shiftreg[0] <= 0;
		end else begin
			if (bitcount != WIDTH-1) begin
				bitcount <= bitcount + 1;
				shiftreg[0] <= MOSI;
			end else begin
				bitcount <= 0;
				if (mosiack == mosivalid) begin
					inbuf <= {shiftreg[WIDTH-1:1],MOSI};
				end
			end
		end

	// set up next outgoing data on rising clock edge
	always @(posedge SCLK or posedge SS)
		if (SS) begin
			shiftreg[WIDTH:1] <= 0;
		end else begin
			if (bitcount == 0) begin
				if (misovalid != misoack) begin
					shiftreg[WIDTH:1] <= txdata;
				end else
					shiftreg[WIDTH:1] <= 0;
			end else
				shiftreg[WIDTH:1] <= shiftreg[WIDTH-1:0];
		end

	// handshake with node
	always @(negedge SCLK or posedge rst)
		if (rst) begin
			mosivalid <= 0;
		end else begin
			if (bitcount == WIDTH-1 && mosiack == mosivalid)
				mosivalid <= ~mosivalid;
		end
	always @(posedge SCLK or posedge rst)
		if (rst) begin
			misoack <= 0;
		end else begin
			if (bitcount == 0 && misovalid != misoack)
				misoack <= ~misoack;
		end

endmodule
