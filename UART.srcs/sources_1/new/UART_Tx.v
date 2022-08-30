/*
	UART-Tx module for transmission of data.

	//Specificifications:
- reset_in is active high and asynchronous.
- Tx_counter starts from 1 to avoid adding a subtractor inside the circuit.
- done logic is in a separate state. For one clock cycle Tx_done is asserted then deasserts.
- Bits for stream: one stop bit, one odd parity bit, one start bit and 9 data bits
- Packet used is 12-bit intentionally
*/

module UART_Tx (
  
  input 				clock_in,
  input 				reset_in,
  input 				start_in,		//Starts UART module
  input 				tick_in,		//For baud rate
//  input					data_ready_in,	//Outside bus has data ready to transmit
//  input			[8:0]	data_in,		//Data from outside bus
//  input 		[3:0]	data_len_in,		//Length of data frame (can be 5 to 9 bits)
  
  output 				data_out,
  output reg			Tx_ready,
  output reg			Tx_done_out		//Data is transmitted. Also used as Tx_ready for input data
);
  parameter data_ready_in=1'b1;   //For sake of testing on FPGA, data is always ready because it is a parameter
  parameter data_in=9'b010101010; //For sake of testing on FPGA, input data is hardwired
  parameter data_len_in=4'd9;
  //Using One-hot encoding for simplicity (but creates relatively more hardware then binary encoding).
  parameter	idle		= 	6'b100000;
  parameter init		= 	6'b010000;
  parameter	get_data	=	6'b001000;
  parameter wait_tick	=	6'b000100;
  parameter serial_out	=	6'b000010;
  parameter done		= 	6'b000001;
  
  parameter stop_bit	=	1'b1;
  parameter parity_bit	=	1'b1;
  parameter start_bit	=	1'b0;
  
  wire		[11:0]	shift_data_register;
  
  //////////////
  //Flip Flops//
  //////////////
  reg       [32:0]  UART_string;
  reg		[11:0] 	data_register;
  reg		[3:0]	data_len;
  reg 		[3:0]	Tx_counter;
  reg 		[5:0]	current_state;
  reg 		[5:0]	next_state;
  
  ///////////////////
  //Control Signals//
  ///////////////////
  reg 				sig_start;
  reg 				sig_send;
  reg 				sig_shift;
  
  ///////////////////
  //Data Path wires//
  ///////////////////
  wire  [11:0]            data_register_wire1;
  wire  [11:0]            data_register_wire2;
  wire 				     EOS;
  wire  [3:0]            data_len_wire1;
  wire  [3:0]            Tx_counter_wire1;
  
  ///////////////////////
  //Flipflop Assignment//
  ///////////////////////
  
  always @ (posedge clock_in or posedge reset_in) begin
    if (reset_in) begin
      UART_string   <="This is UART\n";
      data_register <= 12'd0;
      data_len		<= 4'd0;
      Tx_counter	<= 4'd0;
    end
    else if (sig_start) begin //Machine in initialization state
      UART_string   <="This is UART\n";
      data_register <= data_register_wire2;
      data_len		<= data_len_wire1;
      Tx_counter	<= 4'd0;
    end
    else begin
      data_register <= data_register_wire1;
      Tx_counter	<= Tx_counter_wire1;
    end
  end
  /////////////////////
  //State Assignments//
  /////////////////////
  
  always @ (posedge clock_in or posedge reset_in)begin
    if (reset_in) 	current_state <= idle;
    else			current_state <= next_state;
  end
  
  ////////////////////
  //Next state logic//
  ////////////////////
  
  always @ (*) begin
    case (current_state)
      idle:begin
        if (start_in)		next_state = init;
        else 				next_state = idle;
      end
      init:begin
        if (data_ready_in)	next_state = get_data;
        else 				next_state = init;
      end
      get_data:begin
        					next_state = wait_tick;
      end
      wait_tick:begin
        if (EOS) 			next_state = done;
        else if (tick_in)	next_state = serial_out;
        else 				next_state = wait_tick;
      end
      serial_out:begin
        					next_state = wait_tick;
      end
      done:begin
        					next_state = idle;
      end
      default:				next_state=6'dx; //Erroneous state
    endcase
  end
  
  //////////////
  //Controller//
  //////////////
  
  always @ (*) begin
    case (current_state)
      idle:begin
        Tx_done_out	=	1'b0;
        Tx_ready	=	1'b1;
        sig_start	=	1'b0;
        sig_shift	=	1'b0;
        sig_send	=	1'b0;
      end
      init:begin
        Tx_done_out	=	1'b0;
        Tx_ready	=	1'b0;
        sig_start	=	1'b1;
        sig_shift	=	1'b0;
        sig_send	=	1'b0;
      end
      get_data:begin
        Tx_done_out	=	1'b0;
        Tx_ready	=	1'b0;
        sig_start	=	1'b0;
        sig_shift	=	1'b0;
        sig_send	=	1'b0;
      end
      wait_tick:begin
        Tx_done_out	=	1'b0;
        Tx_ready	=	1'b0;
        sig_start	=	1'b0;
        sig_shift	=	1'b0;
        sig_send	=	1'b0;
      end
      serial_out:begin
        Tx_done_out	=	1'b0;
        Tx_ready	=	1'b0;
        sig_start	=	1'b0;
        sig_shift	=	1'b1;
        sig_send	=	1'b1;
      end
      done:begin
        Tx_done_out	=	1'b1;
        Tx_ready	=	1'b0;
        sig_start	=	1'b0;
        sig_shift	=	1'b0;
        sig_send	=	1'b0;
      end
      default:begin				//Error State
        Tx_done_out	=	1'bx;
        Tx_ready	=	1'bx;
        sig_start	=	1'bx;
        sig_shift	=	1'bx;
        sig_send	=	1'bx;
      end
    endcase
  end
  
  ////////////
  //Datapath//
  ////////////
  
  
  //data_register
  assign shift_data_register 	=	(data_register >> 1'b1);
  assign data_register_wire1 	= 	sig_shift?shift_data_register:data_register;
  assign data_register_wire2 	= 	data_ready_in?{stop_bit,parity_bit,data_in,start_bit}:data_register;
  
  //data_length
  assign data_len_wire1			=	data_len_in+2'd3;
  
  //Tx_counter
  assign Tx_counter_wire1		=	sig_shift?(Tx_counter+1):Tx_counter;
  
  //output logic
  assign data_out				=	sig_send?data_register[0]:1'b1;
  
  //comparator logic
  assign EOS					=	(Tx_counter == data_len);
endmodule