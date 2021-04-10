# VHDL-Implementation-of-UART

UART stands for Universal Asynchronous Receiver/Transmitter.

UART data is organized into packets. Each packet contains 1 start bit, 5 to 9 data bits (depending on the UART), an optional parity bit, and 1 or 2 stop bits: 

**Example Timing Diagram:**

![Uart Timing Diagram](https://developer.electricimp.com/sites/default/files/attachments/images/uart/uart3.png).

**This design includes 1 start bit, 8 data bits and 1 stop bits.It was created with the Time-Fined State Machine structure using VHDL.**
