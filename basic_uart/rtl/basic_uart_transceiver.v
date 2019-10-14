`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:sitrus-tech
// Engineer:Yu Huang
// 
// Create Date : 09/25/2019 04:50:23 PM
// Design Name : uart 
// Module Name : uart_transceiver
// Project Name: uart
// Target Devices:spartan 7 
// Tool Versions:vivado 2018.1 
// Description: 
// 	implementation of uart_transceiver
//////////////////////////////////////////////////////////////////////////////////
module basic_uart_transceiver(
    input                   clk,
    input                   rst,
    input                   tx_wr_ev,
    input                   rx_dat_ser,
	input       [15:0]      divisor,      
    input       [7 :0]      tx_dat,
	input                   trans_bit_order,
	input       [1 :0]      trans_stop_bit_num,
	input                   rec_bit_order,

    output      [7 :0]      rx_dat, 
    output                  tx_dat_ser,
    output                  rx_dat_ev,
    output                  tx_done_ev,
    output                  tx_ready
    );

    basic_uart_transmitter uart_transmitter_i(
                     .clk(clk),
                     .rst(rst),
                     .tx_wr_ev(tx_wr_ev),
                     .tx_dat(tx_dat),
					 .divisor(divisor),
					 .stop_bit_num(trans_stop_bit_num),
					 .trans_bit_order(trans_bit_order),
                     .tx_dat_ser(tx_dat_ser),
                     .tx_done_ev(tx_done_ev),
                     .tx_ready(tx_ready));

    basic_uart_receiver uart_receiver_i(
                  .clk(clk),
                  .rst(rst),
                  .rx_dat_ser(rx_dat_ser),
			      .rec_bit_order(rec_bit_order),
			      .divisor(divisor),
                  .rx_dat(rx_dat), 
                  .rx_dat_ev(rx_dat_ev));

endmodule



