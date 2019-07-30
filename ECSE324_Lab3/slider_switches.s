		.text
		.equ SW_BASE, 0xFF200040
		.global read_slider_switches_ASM
		.global read_slider_switches_7Seg_ASM
		.global read_slider_switches_clearHEX_ASM

//this function reads the data
//from location of slider switches, and 
//puts it into R0, then returns
//might need to save the data of R1 beforehand
read_slider_switches_ASM:
		LDR R1, =SW_BASE
		LDR R0, [R1]
		BX LR			


//returns 0 if switch9 inactive, 1 if active
read_slider_switches_clearHEX_ASM:
		MOV R2, #0x200
		LDR R1, =SW_BASE
		LDR R0, [R1]
		TST R0, R2
		MOVEQ R0, #0 	//if log and gives 0, switch not activated
		MOVNE R0, #1
		BX LR		
		
//this differs by returning only first 4 bits
read_slider_switches_7Seg_ASM:
		LDR R1, =SW_BASE
		LDR R0, [R1]
		AND R0, R0, #0x0F		//clears most significant 4 bits
		BX LR		
		
		
		
		.end
