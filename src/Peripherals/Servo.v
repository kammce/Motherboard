`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/26/2017 08:22:01 PM
// Design Name:
// Module Name: ServoTop
// Project Name:
// Target Devices:
// Tool Versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////

module ServoTop(
	input wire clk,
	input wire rst,
	output wire [3:0] signal
);

wire [31:0] data;

reg cs;
reg [1:0] addr;
reg [15:0] data_reg;

assign data = (cs) ? data_reg : 0;

ServoController servo(
    .clk(clk),
    .rst(rst),
    .cs(cs), // chip select
    .addr(addr[1:0]),
    .data(data[15:0]),
    .signal(signal)
);

reg [2:0] init;

always @(posedge clk or posedge rst) begin
	if (rst)
	begin
		init = 0;
		cs = 1;
	end
	else if(init < 3'b100)
	begin
		addr = init;
		case(addr)
			3'b000: begin
				data_reg = 32'd500;
			end
			3'b001: begin
				data_reg = 32'd1000;
			end
			3'b010: begin
				data_reg = 32'd1500;
			end
			3'b011: begin
				data_reg = 32'd2000;
			end
		endcase
		init = init + 1;
	end
	else begin
		cs = 0;
	end
end

endmodule


module ServoModule(
	input wire clk,
	input wire rst,
	input wire load,
	input wire [15:0] data,
	output reg signal
);
// ==================================
//// Internal Parameter Field
// ==================================
parameter MAX_COUNT    = 20000*100;
//// Bits required to reach 2,000,000
parameter COUNT_WIDTH  = 32;
// ==================================
//// Registers
// ==================================
reg  [COUNT_WIDTH-1:0] counter;
reg  [COUNT_WIDTH-1:0] compare_value;
reg  [COUNT_WIDTH-1:0] tmp_compare_value;
// ==================================
//// Wires
// ==================================
// wire [PWM_SIGNAL_COUNT-1:0] select;
// ==================================
//// Wire Assignments
// ==================================
// assign select[0]  = (2'b00) ? 1 : 0;
// ==================================
//// Modules
// ==================================
// ==================================
//// Behavioral Block
// ==================================
always @(posedge clk or
		 posedge rst) begin
    if (rst) begin
        counter = 0;
        compare_value = 0;
        tmp_compare_value = 0;
    end
    else if(load) begin
        tmp_compare_value = data;
    end
    else begin
        if(counter > MAX_COUNT) begin
        	compare_value = tmp_compare_value;
	        counter = 0;
        	signal = 1;
        end
        if(counter >= compare_value*100) begin
        	signal = 0;
        end
	    counter = counter + 1;
    end
end

endmodule


module ServoController #(
    parameter SIGNAL_BIT_WIDTH  = 16,
    parameter ADDRESS_BIT_WIDTH = 2,
    parameter PWM_SIGNAL_COUNT  = 4
)
(
    input wire clk,
    input wire rst,
    input wire cs, // chip select
    input wire  [ADDRESS_BIT_WIDTH-1:0] addr,
    input wire  [SIGNAL_BIT_WIDTH-1:0]  data,
    output wire [PWM_SIGNAL_COUNT-1:0]  signal
);
// ==================================
//// Registers
// ==================================
// ==================================
//// Wires
// ==================================
wire [PWM_SIGNAL_COUNT-1:0] load_select;
// ==================================
//// Wire Assignments
// ==================================
assign load_select[0]  = (addr == 2'b00 && cs) ? 1 : 0;
assign load_select[1]  = (addr == 2'b01 && cs) ? 1 : 0;
assign load_select[2]  = (addr == 2'b10 && cs) ? 1 : 0;
assign load_select[3]  = (addr == 2'b11 && cs) ? 1 : 0;
// ==================================
//// Modules
// ==================================
ServoModule U0(
    .clk(clk),
    .rst(rst),
    .load(load_select[0]),
    .data(data),
    .signal(signal[0])
);
ServoModule U1(
    .clk(clk),
    .rst(rst),
    .load(load_select[1]),
    .data(data),
    .signal(signal[1])
);
ServoModule U2(
    .clk(clk),
    .rst(rst),
    .load(load_select[2]),
    .data(data),
    .signal(signal[2])
);
ServoModule U3(
    .clk(clk),
    .rst(rst),
    .load(load_select[3]),
    .data(data),
    .signal(signal[3])
);
// ==================================
//// Behavioral Block
// ==================================
endmodule