module uart_tb;

reg  	   rst;
reg  	   clk; 

wire [7:0] rx_dat;
wire [7:0] tx_dat;

reg  rx_dat_ser;


parameter [31:0]      CLK_FRE   			=	50*1000000;
parameter [31:0]      BAUD_RATE 			=	115200;
parameter [15:0]      DIVISOR   			=	CLK_FRE/BAUD_RATE;
parameter             TRANS_BIT_ORDER   	=   1'b0;
parameter [1 :0]      TRANS_STOP_BIT_NUM    =   2'b1;

basic_uart dut( .sys_clk(clk),
				.rst(rst),
				.rx_dat_ser(rx_dat_ser),
				.rx_dat(rx_dat), 
				.tx_dat_ser(tx_dat_ser),
				.tx_dat(tx_dat),
				.rx_dat_ev(rx_dat_ev),
				.tx_done_ev(tx_done_ev),
				.tx_wr_ev(tx_wr_ev),
				.tx_ready(tx_ready));

initial begin
	rx_dat_ser = 1'b1;
end

initial begin
	rst   = 1'b0;
	#100;
	rst   = 1'b1;
end

initial begin
		clk = 0;
		forever #10 clk = ~clk;
end

endmodule
