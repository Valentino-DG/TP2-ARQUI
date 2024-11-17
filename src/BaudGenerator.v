`timescale 1ns / 1ps

module BaudGenerator#(parameter BAUD_RATE = 19200,
                      parameter OVERSAMPLING_FACTOR = 16,
                      parameter CLOCK_FREQUENCY = 100000000)
(
        input i_clk,           
        input i_reset,
        
        output o_tickSignal   //señal de sobremuestreo
);
   localparam counter_max_value = CLOCK_FREQUENCY / (BAUD_RATE * OVERSAMPLING_FACTOR); // Para generar la señal de sobremuestreo (326 veces mas lenta que el clk))
    
    reg[8:0] counter; //Contador que cuenta hasta 326 (necesitamos 9 bits para eso) 
    
    assign o_tickSignal = (counter == counter_max_value);    //Cuando el contador llega al valor maximo, se pone en 1 la señal de sobremuestreo
    
    always @(posedge i_clk)
        begin
            if (i_reset)
                counter <= 0;
            else if (counter == counter_max_value) 
                counter <= 0;
			else
                counter <= counter + 1;
        end
    
endmodule
