`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 11/27/2017 11:22:44 PM
// Design Name:
// Module Name: PulseCapture
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

module PulseCaptureTop(
	input wire clk,
	input wire rst,
	input wire ext_pulse,
	input wire switch,
	input wire select,
	input wire trigger,
	input wire int_clr,
	input wire oe,
	output wire [15:0] leds
);

wire 		pulse;
wire 		int;
wire [31:0] data;

assign pulse 			= (select) ? ext_pulse : switch;
assign leds[14:0] 	= (oe) ? data[31:17] : 0;
assign leds[15] 	= int;

pulseCapture U0 (
    .clk(clk),
    .rst(rst),
    .oe(oe), 			// output enable
    .trigger(trigger), 	// start a capture
    .ext_pulse(pulse),		// external pulse signal
    .int_clr(int_clr),		// interrupt flag clear signal
    .int(int), 		// interrupt flag when capture event occurs
    .data(data)
);

endmodule

module PulseCapture #(
  parameter BUS_WIDTH = 32
)(
    input wire clk,
    input wire rst,
    input wire oe,          // output enable
    input wire trigger, 	// start a capture
    input wire ext_pulse,   // external Pulse signal
    input wire int_clr,     // interrupt flag clear signal
    output reg int,         // interrupt flag when capture event occurs
    inout wire [BUS_WIDTH-1:0] data
);
// ==================================
//// Internal Parameter Field
// ==================================
parameter LOOKING_FOR_HIGH_LEVEL 	= 0;
parameter IS_HIGH_LEVEL 			= 1;
parameter CAPTURE_AND_HOLD 			= 2;
// ==================================
//// Registers
// ==================================
reg [BUS_WIDTH-1:0] out;
reg [BUS_WIDTH-1:0] counter;
reg [1:0] state;
// ==================================
//// Wires
// ==================================
// ==================================
//// Wire Assignments
// ==================================
assign data       = oe ? out : 32'bz;
// ==================================
//// Modules
// ==================================
// ==================================
//// Behavioral Block
// ==================================
always @(posedge clk or posedge rst)
begin
    if (rst)
    begin
        out 	= 0;
        counter = 0;
        state 	= CAPTURE_AND_HOLD;
        int 	= 0;
    end
    else if (trigger)
    begin
        // out     = 0;
        counter = 0;
        state   = LOOKING_FOR_HIGH_LEVEL;
        int     = 0;
    end
    else if (int_clr)
    begin
        int = 0;
    end
    else
    begin
        case(state)
            LOOKING_FOR_HIGH_LEVEL:
            begin
                if(ext_pulse)
                begin
                    state = IS_HIGH_LEVEL;
                end
            end
            IS_HIGH_LEVEL:
            begin
                counter = counter + 1;
                if(!ext_pulse)
                begin
                    state = CAPTURE_AND_HOLD;
                    out = counter;
                    int = 1;
                end
            end
        endcase
    end
end
endmodule
