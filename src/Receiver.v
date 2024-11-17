`timescale 1ns / 1ps

module Receiver#(parameter IO_SIZE = 8, // Tamaño de los datos
                 parameter SB_TICK = 16 // ticks por simbolo
                 )
(
    input wire i_clk,
    input wire i_reset,
    input wire i_rx,        //Señal recibida por UART
    input wire i_tick,      //Tick signal
    
    output reg o_rx_done,   //Flag para indicar que la recepcion ha sido terminada
    output wire [IO_SIZE-1:0] o_data_out //Byte de datos recibidos

);


// Estados de la maquina de estados
localparam IDLE  = 2'b00;
localparam START = 2'b01;
localparam DATA  = 2'b10;
localparam STOP  = 2'b11;

reg [1:0] state, next_state;                //Estado actual, Estado siguiente
reg [3:0] ticks, next_ticks;                //Cantidad de ticks actual, Cantidad de ticks siguiente
reg [2:0] bits_rx, bits_rx_next;            //Cantidad de bits recibidos actual, Cantidad de bits recibidos siguiente
reg [IO_SIZE-1:0] byte_rx, byte_rx_next;    //Data recibida actual, Data recibida siguiente

//Maquina de estados


//Asignacion de los registros "actual"
always @(posedge i_clk) begin
    if (i_reset) begin
        state <= IDLE;
        ticks <= 0;
        bits_rx <= 0;
        byte_rx <= 0;
    end
    else begin
        state <= next_state;
        ticks <= next_ticks;
        bits_rx <= bits_rx_next;
        byte_rx <= byte_rx_next;
    end
end

//Logica de cambio de estado y Asignacion de los registros "siguiente"
always @(*) begin
    next_state = state;
    next_ticks = ticks;
    bits_rx_next = bits_rx;
    byte_rx_next = byte_rx;
    o_rx_done = 1'b0;

    case (state)
        IDLE:
            if (~i_rx) begin // Chequeo de bit de start
               next_state = START;
               next_ticks = 0; 
               o_rx_done = 1'b0;
            end
        
        START:
            if (i_tick) begin
                if (ticks == 7) begin
                    next_state = DATA;
                    next_ticks = 0;
                    bits_rx_next = 0;
                end
                else begin
                    next_ticks = ticks + 1;
                end
            end

        DATA:
            if (i_tick) begin
                if (ticks == SB_TICK-1) begin
                    next_ticks = 0;
                    byte_rx_next = {i_rx, byte_rx[IO_SIZE-1:1]}; 
                    if (bits_rx == (IO_SIZE-1)) begin
                        next_state = STOP;
                    end
                    else begin
                        bits_rx_next = bits_rx + 1;
                    end
                end
                else begin 
                    next_ticks = ticks + 1;
                end
            end
        
        STOP:
            if (i_tick) begin
                if (ticks == (SB_TICK-1)) begin
                    next_state = IDLE;
                    if(i_rx) begin
                        o_rx_done = 1'b1;
                    end
                end 
                else begin
                    next_ticks = ticks + 1;
                end
            end

        default: 
            next_state = IDLE;   
    endcase
end

assign o_data_out = byte_rx;

endmodule