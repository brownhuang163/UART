`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:sitrus-tech
// Engineer:Yu Huang
// 
// Create Date : 09/25/2019 04:50:23 PM
// Design Name : uart 
// Module Name : transmitter
// Project Name: uart
// Target Devices:spartan 7 
// Tool Versions:vivado 2018.1 
// Description: 
// 	implementation of uart transmitter
//
//  feature:
//      baud rate :support baud rate from 1220 to 128000
//      parity    :none
//      stop_bits :1-3
//      bit order : 0 for LSB first transmitting , 1 for MSB first transmitting
//
//
//////////////////////////////////////////////////////////////////////////////////
module basic_uart_transmitter(
    input                   clk,
    input                   rst,
    input                   tx_wr_ev,
    input       [7 :0]      tx_dat,
	input       [15:0]      divisor, //baud rate divide clock frequency
	input       [1 :0]      stop_bit_num,
	input                   trans_bit_order,//low:lsb first, high msb first
    output  reg             tx_dat_ser,
    output  reg             tx_done_ev,
    output  reg             tx_ready
    );
    parameter IDLE          = 2'b00;
    parameter START         = 2'b01;
    parameter TRANSMIT      = 2'b10;
    parameter STOP          = 2'b11;

    reg [15:0]      trans_cnt;
   	reg [7 :0]      tx_dat_vault;
   	reg [3 :0]      trans_bit_cnt;
    reg [1 :0]      state;
    reg [1 :0]      stop_bit_cnt;

    always@(posedge clk or posedge rst) begin
        if(rst) begin
            state           <= IDLE;
            tx_dat_ser      <= 1'b1;//start 
            tx_done_ev      <= 1'b0;
            tx_dat_vault    <= 8'h00;
            tx_ready        <= 1'b1;
            stop_bit_cnt    <= 2'b0;
            trans_cnt       <= 16'b0;
            trans_bit_cnt   <= 4'b0;
        end else begin
            case(state) 
                IDLE    : begin
                              if(tx_wr_ev) begin   
                                  state        <= START;
                                  tx_dat_vault <= tx_dat;
                                  tx_dat_ser   <= 1'b0;//start 
                                  tx_ready     <= 1'b0;
                              end else begin
                                  state        <= IDLE;
                                  tx_dat_vault <= tx_dat_vault;
                                  tx_dat_ser   <= 1'b1;//start 
                                  tx_ready     <= 1'b1;
                              end
                          end

                START   : begin
                              if(trans_cnt == divisor - 1'b1) begin
                                  trans_cnt  <= 16'b0;
                                  state      <= TRANSMIT;
                                  tx_dat_ser <= tx_dat_vault[0];//start 
                              end else begin
                                  trans_cnt  <= trans_cnt + 1'b1;
                                  state      <= START;
                                  tx_dat_ser <= 1'b0;//start 
                              end
                          end

                TRANSMIT: begin
                              if(trans_cnt == divisor - 1'b1) begin
                                  trans_cnt  <= 16'b0;
                                    
                                  if(trans_bit_cnt == 4'd7) begin
                                      trans_bit_cnt <= 4'd0;
                                      state         <= STOP;
                                      tx_done_ev    <= 1'b1;
                                  end else begin
                                      trans_bit_cnt <= trans_bit_cnt + 1'b1;
                                      state         <= TRANSMIT;
                                      tx_done_ev    <= 1'b0;
                                  end

                              end else begin
                                  trans_cnt  <= trans_cnt + 1'b1;
                                  state      <= TRANSMIT;
                                  tx_done_ev <= tx_done_ev;

                                  if(trans_bit_order) 
                                      tx_dat_ser <= tx_dat_vault[4'd7 - trans_bit_cnt];
                                  else
                                      tx_dat_ser <= tx_dat_vault[trans_bit_cnt];
                              end
                          end

                STOP    : begin
                              tx_done_ev    <= 1'b0;

                              if(trans_cnt == divisor - 1'b1) begin
                                  trans_cnt  <= 16'b0;

                                  if(stop_bit_cnt == stop_bit_num - 1'b1) begin
                                      stop_bit_cnt <= 2'b0;

                                      state     <= IDLE;
                                      tx_ready  <= 1'b1;
                                  end else begin
                                      state     <= STOP;
                                      tx_ready  <= 1'b0;
                                      
                                      stop_bit_cnt <= stop_bit_cnt + 1'b1;
                                  end
                              end else begin
                                  trans_cnt  <= trans_cnt + 1'b1;
                                  state      <= STOP;
                                  tx_ready   <= tx_ready;
                              end

                              tx_dat_ser <= 1'b1; 
                          end

                default : begin
                              state           <= IDLE;
                              tx_dat_ser      <= 1'b1;//start 
                              tx_done_ev      <= 1'b0;
                              tx_dat_vault    <= 8'h00;
                              tx_ready        <= 1'b1;
                              stop_bit_cnt    <= 2'b0;
                              trans_cnt       <= 16'b0;
                              trans_bit_cnt   <= 4'b0;
                          end
            endcase
        end
    end
endmodule



