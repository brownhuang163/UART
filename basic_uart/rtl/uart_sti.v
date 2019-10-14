module uart_sti(
    input                           clk,
    input                           rst_n,
    input            [7:0]          rx_dat,
    input                           rx_dat_ev, 
    input                           tx_ready,
    output    reg    [7:0]          tx_dat,
    output    reg                   tx_wr_ev
);

localparam                       IDLE    =  0;
localparam                       SEND    =  1;   
localparam                       WAIT    =  2;   

reg             [7:0]            tx_str;
reg             [7:0]            tx_cnt;
reg             [31:0]           wait_cnt;
reg             [3:0]            state;

wire            [7:0]            rx_data;

always@(posedge clk or negedge rst_n) begin
	if(rst_n == 1'b0)
	begin
		wait_cnt <= 32'd0;
		tx_dat <= 8'd0;
		state <= IDLE;
		tx_cnt <= 8'd0;
		tx_wr_ev <= 1'b0;
	end else
	    case(state)
	    	IDLE:
	    		state <= SEND;
	    	SEND:
	    	begin
	    		wait_cnt <= 32'd0;
	    		tx_dat <= tx_str;

	    		if(tx_wr_ev == 1'b1 && tx_ready == 1'b1 && tx_cnt < 8'd37)//Send 12 bytes data
	    		begin
	    			tx_cnt <= tx_cnt + 8'd1; //Send data counter
	    		end
	    		else if(tx_wr_ev && tx_ready)//last byte sent is complete
	    		begin
	    			tx_cnt   <= 8'd0;
	    			tx_wr_ev <= 1'b0;
	    			state    <= WAIT;
	    		end
	    		else if(~tx_wr_ev)
	    		begin
	    			tx_wr_ev <= 1'b1;
	    		end
	    	end
	    	WAIT:
	    	begin
	    		wait_cnt <= wait_cnt + 32'd1;

                if(wait_cnt >= 32'd99999999) begin // wait for 1 second
	    			state    <= SEND;
                    wait_cnt <= 32'd0;
                end 
                
                if(rx_dat_ev) begin
                    tx_wr_ev <= 1'b1;
                    tx_dat   <= rx_dat;
                end else if(tx_wr_ev && tx_ready) begin
                    tx_wr_ev <= 1'b0;
                end 
	    	end
	    	default:
	    		state <= IDLE;
	    endcase
end

always@(*) begin
	case(tx_cnt)
		8'd0 :  tx_str <= "s";
		8'd1 :  tx_str <= "a";
		8'd2 :  tx_str <= "p";
		8'd3 :  tx_str <= "i";
		8'd4 :  tx_str <= "e";
		8'd5 :  tx_str <= "n";
		8'd6 :  tx_str <= "s";
		8'd7 :  tx_str <= ":";
		8'd8 :  tx_str <= "a";
		8'd9 :  tx_str <= " ";
		8'd10:  tx_str <= "b";
		8'd11:  tx_str <= "r";
		8'd12:  tx_str <= "i";
		8'd13:  tx_str <= "e";
		8'd14:  tx_str <= "f";
		8'd15:  tx_str <= " ";
		8'd16:  tx_str <= "h";
		8'd17:  tx_str <= "i";
		8'd18:  tx_str <= "s";
		8'd19:  tx_str <= "t";
		8'd20:  tx_str <= "o";
		8'd21:  tx_str <= "r";
		8'd22:  tx_str <= "y";
		8'd23:  tx_str <= " ";
		8'd24:  tx_str <= "o";
		8'd25:  tx_str <= "f";
		8'd26:  tx_str <= " ";
		8'd27:  tx_str <= "h";
		8'd28:  tx_str <= "u";
		8'd29:  tx_str <= "m";
		8'd30:  tx_str <= "a";
		8'd31:  tx_str <= "n";
		8'd32:  tx_str <= "k";
		8'd33:  tx_str <= "i";
		8'd34:  tx_str <= "n";
		8'd35:  tx_str <= "d";
		8'd36:  tx_str <= "\r";
		8'd37:  tx_str <= "\n";
		default:tx_str <= 8'd0;
	endcase
end


endmodule


