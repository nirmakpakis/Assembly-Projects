	.text
	.equ   HPS_TIM0_BASE, 0xFFC08000
	.equ   HPS_TIM1_BASE, 0xFFC09000
	.equ   HPS_TIM2_BASE, 0xFFD00000
	.equ   HPS_TIM3_BASE, 0xFFD01000
	
	.global HPS_TIM_config_ASM
	.global HPS_TIM_clear_INT_ASM
	.global HPS_TIM_read_INT_ASM


//when we configure the HPS timer, we first set E to 0
HPS_TIM_config_ASM:
	PUSH {R4-R7, LR}
	MOV R1, #0
	MOV R2, #1
	LDR R7, [R0]		//struct pointer arg passed into R0, you get first value into R7
									//i.e. you get one shot encoding of TIM 
	B LOOP

LOOP:
	TST R7, R2, LSL R1
	BEQ CONTINUE
	BL CONFIG

CONTINUE:
	ADD R1, R1, #1
	CMP R1, #4
	BLT LOOP

DONE:
	POP {R4-R7, LR}
	BX LR


CONFIG:
	PUSH {LR}
	
	LDR R3, =HPS_TIM_BASE			//standard take this add every time
	LDR R4, [R3, R1, LSL #2]	//shift so you start at beginning of HPS timer,
														//this works cause you times by 4, where you go to next in array defined at bottom
														
	BL DISABLE								// 1. disable E bit in control, store control register in R5
	BL SET_LOAD_VAL						// 2. takes timeout, multiplys by 25 or 100 (depend on HPS numb), puts result in Load R
	BL SET_LOAD_BIT
	BL SET_INT_BIT
	BL SET_EN_BIT
	
	POP {LR}
	BX LR 

DISABLE:
	LDR R5, [R4, #0x8]				//take 3rd register
	AND R5, R5, #0xFFFFFFFE		//disable the E (1st bit)
	STR R5, [R4, #0x8]				//store control reg in R5
	BX LR
	
SET_LOAD_VAL:
	LDR R5, [R0, #0x4]				//load int timeout from struct
	MOV R6, #25								
	MUL R5, R5, R6						//multiply timeout by 25, store in R5
	CMP R1, #2								//if its HPS 1 or 2 (i.e. not 3 or 4) then its the 100MHz not 25MHz
	LSLLT R5, R5, #2					//so if less than multiply by 4
	STR R5, [R4]							//store this result in Load register of HPS timer 
	BX LR
	
SET_LOAD_BIT:
	LDR R5, [R4, #0x8]				//get load register from HPS
	LDR R6, [R0, #0x8]				//get load bit from struct
	AND R5, R5, #0xFFFFFFFD		//bit clear the second bit from load register i.e. M 
	ORR R5, R5, R6, LSL #1		//dont affect any other of load register, if load bit is enabled, then enable M 
	STR R5, [R4, #0x8]				//store it back in load register
	BX LR
	
SET_INT_BIT:
	LDR R5, [R4, #0x8]				//get load register
	LDR R6, [R0, #0xC]				//get INT_en
	EOR R6, R6, #0x00000001		//if INT_en is enabled -> it sets to 0 , if disabled -> it sets to 1
	AND R5, R5, #0xFFFFFFFB		//clear 3rd bit of load reg, i.e. the I
	ORR R5, R5, R6, LSL #2		
	STR R5, [R4, #0x8]
	BX LR
	
SET_EN_BIT:									//same as both above except for E
	LDR R5, [R4, #0x8]
	LDR R6, [R0, #0x10]
	AND R5, R5, #0xFFFFFFFE
	ORR R5, R5, R6
	STR R5, [R4, #0x8]
	BX LR






HPS_TIM_clear_INT_ASM:
	PUSH {LR}
	MOV R1, #0
	MOV R2, #1
	B CLEAR_INT_LOOP

CLEAR_INT_LOOP:
	TST R0, R2, LSL R1
	BEQ CLEAR_INT_CONTINUE
	BL CLEAR_INT

CLEAR_INT_CONTINUE:
	ADD R1, R1, #1
	CMP R1, #4
	BLT CLEAR_INT_LOOP
	B CLEAR_INT_DONE

CLEAR_INT_DONE:
	POP {LR}
	BX LR

CLEAR_INT:
	LDR R3, =HPS_TIM_BASE
	LDR R3, [R3, R1, LSL #2]
	LDR R3, [R3, #0xC]
	BX LR
	
	

HPS_TIM_read_INT_ASM:
	PUSH {LR}
	PUSH {R4}
	MOV R1, #0
	MOV R2, #1
	MOV R4, #0
	B READ_INT_LOOP

READ_INT_LOOP:
	TST R0, R2, LSL R1
	BEQ READ_INT_CONTINUE
	BL READ_INT

READ_INT_CONTINUE:
	ADD R1, R1, #1
	CMP R1, #4
	BEQ READ_INT_DONE
	LSL R4, R4, #1
	B READ_INT_LOOP
	
READ_INT_DONE:
	MOV R0, R4
	POP {R4}
	POP {LR}
	BX LR

READ_INT:
	LDR R3, =HPS_TIM_BASE
	LDR R3, [R3, R1, LSL #2]
	LDR R3, [R3, #0x10]					//read the interupt register
	AND R3, R3, #0x1							//clears all bits except the one we want to inspect
	EOR R4, R4, R3							//EOR will keep the previous S-bit values read to be the same since comparing
															//with all zeros except first bit
															//if S-bit is 1, it adds 1 to return value for that TIM, if 0 then returns 0
	BX LR
	
HPS_TIM_BASE:
	.word 0xFFC08000, 0xFFC09000, 0xFFD00000, 0xFFD01000

	.end
