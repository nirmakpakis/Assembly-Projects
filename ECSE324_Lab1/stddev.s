							.text
							.global _start	

//Program to find the standard deviation
//we divide the difference of the MAX and MIN by 4
_start:
							LDR R4, =MAX
							LDR R5, =MIN
							LDR R6, [R5, #4]	//store size of list in R6
							LDR R7, [R5, #4]	//store size of list in R7
							ADD R3, R5, #8		//R3 points to start of list 
							ADD R8, R5, #8		//R8 also points to start of list
							LDR R0, [R3]			//R0 holds first value 
							LDR R9, [R3]			//R9 also holds first value for MIN

LOOP_MAX:			SUBS R6, R6, #1		//decrements number of values
							BEQ LOOP_MIN			//found max, go find min
							ADD R3, R3, #4		//R3 points to next value
							LDR R1, [R3]			//R1 holds second value
							CMP R0, R1				//is R0 larger than R1
							BGE LOOP_MAX			//if no loop
							MOV R0, R1				//if yes put R1 value into R0
							B LOOP_MAX				//loop


LOOP_MIN:			SUBS R7, R7, #1		//decrements number of values
							BEQ DONE					//found max, go find min
							ADD R8, R8, #4		//R3 points to next value
							LDR R1, [R8]			//R1 holds second value
							CMP R1, R9				//is R1 greater than R9
							BGE LOOP_MIN			//if yes loop
							MOV R9, R1				//if no put R1 value into R9
							B LOOP_MIN				//loop

DONE:					SUB R10, R0, R9
							LSR R10, R10, #2
							STR R10, [R4]

END:					B END

MAX:					.word	0
MIN:					.word	0
N:						.word 7
NUMBERS:			.word 0, 16, 3, 6
							.word	7, 10, 2
