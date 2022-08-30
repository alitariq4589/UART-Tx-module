`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2022 10:35:15 PM
// Design Name: 
// Module Name: UART_clock
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


module UART_clock(
    input           clock_in,
    input           reset_in,
    input   [15:0]  baud_divisor_in,
    output          tick_out
);
    reg     [15:0]  baud_rate_reg;
    
    assign tick_out=(baud_rate_reg==baud_divisor_in);
    
    always @(posedge clock_in or posedge reset_in) begin
        if (reset_in)       baud_rate_reg   <=  16'd1;
        else if (tick_out)  baud_rate_reg   <=  16'd1;
        else                baud_rate_reg   <=  baud_rate_reg+1;
    end
endmodule