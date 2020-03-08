# vDE0 Summary

## Registers

$00 - CR
  - Control register
  - Set graphics mode, memory autoincrement
  
$01 - DATA
  - Data to be read from or written to internal memory
  
$02 - ADDRL
  - Low memory address byte
  - Incremented by AUTOINC value
  
$03 - ADDRH
  - High memory address byte
  - Incremented when ADDRL overflows
  

### Control Register
GM2 GM1 GM0 AI3 AI2 AI1 AI0 EN
 - GM2-0 Selects graphics mode
   * 0 is standard text
   * More modes to be added
 
 - AI3-0 Sets auto increment value
   * Always added to ADDRL after every read or write operation
   
 - EN Enables or disables the display
   * 0 will turn off display