`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:sitrus-tech
// Engineer:Yu Huang
// 
// Create Date : 09/25/2019 04:50:23 PM
// Design Name : uart 
// Module Name : basic_uart_receiver
// Project Name: uart
// Target Devices:spartan 7 
// Tool Versions:vivado 2018.1 
// Description: 
// 	implementation of uart_transceiver
// 
//  feature:
//      baud rate :support baud rate from 1220 to 128000
//      parity    :none
//      stop_bits :1-3
//      bit order : 0 for LSB first transmitting , 1 for MSB first transmitting
//
//
//////////////////////////////////////////////////////////////////////////////////
module basic_uart_receiver
(
	input                        clk,              //clock input
	input                        rst,            //asynchronous reset input, low active 
	input                        rx_dat_ser,            //serial data input
    input         [15:0]         divisor,      
    input                        rec_bit_order,

	output reg    [7:0]          rx_dat,          //received serial data
	output reg                   rx_dat_ev    //received serial data is valid
);
    //state machine code
    localparam                       IDLE      = 1;
    localparam                       START     = 2; //start bit
    localparam                       RECEIVE   = 3; //data bits
    localparam                       STOP      = 4; //stop bit
    
    reg     [2 :0]                   state;
    reg                              rx_d0;          
    reg                              rx_d1;        
    reg     [7 :0]                   rx_bits;        
    reg     [15:0]                   rec_cnt;        
    reg     [2 :0]                   bit_cnt;        
    
    always@(posedge clk or posedge rst) begin
    	if(rst) begin
    		rx_d0 <= 1'b1;
    		rx_d1 <= 1'b1;	
    	end else begin
    		rx_d0 <= rx_dat_ser;
    		rx_d1 <= rx_d0;
    	end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
    		state      <= IDLE;
            rec_cnt    <= 16'b0;
            bit_cnt    <= 3'b0;
            rx_dat <= 7'b0;
            rx_dat_ev   <= 1'b0;
            rx_bits    <= 8'b0;
        end else begin
    	    case(state)
                IDLE:begin
                           if(rx_d1 == 1'b0) begin
    	    		       	state <= START;
                           end else begin
    	    		       	state <= IDLE;
                           end
                     end
    
    	    	START:
                    if(rec_cnt == divisor - 1) begin
                        rec_cnt  <= 16'b0;
    	    			state    <= RECEIVE;
                    end else begin
    	    			state    <= START;
                        rec_cnt  <= rec_cnt + 1'b1;
                    end
    
                RECEIVE:begin
                            if(rec_cnt == divisor - 1) begin
    
                                rec_cnt <= 16'b0;
    
                                if(bit_cnt == 3'd7) begin
                                    bit_cnt  <= 3'd0;
    	    		        	    state    <= STOP;
                                    rx_dat_ev <= 1'b1;
                                end else begin
                                    bit_cnt  <= bit_cnt + 1'b1;
                                    rx_dat_ev <= 1'b0;
                                end
    
                            end else begin
                                rec_cnt  <= rec_cnt + 1'b1;
    	    		        	state    <= RECEIVE;
                                rx_dat_ev <= 1'b0;
                            end
    
                            if(rec_cnt == divisor/2) begin
                                if(rec_bit_order) 
                                    rx_bits[3'd7 - bit_cnt] <= rx_d1;
                                else
                                    rx_bits[bit_cnt] <= rx_d1;
                            end else begin
                                rx_bits <= rx_bits;
                            end
                        end
                    
                STOP:begin
                            if(rx_dat_ev) begin 
    	    	                rx_dat <= rx_bits;//latch received data
                            end else begin
                                rx_dat <= rx_dat; 
                            end
    
                            rx_dat_ev <= 1'b0;
    
                            if(rec_cnt == divisor - 1) begin
                                rec_cnt  <= 16'b0;
    	    		        	state    <= IDLE;
                            end else begin
                                rec_cnt  <= rec_cnt + 1'b1;
    	    		        	state    <= STOP;
                            end
                       end
    	    	default:
    	    		state <= IDLE;
    	    endcase
        end
    end

endmodule 


