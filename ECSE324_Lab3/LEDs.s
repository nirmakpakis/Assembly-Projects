			.text
			.equ LED_BASE, 0xFF200000 //need to add location of LEDs to read
			.global read_LEDs_ASM
			.global write_LEDs_ASM


read_LEDs_ASM:
			LDR R1, =LED_BASE
			LDR R0, [R1]
			BX LR


//store value of R0 into memory location
//guessing same one
write_LEDs_ASM:
			LDR R1, =LED_BASE
			STR R0, [R1]
			BX LR


			.end
