`timescale 1ns / 1ps

module Top_UART(
    input wire i_clk,          // Señal de reloj global
    input wire i_reset,        // Señal de reset global
    input wire i_rx,           // Señal serial de recepción 
    
    output wire o_tx,
    output wire [7:0] operando_A, operando_B
);
    wire tx_done, rx_done;
    wire [7:0] alu_out;
    wire [7:0] byte_to_transmit;
    wire tx_interface_buffer_full;
    wire tickSignal;
    wire [7:0] byte_recived;
    wire [5:0] opcode;
    wire alu_start;
    wire alu_result_ready;

    // Instancia del generador de baudios
    BaudGenerator u_baud_generator (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .o_tickSignal(tickSignal)     // Se�al de sincronizaci�n de ticks
    );
    
    // Instancia del receptor para encendido/apagado del LED
    Receiver u_rx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_rx(i_rx),           // Entrada del dato serial
        .i_tick(tickSignal),
        .o_rx_done(rx_done),
        .o_data_out(byte_recived)          // Salida del LED
    );
    
    // Instancia de la interfaz del receptor
    Interface_Rx u_interface_rx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_data(byte_recived),    // Datos desde el receptor
        .i_reception_done(rx_done),   // Indica que se complet� la recepci�n
        .i_alu_result_ready(alu_result_ready),      // Se�al de lectura por parte de la ALU
        .o_data_A(operando_A),        // Operando A para la ALU
        .o_data_B(operando_B),        // Operando B para la ALU
        .o_opcode(opcode),            // Opcode para la ALU
        .o_ready(alu_start)               // Se�al que indica que la interfaz est� lista
    );
    
    
    
       // Instancia de la ALU
    ALU u_alu (
        .i_OperandoA(operando_A),
        .i_OperandoB(operando_B),
        .i_opcode(opcode),
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_start(alu_start),              // Se�al de la interfaz que indica que los datos est�n listos
        .o_output(alu_out),        // Resultado de la ALU
        .o_alu_result_ready(alu_result_ready)             // Se�al para indicar que los datos fueron le�dos
    );
    
       
    // Instancia de la interfaz de transmisi�n
    Interface_Tx u_interface_tx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_data(alu_out),          // Datos desde la ALU
        .i_alu_result_ready(alu_result_ready),      // Se�al de habilitaci�n de escritura
        .i_transmission_done(tx_done), //Indica que la transmisi�n ha finalizado
        .o_data(byte_to_transmit),             // Datos listos para el transmisor
        .o_interface_tx_full(tx_interface_buffer_full)  //Se�al que indica que el buffer est� lleno
    );
    
    
      // Instancia del transmisor UART
    Transmitter u_tx (
        .i_clk(i_clk),
        .i_reset(i_reset),
        .i_tx_start(tx_interface_buffer_full),        // Iniciar transmisión cuando el buffer no esté lleno
        .i_tickSignal(tickSignal),    // Señal de tick para la sincronización
        .i_received_data_tx(byte_to_transmit), // Datos a transmitir
        .o_transmission_done(tx_done),// Indica que se completó la transmisión
        .o_transmitted_data_tx(o_tx)  // Señal serial de salida
    );

endmodule