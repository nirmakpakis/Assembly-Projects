			.text
			.equ HEX_BASE_1, 0xFF200020
			.equ HEX_BASE_2, 0xFF200030
			.global HEX_clear_ASM
			.global HEX_flood_ASM
			.global HEX_write_ASM


////////SUBROUTINE 1////////
HEX_clear_ASM:  //(HEX_t hex) - hex in R0
			PUSH {R1-R5}
			//check HEX0-HEX3
			MOV R3, #1					//going to use R3 to TST each bit of arg passed in
			MOV R4, #0x00				//used to empty the display
			MOV R5, #7
			LDR R1, =HEX_BASE_1
			LDR R2, =HEX_BASE_2
CHECK_0_3:	
			SUBS R5, R5, #1
			CMP R5, #2
			BEQ CHECK_4_5
			TST R0, R3					//R0 is arg passed in
			LSL R3, R3, #1			//shift the bit by one
			BEQ JUMP
			STRB R4, [R1], #1 	//if not equal to zero, then clear display, inc after
			B CHECK_0_3
JUMP:	ADD R1, R1, #1			//else just shift pointer by one byte
			B CHECK_0_3
CHECK_4_5:
			//check HEX4 and HEX5			
			TST R0, R3
			LSL R3, R3, #1
			BEQ JUMP1
			STRB R4, [R2]
JUMP1:
			TST R0, R3
			BEQ JUMP2
			STRB R4, [R2, #1]
JUMP2:
			POP {R1-R5}
			BX LR
			



////////SUBROUTINE 2////////
HEX_flood_ASM:	//(HEX_t hex) - hex in R0
			PUSH {R1-R5}
			//check HEX0-HEX3
			MOV R3, #1					//going to use R3 to TST each bit of arg passed in
			MOV R4, #0x7F				//store R4 with 111111 in bin
			MOV R5, #7
			LDR R1, =HEX_BASE_1
			LDR R2, =HEX_BASE_2
LOOP:	SUBS R5, R5, #1
			CMP R5, #2
			BEQ LOOP2
			TST R0, R3					//R0 is arg passed in
			LSL R3, R3, #1			//shift the bit by one
			BEQ SKIP
			STRB R4, [R1], #1 	//if not equal to zero, then flood this display with byte of R4, increment R1 after
			B LOOP
SKIP:	ADD R1, R1, #1			//else just shift pointer by one byte
			B LOOP
LOOP2:
			//check HEX4 and HEX5			
			TST R0, R3
			LSL R3, R3, #1
			BEQ SKIP2
			STRB R4, [R2]
SKIP2:
			TST R0, R3
			BEQ SKIP3
			STRB R4, [R2, #1]
SKIP3:
			POP {R1-R5}
			BX LR
			

////////SUBROUTINE 3////////
HEX_write_ASM:		//(HEX_t hex, char val) - assuming hex in R0, val in R1
			PUSH {R2-R5}
			MOV R3, #1					//going to use R3 to TST each bit of arg passed in
			MOV R5, #5
			LDR R4, =HEX_BASE_1
LOOP_W:	
			SUBS R5, R5, #1
			BEQ DONE
			TST R0, R3					//R0 is arg passed in
			LSL R3, R3, #1			//shift the bit by one
			BEQ SKIP_W
			STRB R1, [R4], #1 	//if not equal to zero, then flood this display with byte of R4, increment R1 after
			B LOOP_W
SKIP_W:	
			ADD R4, R4, #1			//else just shift pointer by one byte
			B LOOP_W
DONE:	POP {R2-R5}
			//clear pushbutton
			BX LR



			.end

