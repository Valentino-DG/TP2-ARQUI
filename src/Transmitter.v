`timescale 1ns / 1ps

module Transmitter(
        input wire i_clk, i_reset,
        input wire i_tx_start, i_tickSignal,
        input wire [7:0] i_received_data_tx,    //Recibe el dato entero, que luego debe ir transmitiendo bit a bit
        output wire o_transmission_done,
        output wire o_transmitted_data_tx
    );
    
    localparam idle = 2'b00;
    localparam start = 2'b01;
    localparam data = 2'b10;
    localparam stop = 2'b11;
    
    reg [1:0] state, next_state;                // Registros para el estado actual y siguiente
    reg [2:0] bit_counter, next_bit_counter;    // Contadores de la cantidad de bits recibidos en la etapa data (cuenta hasta 7)
    reg [3:0] tick_counter, next_tick_counter;  // Contadores que almacenan la iteración de la cantidad de ticks de la señal de muestreo (i_tickSignal) recibido del Baud Generator (cuenta hasta 15)
    reg [7:0] data_reg, next_data_reg;          // Registros que almacenan los datos que se van recibiendo de la señal tx
    reg tx_reg, tx_next;                        // Registro que va almacenando la data transmitida de a 1 bit a la vez
    reg transmission_done, transmission_done_next;
    
    always@(posedge i_clk, posedge i_reset)
        begin
            if (i_reset) begin
                // Reseteamos los registros actuales
                state <= 2'b0;
                bit_counter <= 3'b0;
                tick_counter <= 4'b0;
                data_reg <= 8'b0;
                tx_reg <= 1'b0;
                transmission_done <= 1'b0;
                 
                          
            end
            else begin
                state <= next_state;
                bit_counter <= next_bit_counter;
                tick_counter <= next_tick_counter;
                data_reg <= next_data_reg;
                tx_reg <= tx_next;
                transmission_done <= transmission_done_next;
            end
        end
        
        always@*
            begin
                next_state = state;
                next_data_reg = data_reg;
                next_bit_counter = bit_counter;
                next_tick_counter = tick_counter;
                transmission_done_next = 1'b0;
                
                case(state)
                    idle:
                        begin
                            tx_next = 1'b1;                         //Prepara la trama para que arranque en 1 (ya que el bit de start es un 0)
                            if(i_tx_start) begin
                                next_state = start;
                                transmission_done_next = 1'b0;
                                next_tick_counter = 4'b0;        // Seteamos el contador de bits en 0
                                next_data_reg = i_received_data_tx; // Almacenamos en el registro interno la data recibida
                            end
                        end
                        
                     start:
                        begin
                            tx_next = 1'b0;                         // Indicamos que comienza la transmisión con el bit de start
                            if(i_tickSignal) begin
                                if(tick_counter == 15) begin
                                    next_state = data;
                                    next_tick_counter = 4'b0;
                                    next_bit_counter = 3'b0;
                                end
                                else begin
                                    next_tick_counter = tick_counter + 1;
                                end
                            end
                        end
                     
                     data:
                        begin
                            tx_next = data_reg[0];                      // El transmisor transmitirá el primer bit del registro que almacenó la palabra que debe transmitir 
                            if(i_tickSignal) begin
                                if(tick_counter == 15) begin
                                    next_tick_counter = 4'b0;
                                    next_data_reg = data_reg >> 1;      // Cuando el contador llega a 15, es cuando terminamos de transmitir el bit. Al hacerlo, hacemos un shift para "eliminar" el bit transmitido, dejando en la posición "0" el próximo bit a transmitir.
                                    
                                    if(bit_counter == 7) begin
                                        next_state = stop;
                                    end
                                    else begin
                                        next_bit_counter = bit_counter + 1;
                                    end 
                                end
                                else begin
                                    next_tick_counter = tick_counter + 1;
                                end
                            end                           
                        end
                
                    stop:
                        begin
                            tx_next = 1'b1;         // Indicamos el bit de STOP
                            if(i_tickSignal) begin
                                if (tick_counter == 15) begin
                                    next_state = idle;
                                    next_tick_counter = 4'b0;
                                    transmission_done_next = 1'b1;
                                end   
                                else begin
                                    next_tick_counter = tick_counter + 1;
                                end                               
                            end 
                        end
                        
                    default: 
                    next_state = idle; 
                endcase
            end // Fin bloque ALWAYS
    
    assign o_transmitted_data_tx = tx_reg; // La salida del transmisor será el registro local que almacena la data transmitida de a 1 bit a la vez
    assign o_transmission_done = transmission_done;
    
endmodule
