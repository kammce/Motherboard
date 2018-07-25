`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: SJSU
// Engineer: Colin Schardt
// 
// Create Date: 07/16/2018 06:07:47 PM
// Design Name: 
// Module Name: PWM_Driver_tb
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


module Test_PWMDriver;
    
    parameter MAX_CYCLE = 'd1_000_000;

    reg clk_tb, rst_tb, load_tb;
    reg [7:0] duty0_tb, duty1_tb, duty2_tb, duty3_tb, duty4_tb;
    reg [7:0] period0_tb, period1_tb, period2_tb, period3_tb, period4_tb;
    wire signal0_tb, signal1_tb, signal2_tb, signal3_tb, signal4_tb, signal5_tb, signal6_tb, signal7_tb, signal8_tb, signal9_tb;
    wire signalA_tb, signalB_tb, signalC_tb, signalD_tb, signalE_tb, signalF_tb, signal10_tb, signal11_tb, signal12_tb; 
    wire signal13_tb, signal14_tb, signal15_tb, signal16_tb, signal17_tb, signal18_tb;
    
    PWM_Driver DUT0( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty0_tb, period0_tb}), .signal(signal0_tb));
    
    PWM_Driver DUT1( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty1_tb, period0_tb}), .signal(signal1_tb));
    
    PWM_Driver DUT2( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty2_tb, period0_tb}), .signal(signal2_tb));
    
    PWM_Driver DUT3( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty3_tb, period0_tb}), .signal(signal3_tb));
    
    PWM_Driver DUT4( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty4_tb, period0_tb}), .signal(signal4_tb));
    
    PWM_Driver DUT5( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty0_tb, period1_tb}), .signal(signal5_tb));
    
    PWM_Driver DUT6( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty1_tb, period1_tb}), .signal(signal6_tb));
    
    PWM_Driver DUT7( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty2_tb, period1_tb}), .signal(signal7_tb));
    
    PWM_Driver DUT8( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty3_tb, period1_tb}), .signal(signal8_tb));
    
    PWM_Driver DUT9( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty4_tb, period1_tb}), .signal(signal9_tb));
    
    PWM_Driver DUTA( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty0_tb, period2_tb}), .signal(signalA_tb));
    
    PWM_Driver DUTB( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty1_tb, period2_tb}), .signal(signalB_tb));
    
    PWM_Driver DUTC( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty2_tb, period2_tb}), .signal(signalC_tb));
    
    PWM_Driver DUTD( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty3_tb, period2_tb}), .signal(signalD_tb));
    
    PWM_Driver DUTE( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty4_tb, period2_tb}), .signal(signalE_tb));
    
    PWM_Driver DUTF( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty0_tb, period3_tb}), .signal(signalF_tb));
    
    PWM_Driver DUT10( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty1_tb, period3_tb}), .signal(signal10_tb));
    
    PWM_Driver DUT11( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty2_tb, period3_tb}), .signal(signal11_tb));
    
    PWM_Driver DUT12( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty3_tb, period3_tb}), .signal(signal12_tb));
    
    PWM_Driver DUT13( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty4_tb, period3_tb}), .signal(signal13_tb));
    
    PWM_Driver DUT14( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty0_tb, period4_tb}), .signal(signal14_tb));
        
    PWM_Driver DUT15( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty1_tb, period4_tb}), .signal(signal15_tb));
    
    PWM_Driver DUT16( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty2_tb, period4_tb}), .signal(signal16_tb));
       
    PWM_Driver DUT17( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty3_tb, period4_tb}), .signal(signal17_tb));
        
    PWM_Driver DUT18( .sys_clk(clk_tb), .reset(rst_tb), .load(load_tb), .data({duty4_tb, period4_tb}), .signal(signal18_tb));        
        
    task CLOCK;
        input [31:0] clk_count;
        integer i;
        begin
            for (i=0; i<clk_count; i=i+1) begin
                #1 clk_tb = 1;
                #1 clk_tb = 0;
            end
        end
    endtask

    initial begin
        duty0_tb = 8'd0;
        duty1_tb = 8'd64;
        duty2_tb = 8'd128;
        duty3_tb = 8'd191;
        duty4_tb = 8'd255;
        period0_tb = 8'd0;
        period1_tb = 8'd64;
        period2_tb = 8'd128;
        period3_tb = 8'd191;
        period4_tb = 8'd255;
        $display("PWM_Driver test start.\n");
        #5 rst_tb = 1;
        CLOCK(5);
        #5 rst_tb = 0;
        CLOCK(1);
        #5 load_tb = 1;
        CLOCK(5);
        #5 load_tb = 0;
        CLOCK(2);
        #5;
        CLOCK(MAX_CYCLE);

        $display("PWM_Driver test complete.\n");
        $finish;
    end    
endmodule