    `timescale 1ns / 1ps
    //////////////////////////////////////////////////////////////////////////////////
    // Company: 
    // Engineer: 
    // 
    // Create Date: 08/30/2022 12:55:30 PM
    // Design Name: 
    // Module Name: clock_divider
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
    
    
    module clock_divider(
        input reset_in,
        input clock_in,
        output clock_out
    );
        reg [1:0] divisor;
        assign clock_out=(divisor==2'b01);
        always @(posedge clock_in) begin
            if (reset_in)           divisor<=2'b00;
            else if (divisor==1'b1) divisor<=2'b00;
            else                    divisor<=divisor+1;
        end
    endmodule
