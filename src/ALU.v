`timescale 1ns / 1ps

// Definici�n del m�dulo ALU con puertos de entrada y salida
module ALU#(parameter DATA_SIZE = 8)(
    
    input [7:0] i_OperandoA,
    input [7:0] i_OperandoB,
    input  [5:0] i_opcode,
    input i_clk, i_reset,                           // Entrada reloj  y reset
    input i_start,                          // Flag que indica si la interfaz ya tiene los 3 datos para leer
  
    output [DATA_SIZE - 1 : 0] o_output,    // Salida de 8 bits que contendr� el resultado
    output o_alu_result_ready                     // Flag que indica que la ALU ya ha le�do todo el contenido del buffer de la Interfaz_Rx
  
);
    localparam SRL      =   6'b101000;   // Right Shift i_B shamt (insertando ceros) L de logic
    localparam SRA      =   6'b100111;   // Right Shift i_B shamt (Aritmetico, conservando el sig)
    localparam ADD      =   6'b100000;
    localparam SUBU     =   6'b100010;   // rs - rt (signed obvio)
    localparam AND      =   6'b100100; 
    localparam OR       =   6'b100101; 
    localparam XOR      =   6'b100110; 
    localparam NOR      =   6'b101001;

   reg[DATA_SIZE : 0] reg_resultado; // Se almacena el resultado

   reg alu_result_ready;
    
    always @(*) begin    // La ALU solo calcula cuando se recibe que buffer de la Interfaz_Rx no est� vac�o (Lo cual se representa con "i_rx_empty == 0")
       
     alu_result_ready = 1'b0; 
    
    if(i_start) begin 
    
	 case (i_opcode)
                SRL  : reg_resultado    = i_OperandoB  >>  i_OperandoA;
                SRA  : reg_resultado    = $signed(i_OperandoB) >>>  i_OperandoA;
                ADD  : reg_resultado    = $signed (i_OperandoA) + $signed (i_OperandoB);
                SUBU : reg_resultado    = $signed (i_OperandoA) - $signed (i_OperandoB);
                AND  : reg_resultado    =  i_OperandoA & i_OperandoB;
                OR   : reg_resultado    =  i_OperandoA | i_OperandoB;
                XOR  : reg_resultado    =  i_OperandoA ^ i_OperandoB;
                NOR  : reg_resultado    = ~(i_OperandoA | i_OperandoB);
                default: reg_resultado   = {DATA_SIZE{1'b1}};
            
	    endcase
	    
	
            alu_result_ready = 1'b1;
            
        end
    end
    
    assign o_alu_result_ready = alu_result_ready;
    assign o_output = reg_resultado;
    
endmodule