      .text
      .equ PB_BASE, 0xFF200050 
      .equ PB_BASE_EDGE, 0xFF20005C 
      .global read_PB_data_ASM
      .global read_PB_edgecap_ASM
      .global CONFIG_KEYS_ASM
	    .global clear_PB_data_ASM

read_PB_data_ASM: //returns int of data
      MOV R2, #0xF
      LDR R1, =PB_BASE
      LDR R0, [R1]
      AND R0, R0, R2    //make sure only first 4 are used
      BX LR
        
read_PB_edgecap_ASM:
      MOV R2, #0xF
      LDR R1, =PB_BASE_EDGE
      LDR R0, [R1]
      AND R0, R0, R2    //make sure only first 4 are used
      BX LR
      
CONFIG_KEYS_ASM: //code taken from manual, configures keys so they hardware generates interupts 
      LDR R0, =0xFF200050 // pushbutton key base address
      MOV R1, #0xF // set interrupt mask bits
      STR R1, [R0, #0x8] // interrupt mask register is (base + 8)
      BX LR


clear_PB_data_ASM:
	  MOV R2, #0x0
    LDR R1, =PB_BASE
    STR R2, [R1]
	  BX LR
      
      .end	
