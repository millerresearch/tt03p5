module ringnode #(parameter WIDTH=16, ABITS=3, ADDRESS=0) (
	input clk,
	input rst,
	input [WIDTH-1:0] fromring,
	output [WIDTH-1:0] toring,
	input [WIDTH-1:0] fromclient,
	output [WIDTH-1:0] toclient,
	output txready, rxready,
	input mosivalid, misoack,
	output reg mosiack, misovalid
	);

	wire [ABITS-1:0] address = ADDRESS;
	reg [1:0] mosivalid_sync, misoack_sync;
	always @(posedge clk or posedge rst)
	if (rst) begin
		mosivalid_sync <= 0;
		misoack_sync <= 0;
	end else begin
		mosivalid_sync <= {mosivalid_sync[0],mosivalid};
		misoack_sync <= {misoack_sync[0],misoack};
	end

	localparam
		FULL = WIDTH-1, ACK = WIDTH-2,
		DST = (WIDTH-2) - ABITS, SRC = (WIDTH-2) - 2*ABITS;

	reg [WIDTH-1:0] rxbuf, txbuf, ringbuf;
	reg busy;
	assign toring = ringbuf;
	assign toclient = rxbuf;
	assign rxready = rxbuf[FULL];
	assign txready = ~txbuf[FULL];
	reg xmit, recv, seize;

	reg [WIDTH-1:0] outpkt;
	always @(*) begin
		outpkt = fromring;
		xmit = 0;
		recv = 0;
		seize = 0;
		case (fromring[FULL:ACK])
		2'b00:	       // free slot - transmit if ready
			if (txbuf[FULL] & ~busy) begin
				outpkt = txbuf;
				outpkt[SRC +: ABITS] = address;
				outpkt[FULL] = 1;
				seize = 1;
			end
		2'b10, 2'b11:  // payload - return ack to sender
			if (fromring[DST +: ABITS] == address && !rxbuf[FULL]) begin
				outpkt[FULL:ACK] = 2'b01;
				recv = 1;
			end
		2'b01:        // ack
			if (fromring[SRC +: ABITS] == address) begin
				outpkt[ACK] = 0;
				xmit = 1;
			end
		endcase
	end

	always @(posedge clk or posedge rst)
	if (rst) begin
		ringbuf <= 0;
		rxbuf <= 0;
		txbuf <= 0;
		busy <= 0;
		mosiack <= 0;
		misovalid <= 0;
	end else begin
		ringbuf <= outpkt;
		if (recv) begin
			rxbuf <= fromring;
			misovalid <= ~misovalid;
		end else if (misoack_sync[1] == misovalid)
			rxbuf[FULL] <= 0;
		if (mosivalid_sync[1] != mosiack) begin
			txbuf <= fromclient;
			mosiack <= ~mosiack;
		end else if (xmit)
			txbuf[FULL] <= 0;
		if (seize)
			busy <= 1;
		else if (xmit)
			busy <= 0;
	end
endmodule

