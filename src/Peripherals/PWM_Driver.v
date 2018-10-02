`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  SJSU
// Engineer: Colin Schardt
// 
// Create Date: 07/10/2018 07:06:16 PM
// Design Name: 
// Module Name: PWM_Driver
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


module PWM_Driver #(
    parameter INPUT_WIDTH = 8,
    parameter DATA_WIDTH = 16
    )(
    input wire sys_clk,
    input wire reset,
    input wire load,
    input wire [DATA_WIDTH  - 1:0] data,
    output reg signal
);
// ==================================
//// Internal Parameter Field
// ==================================
// ==================================
//// Registers
// ==================================
reg [INPUT_WIDTH - 1:0] duty_counter;
reg [INPUT_WIDTH - 1:0] duty_compare_value;
// ==================================
//// Wires
// ==================================
wire [INPUT_WIDTH - 1:0] duty;
wire [INPUT_WIDTH - 1:0] period;
wire pwm_clk;
// ==================================
//// Wire Assignments
// ==================================
assign period = data[7:0];
assign duty = data[15:8];
// ==================================
//// Modules
// ==================================
VARIABLE_CLOCK_GENERATOR CLOCK1 (.DIVIDEND(period), .rst(reset), .fast_clk(sys_clk), .slow_clk(pwm_clk));
// ==================================
//// Behavioral Block
// ==================================
initial duty_counter <= 0;
initial signal <= 0;
initial duty_compare_value <=0;
    
always @(posedge pwm_clk or posedge reset or posedge load) begin
// Reset values
    if (reset) begin
        duty_counter = 0;
        signal = 0;
        duty_compare_value = 0;
    end
// load values into internal registers
    else if (load) begin                                 
        duty_compare_value = duty;        
    end
    else begin
// turn the signal on when counter resets
        if (duty_counter >= 255) begin
            signal = 1;
            duty_counter = 0;
        end
// turn the signal off when counter passes duty cycle value
        else if (duty_counter >= duty_compare_value)
            signal = 0;
        duty_counter = duty_counter + 1;
    end
end
endmodule

module VARIABLE_CLOCK_GENERATOR #(DIVISOR = 2)
(
    input wire [7:0] DIVIDEND,
    input wire rst,
    input wire fast_clk,
    output reg slow_clk
);

reg [31:0] counter = 0;
reg [8:0] DIV_REG;
always @(posedge fast_clk or posedge rst)
begin
    if(rst)
    begin
        slow_clk <= 0;
        counter <= 0;
    end
    else
    begin
        DIV_REG <= DIVIDEND + 2;
        if(counter == DIV_REG/2)
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