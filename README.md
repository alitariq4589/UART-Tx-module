# UART-Tx-module
This is the UART Tx protocol. Currently it does not have Rx in it but will be (possibly) included in future.

The project is not yet tested on the FPGA, but the bitstream for Arty A7 100tcsg324-2 is generated and synthesis gives no error so far. Baud rate is configured to be 9600 (9615.384615385 to be specific, because fractional clock divisor not implemented). The pinout for Arty A7 100tcs324-2 FPGA is as follows:
 				clock: 		E3  
 				data_out: G13  
 				reset:		D9  
 				start:		C9  
 				Tx_done:	H5  
 				Tx_ready:	J5  
One may find other important details in the project comments
