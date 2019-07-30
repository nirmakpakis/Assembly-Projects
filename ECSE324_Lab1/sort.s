			.text
			.global _start	

// This program runs the insertion sort algorithm
_start:		LDR R1, =ZERO     	//store address of ZERO
					LDR R0, [R1, #4]		//R0 stores the outer loop size of array 
					LDR R2, [R1, #4]  	//R2 stores the size of the current array for finding MIN
					ADD R3, R1, #8    	//R3 - pointer to loop through unsorted array
					LDR R4, [R3]				//R4 - holds value of first element, used to hold min in LOOP_MIN
					ADD R6, R1, #8			//R6 - address of first element
					ADD R7, R1, #8			//R7 - address of first element


LOOP_MIN:	SUBS R2, R2, #1			//decrements counter
					BEQ LOOP_SORT				//found min, sort it
					LDR R5, [R3, #4]		//R5 - holds next element to compare
					ADD R3, R3, #4			//Increment R3 pointer
					CMP R5, R4					//Is R5(next value) greater than saved min(R4)
					BGE LOOP_MIN				//If yes loop, we already have min
					ADD R6, R3, #0			//If no, save address of where R5 is in actual memory to swap if its actual min
					MOV R4, R5					//R5 value now new min stored in R4
					B LOOP_MIN					//loop

// r4 returns the min
LOOP_SORT:   
					LDR R8, [R7] 				//Take value of first element store in R8
					STR R4, [R7]				//Store min of unsorted in address at first
					STR R8, [R6]				//Store value of first in unsorted, into location R6 where min is located
					ADD R7, R7, #4			//Increment start of unsorted list
					ADD R3, R7, #0			//Resets new first unsorted value for next LOOP_MIN call
					MOV R6, R3					
					LDR R4, [R3]				//R4 holds first value of unsorted array
					SUBS R0, R0, #1 		//Decrements size of unsorted array
					CMP R0, #1					//If there is one element left its sorted
					BEQ END				
					MOV R2, R0					//Otherwise, reset LOOP_MIN counter to new number of values
					B LOOP_MIN					//Find min of next unsorted array
			

END:			B END


ZERO:			.word	0
N:				.word 8
NUMBERS:	.word 5, 2, 1, 6
					.word	7, 16, 3, 9
