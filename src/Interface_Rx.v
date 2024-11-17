`timescale 1ns / 1ps

module Interface_Rx(
    input wire i_clk, i_reset,
    input wire [7:0] i_data,              // Byte recibido del receptor
    input wire i_reception_done,          // Señal que indica que la recepción ha terminado (ya se ha recibido el byte)
    input wire i_alu_result_ready,        // Señal que indica que la ALU ha terminado de realizar la operacion
    
    output wire [7:0] o_data_A,           // Operando A para la ALU
    output wire [7:0] o_data_B,           // Operando B para la ALU
    output wire [5:0] o_opcode,           // Opcode para la ALU
    output wire o_ready                   // Flag que ndica que la interfaz ha recibido todos los datos y por ende la ALU puede hacer la operacion
);

   // Estados de la maquina de estados
    localparam STATE_A = 2'b00;       //Alamcenar el operando A
    localparam STATE_B = 2'b01;       //Alamcenar el operando B
    localparam STATE_OPCODE = 2'b10;  //Alamcenar el codigo de operacion
    localparam STATE_READY = 2'b11;   //Espera a que la ALU termine la operacion y luego vuelve al Estado A para asi volver a esperar los siguientes datos para la siguiente operacion
   
    reg [1:0] state, next_state;                 // Estado Actual, Estado siguiente
    reg [7:0] buffer_A, buffer_B;                // Operando A,B actual
    reg [7:0] next_buffer_A, next_buffer_B;      // Operando A,B siguiente
    reg [5:0] buffer_opcode, next_opcode;        // CodOp actual, codOp siguiente
    reg ready_flag, next_ready_flag;             // Flag que de datos listos para la ALU Actual, Flag que de datos listos para la ALU Siguiente



//Maquina de estados


//Asignacion de los registros "actual"
    always @(posedge i_clk) begin
        if (i_reset) begin
            state      <= STATE_A;
            buffer_A   <= 8'b00000000;
            buffer_B   <= 8'b00000000;
            buffer_opcode <= 8'b00000000;
            ready_flag <= 1'b0;
        end
        else begin
            state <= next_state;
            buffer_A <= next_buffer_A;
            buffer_B <= next_buffer_B;
            buffer_opcode <= next_opcode;
            ready_flag <= next_ready_flag;
        end
    end
    
//Logica de cambio de estado y Asignacion de los registros "siguiente"
    always @(*) begin
        next_state = state;
        next_buffer_A = buffer_A;
        next_buffer_B = buffer_B;
        next_opcode = buffer_opcode;
        next_ready_flag = ready_flag;

        case (state)
            STATE_A: begin
                if (i_reception_done) begin
                    next_buffer_A = i_data;    // Almacenar operando A
                    next_state = STATE_B;
                end
            end

            STATE_B: begin
                if (i_reception_done) begin
                    next_buffer_B = i_data;    // Almacenar operando B
                    next_state = STATE_OPCODE;
                end
            end

            STATE_OPCODE: begin
                if (i_reception_done) begin
                    next_opcode = i_data[5:0]; // Almacenar opcode (6 bits)
                    next_state = STATE_READY;
                    next_ready_flag = 1'b1;    // Datos listos para la ALU
                end
            end

            STATE_READY: begin 
                if (i_alu_result_ready)  begin   
                    next_state = STATE_A;      // Volver a esperar los siguientes datos para la siguiente operacion
                    next_ready_flag = 1'b0;  
                 
                 end           
            end
            
            default:
            next_state = STATE_A;
            
        endcase
    end

    assign o_data_A = buffer_A;
    assign o_data_B = buffer_B;
    assign o_opcode = buffer_opcode;
    assign o_ready = ready_flag;

endmodule