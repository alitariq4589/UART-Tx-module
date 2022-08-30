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

module UART_Tx_test;
    reg 	    clock;
    reg         reset;
    reg         start;       //Starts UART module
    wire        tick;        //For baud rate
    reg         data_ready;  //Outside bus has data ready to transmit
//    reg [8:0]   data_in;        //Data from outside bus
    reg [3:0]   data_len;    //Length of data frame (can be 5 to 9 bits)
    
    reg [15:0]  baud_divisor; //For UART clock generator;
    
    wire        data_out;
    wire        Tx_ready;
    wire        Tx_done;        //Data is transmitted. Also used as Tx_ready for input data
    
    /////////////////////////
    //UART Instantiation//
    /////////////////////////
    UART UART_inst(
        .clock(clock),
        .reset(reset),
        .start(start),       //Starts UART module
        
        
        .data_out(data_out),
        .Tx_ready(Tx_ready),
        .Tx_done(Tx_done)       //Data is transmitted. Also used as Tx_ready for input data
    );
    
    ///////////////////
    //Clock generator//
    ///////////////////
    initial begin
        clock=1'b0;
        forever #10 clock=~clock; //Clock of 50MHz
    end
    
    initial begin
//        data_len=4'd9; //Length of data
//        data_in=9'b101010101;  //Frame will be {010101010111}
        baud_divisor=16'd325; //Baud divisor for 9600bps and 50MHz clock.
    end
    
    initial begin
        //Module Idle signals:
        reset=1'b1;
        start=1'b0;
//        data_ready=1'b0;
        
        
        //Module Active signals:
        #60 reset=1'b0;
        start=1'b1;
//        data_ready=1'b1;
        #20 start=1'b0;
    end
endmodule
