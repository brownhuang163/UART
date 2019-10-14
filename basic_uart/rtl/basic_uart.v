`timescale 1ns / 1ps //////////////////////////////////////////////////////////////////////////////////
// Company:sitrus-tech
// Engineer:Yu Huang
// 
// Create Date : 09/25/2019 04:50:23 PM
// Design Name : uart 
// Module Name : basic_uart
// Project Name: uart
// Target Devices:spartan 7 
// Tool Versions:vivado 2018.1 
// Description: 
// 	implementation of uart basic_uart
//
//  feature:
//      baud rate :support baud rate from 1220 to 128000
//      parity    :none
//      stop_bits :1-3
//      bit order : 0 for LSB first transmitting , 1 for MSB first transmitting
//////////////////////////////////////////////////////////////////////////////////
module basic_uart(
    input                   sys_clk,
    input                   rst,

    input    			    rx_dat_ser,
    output      [7 :0]      rx_dat, 
    output                  rx_dat_ev, 
    output                  tx_dat_ser,
    output                  tx_done_ev,
    output                  tx_ready,
    output                  tx_wr_ev
    );

    wire [7:0]  tx_dat;

    parameter [31:0]      CLK_FRE   			=	50*1000000;
	parameter [31:0]      BAUD_RATE 			=	1800;
	parameter [15:0]      DIVISOR   			=	CLK_FRE/BAUD_RATE;
    parameter             TRANS_BIT_ORDER   	=   1'b0;
	parameter [1 :0]      TRANS_STOP_BIT_NUM    =   2'b1;
    parameter             REC_BIT_ORDER         =   1'b0;
    parameter             STI_MODE              =   1'b1;
	
    basic_uart_transceiver i_uart_transceiver(
                    .clk(sys_clk),
                    .rst(~rst),
                    .tx_wr_ev(tx_wr_ev),
                    .rx_dat_ser(rx_dat_ser),
					.divisor(DIVISOR),
                    .tx_dat(tx_dat),
					.trans_bit_order(TRANS_BIT_ORDER),
					.trans_stop_bit_num(TRANS_STOP_BIT_NUM),
			        .rec_bit_order(REC_BIT_ORDER),
                    .rx_dat(rx_dat), 
                    .tx_dat_ser(tx_dat_ser),
                    .rx_dat_ev(rx_dat_ev),
                    .tx_done_ev(tx_done_ev),
                    .tx_ready(tx_ready));

     uart_sti i_uart_sti(
              .clk(sys_clk),
              .rst_n(rst),
              .rx_dat(rx_dat),
              .rx_dat_ev(rx_dat_ev),
	 		  .tx_dat(tx_dat),
              .tx_ready(tx_ready),
              .tx_wr_ev(tx_wr_ev));

endmodule




