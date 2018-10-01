`timescale 1ns / 1ps
`default_nettype none
 
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 08/09/2018
// Design Name:
// Module Name: Clock
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

module CLOCK_GENERATOR #(parameter DIVIDE = 2)
(
    input wire rst,
    input wire fast_clk,
    output reg slow_clk
);

reg [31:0] counter = 0;

always @(posedge fast_clk or posedge rst)
begin
    if(rst)
    begin
        slow_clk <= 0;
        counter <= 0;
    end
    else
    begin
        if(counter == DIVIDE/2)
        begin
            slow_clk <= ~slow_clk;
            counter <= 0;
        end
        else
        begin
            slow_clk <= slow_clk;
            counter <= counter + 1;
        end
    end
end

endmodule

module ONESHOT(
    input wire clk,
    input wire rst,
    input wire signal,
    output reg out
);

reg previously_high;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        out <= 0;
        previously_high <= 0;
    end
    else
    begin
        if(signal && !previously_high)
        begin
            out <= 1;
            previously_high <= 1;
        end
        else if(signal && previously_high)
        begin
            out <= 0;
            previously_high <= 1;
        end
        else
        begin
            out <= 0;
            previously_high <= 0;
        end
    end
end

endmodule

//////////////////////////////////
// External Signal Syncronizer
//////////////////////////////////

module Syncronizer #(
	parameter WIDTH = 1,
	parameter DEFAULT_DISABLED = 0
)
(
	input wire clk,
	input wire rst,
	input wire en,
	input wire [WIDTH-1:0] in,
	output reg [WIDTH-1:0] sync_out
);

always@(posedge clk)
begin
	if(en)
	begin
		sync_out = in;
	end
	else
	begin
		sync_out = DEFAULT_DISABLED;
	end
end

endmodule
