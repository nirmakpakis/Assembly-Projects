	.text
	
	.global A9_PRIV_TIM_ISR
	.global HPS_GPIO1_ISR
	.global HPS_TIM0_ISR
	.global HPS_TIM1_ISR
	.global HPS_TIM2_ISR
	.global HPS_TIM3_ISR
	.global FPGA_INTERVAL_TIM_ISR
	.global FPGA_PB_KEYS_ISR
	.global FPGA_Audio_ISR
	.global FPGA_PS2_ISR
	.global FPGA_JTAG_ISR
	.global FPGA_IrDA_ISR
	.global FPGA_JP1_ISR
	.global FPGA_JP2_ISR
	.global FPGA_PS2_DUAL_ISR
	.global hps_tim0_int_flag
	.global key_pressed_number
	
	
key_pressed_number: .word 0
hps_tim0_int_flag: 	.word 0x0

A9_PRIV_TIM_ISR:
	BX LR
	
HPS_GPIO1_ISR:
	BX LR
	
	
	
	
	
	
	
HPS_TIM0_ISR:			//need to write this one
	PUSH {LR}
	
	MOV R0, #0x1
	BL HPS_TIM_clear_INT_ASM		//this sets F/S bit to 0, so that when it becomes 1 again it sends interupt 
	
	LDR R0, =hps_tim0_int_flag
	MOV R1, #1
	STR R1, [R0]
	
	POP {LR}
	BX LR
	
	
	
	
	
	
	
	
HPS_TIM1_ISR:
	BX LR
	
HPS_TIM2_ISR:
	BX LR
	
HPS_TIM3_ISR:
	BX LR
	
FPGA_INTERVAL_TIM_ISR:
	BX LR
	
	
	
	
	
FPGA_PB_KEYS_ISR:   //need to write this one 
	LDR R0, =0xFF200050 // base address of KEYs
	LDR R1, [R0, #0xC] // read edge capture register
	STR R1, [R0, #0xC] // clear the interrupt
	LDR R0, =key_pressed_number // global variable to return the result
CHECK_KEY1:
	MOVS R3, #0x2
	ANDS R3, R1 // check for KEY1
	BEQ CHECK_KEY2
	MOVS R2, #1
	STR R2, [R0] // return KEY1 value
	B END_KEY_ISR
CHECK_KEY2:
	MOVS R3, #0x4
	ANDS R3, R1 // check for KEY2
	BEQ IS_KEY3
	MOVS R2, #2
	STR R2, [R0] // return KEY2 value
	B END_KEY_ISR
IS_KEY3:
	MOVS R2, #3
	STR R2, [R0] // return KEY3 value
END_KEY_ISR:
	BX LR
	
	
	
	
	
	
	
FPGA_Audio_ISR:
	BX LR
	
FPGA_PS2_ISR:
	BX LR
	
FPGA_JTAG_ISR:
	BX LR
	
FPGA_IrDA_ISR:
	BX LR
	
FPGA_JP1_ISR:
	BX LR
	
FPGA_JP2_ISR:
	BX LR
	
FPGA_PS2_DUAL_ISR:
	BX LR
	
	.end
