`timescale 1ns / 1ps

module Interface_Tx(
        input wire i_clk, i_reset,
        input wire [7:0] i_data,           // Datos a ser enviados
        input wire i_transmission_done,    //Se�al de que la transmisi�n ha finalizado (recibida del transmisor)
        input wire i_alu_result_ready,            // Se�al para habilitar la escritura de nuevos datos desde la ALU
        
        output wire [7:0] o_data,          // Datos que ser�n enviados al transmisor
        output wire o_interface_tx_full     //flag que indica que los datos est�n listos para ser transmitidos
    );
    
    reg [7:0] buffer, buffer_next;
    reg tx_full_flag, tx_full_flag_next;
    
    always@(posedge i_clk) begin
        if(i_reset)begin
            buffer <= 0; 
            tx_full_flag <= 0;   
        end
        else
            buffer <= buffer_next;
            tx_full_flag <= tx_full_flag_next;
        end
    
//    end
    
    
    always@(*) begin
        buffer_next = buffer;
        tx_full_flag_next = tx_full_flag;
        
        if(i_transmission_done) begin
            tx_full_flag_next = 1'b0;           //Cuando la transmisi�n finaliza, limpiamos el flag
        end 
        
        // Escribimos datos nuevos cuando la se�al de escritura est� habilitada
       if(i_alu_result_ready) begin   //Si est� habilitada la escritura y el buffer EST� VAC�O
           if(~tx_full_flag)begin
            buffer_next = i_data;                 //Guardamos los datos de entrada en el buffer
            tx_full_flag_next = 1'b1;          //Marcamos que los datos est�n listos
           end
        end
         
        
     end
    
    // Salidas
    assign o_data = buffer;                     // Los datos que se escribir�n en el transmisor
    assign o_interface_tx_full = tx_full_flag;   // Indicador de que los datos est�n listos para ser enviados
    
endmodule