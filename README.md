# Arquitectura de Computadoras - Trabajo Práctico N.2

**Alumnos:**  
- Ulla, Juan Ignacio.  
- Di Giannantonio, Marco Valentino.

## 1. Enunciado

El trabajo consiste en diseñar e implementar un sistema UART completo (Universal Asynchronous Receiver-Transmitter) en lenguaje Verilog utilizando la IDE Vivado para una FPGA Basys 3. Este sistema permite realizar operaciones lógicas y aritméticas básicas mediante el uso de comunicación serial entre una computadora y la FPGA.

Las funcionalidades implementadas incluyen:
- Recepción de datos a través de UART.
- Procesamiento de los datos en una ALU (Unidad Aritmética Lógica).
- Transmisión del resultado de vuelta a la computadora.

## 2. Desarrollo

El sistema está compuesto por los siguientes módulos principales:
1. **Generador de Baudios (BaudGenerator):** Proporciona señales de sincronización necesarias para la comunicación UART.
2. **Receptor (Receiver):** Decodifica los datos recibidos a través de UART.
3. **Interfaz de Recepción (Interface_Rx):** Gestiona los datos recibidos y los prepara para su procesamiento en la ALU.
4. **ALU:** Realiza operaciones aritméticas y lógicas sobre los datos recibidos.
5. **Interfaz de Transmisión (Interface_Tx):** Gestiona el resultado de la ALU para su transmisión.
6. **Transmisor (Transmitter):** Envía el resultado a través de UART.
7. **Módulo Principal (Top_UART):** Integra todos los módulos y conecta los pines de la FPGA.
8. **Script Python:** Permite la comunicación entre la computadora y la FPGA.

El flujo del sistema es el siguiente:
1. **Recepción de datos:** La computadora envía dos operandos y un código de operación a través de UART.
2. **Procesamiento en la ALU:** La FPGA realiza la operación especificada por el código de operación.
3. **Transmisión del resultado:** La FPGA envía el resultado de vuelta a la computadora.

## 3. Módulos

### 3.1 BaudGenerator
Este módulo genera una señal de sincronización llamada "tick", que es utilizada por el receptor y el transmisor para asegurar que los datos sean muestreados y enviados a la frecuencia correcta. La señal "tick" se obtiene dividiendo la frecuencia del reloj principal de la FPGA (100 MHz) por un factor calculado en función del baud rate (19200) y el factor de sobremuestreo (16). Este proceso garantiza la transmisión y recepción de datos con precisión.

### 3.2 Receiver
El módulo receptor decodifica los datos recibidos a través de la señal UART serial. Implementa una máquina de estados finita con cuatro estados principales:
- **IDLE:** Espera el bit de inicio (start bit) para iniciar la recepción.
- **START:** Verifica el bit de inicio y sincroniza la recepción.
- **DATA:** Recibe los bits de datos uno por uno y los almacena en un registro.
- **STOP:** Valida el bit de parada (stop bit) y finaliza la recepción.
Cuando se completa la recepción de un byte, el módulo activa un indicador (`o_rx_done`) que señala a los módulos siguientes que los datos están disponibles.

### 3.3 Interface_Rx
Este módulo actúa como intermediario entre el receptor y la ALU. Su función principal es almacenar los datos recibidos (dos operandos y un código de operación) y activar una señal de "listo" (`o_ready`) una vez que todos los datos necesarios para la operación han sido recibidos. Utiliza una máquina de estados para gestionar el almacenamiento de:
- El operando A.
- El operando B.
- El código de operación.
Después de que la ALU procesa los datos, este módulo se resetea para esperar los próximos datos.

### 3.4 ALU
La ALU es el núcleo del sistema, responsable de realizar las operaciones lógicas y aritméticas especificadas por el código de operación (`i_opcode`). Admite las siguientes operaciones:
- **SRL:** Desplazamiento lógico a la derecha.
- **SRA:** Desplazamiento aritmético a la derecha.
- **ADD:** Suma.
- **SUBU:** Resta sin signo.
- **AND, OR, XOR, NOR:** Operaciones lógicas bit a bit.
La ALU recibe los operandos y el código de operación desde el módulo `Interface_Rx` y devuelve el resultado junto con una señal de "resultado listo" (`o_alu_result_ready`) que informa al sistema que puede transmitir el resultado.

### 3.5 Interface_Tx
Este módulo es responsable de gestionar el resultado de la ALU antes de enviarlo. Almacena el dato recibido de la ALU y lo prepara para la transmisión. Si el transmisor está ocupado, este módulo espera hasta que esté libre antes de enviar los datos (activa un indicador (`o_interface_tx_full`) para señalar al transmisor que los datos están listos).

### 3.6 Transmitter
El transmisor envía los datos serialmente a través del pin UART de la FPGA. Implementa una máquina de estados con los siguientes estados:
- **IDLE:** Espera la señal de inicio de transmisión.
- **START:** Envía el bit de inicio.
- **DATA:** Envía los bits del dato, uno por uno.
- **STOP:** Envía el bit de parada y regresa al estado IDLE.
Este módulo asegura que el dato se transmita correctamente, bit por bit, con la sincronización adecuada proporcionada por la señal "tick".

### 3.7 Top_UART
El módulo principal integra todos los bloques funcionales. Coordina el flujo de datos desde la recepción, pasando por el procesamiento en la ALU, hasta la transmisión. Además, conecta los pines de entrada y salida de la FPGA, asegurando la comunicación con la computadora a través del puerto UART.

### 3.8 Script Python
El script de Python funciona como una interfaz entre la computadora y la FPGA, permitiendo al usuario enviar los datos de entrada y recibir los resultados. Los pasos principales que realiza el script son:
1. Solicitar al usuario los dos operandos (A y B) en formato hexadecimal y la operación deseada (ADD, SUB, AND, OR, XOR, NOR, SRA, SRL).
2. Convertir la operación seleccionada en su correspondiente código de operación (`opcode`).
3. Enviar los datos (operando A, operando B, opcode) a la FPGA utilizando el puerto serial.
4. Leer el resultado transmitido desde la FPGA y mostrarlo al usuario en consola.

Este script utiliza la librería `pyserial` para establecer la comunicación con la FPGA a través del puerto UART y permite realizar múltiples operaciones en una sesión continua.

## 4. Conclusión

En este proyecto, se implementó un sistema de comunicación UART que permite realizar operaciones lógicas y aritméticas en una FPGA Basys 3. La integración de múltiples módulos, como el receptor, la ALU, el transmisor y el script de Python, demuestra una comprensión profunda de las arquitecturas reconfigurables y de la interacción entre hardware y software.

El sistema no solo es funcional sino también flexible, permitiendo expandir las operaciones soportadas y ajustar los parámetros de comunicación.

