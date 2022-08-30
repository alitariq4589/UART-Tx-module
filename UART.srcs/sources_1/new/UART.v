`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 08/27/2022 10:34:18 PM
// Design Name: 
// Module Name: UART_Tx_test
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

/*
//////////////////
//Specifications//
//////////////////

Clock is considered to be 50MHz
Baud Rate is considered to be 9600bps
Baud_divisor=clock/(Baud_rate*16)
Baud_divisor=325

*/

module UART(
    input 	    clock,
    input       reset,
    input       start,       //Starts UART module
    
    
    output        data_out,
    output        Tx_ready,
    output        Tx_done       //Data is transmitted. Also used as Tx_ready for input data
);
    wire tick;
    wire div_clock;
    parameter baud_divisor=16'd325;
    /////////////////////////
    //UART_Tx Instantiation//
    /////////////////////////
    UART_Tx UART_Tx_inst (
      
      .clock_in(div_clock),
      .reset_in(reset),
      .start_in(start),        //Starts UART module
      .tick_in(tick),        //For baud rate
      
      .data_out(data_out),
      .Tx_ready(Tx_ready),
      .Tx_done_out(Tx_done)        //Data is transmitted. Also used as Tx_ready for input data
    );
    
    ////////////////////////////
    //UART_clock Instantiation//
    ////////////////////////////
    UART_clock UART_clock_inst(
        .clock_in(div_clock),
        .reset_in(reset),
        .baud_divisor_in(baud_divisor),
        .tick_out(tick)
    );
    
    ///////////////////////////////
    //clock_divider Instantiation//
    ///////////////////////////////
    clock_divider clock_divider_inst (
        .reset_in(reset),
        .clock_in(clock),
        .clock_out(div_clock)
    );
endmodule