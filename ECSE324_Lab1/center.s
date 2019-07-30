						.text
						.global _start	

//This program centers a signal by taking the 
//average of the samples in a signal and 
//subtracting the average from every value
_start:
						LDR R0, =NUMBERS		//R0 points to start of list
						LDR R1, [R0, #-8]		//load with 0
						LDR R7, [R0,#-4]		//R7 stores size of signal
						LDR R8, [R0,#-4]		//R8 stores size of signal
						LDR R9, [R0, #-4]		//R9 stores size of signal
						LDR R10, [R0, #-4]	//R10 also stores size of signal
						SUBS R8, R8, #1
						BEQ ONE_VALUE				//if the size is only one value then skip	
						LDR R2, [R0]				//R2 starts off with first value, it will hold the sum then average

FIND_LOG:		SUBS R1, R1, #-1		//increment R1 by 1
						LSR R9, R9, #1			//divide size by 2
						CMP R9, #1					//if R9 is equal to 1
						BEQ LOOP_SUM				//if yes found log continue
						B FIND_LOG			

ONE_VALUE:	LDR R5, [R4]
						STR R5, [R0]
						B END
			
LOOP_SUM:		SUBS R10, R10, #1		//loop through and add all
						BEQ FIND_AVG
						ADD R0, R0, #4			//increment pointer to next sample
						LDR R5, [R0]				//load R5 with next value
						ADD R2, R2, R5			//add to sum the value at next pointer
						B LOOP_SUM

FIND_AVG:		LSR R2, R2, R1
						LDR R5, [R0]
						SUB R5, R5, R2
						STR	R5, [R0]
						B CENTER

CENTER:			SUBS R7, R7, #1
						BEQ END
						ADD R0, R0, #-4			//decrement the pointer cause it is at the end
						LDR R5, [R0]
						SUB R5, R5, R2
						STR	R5, [R0]
						B CENTER

END:				B END

ZERO:				.word	0
N:		    	.word	8                                                                       
NUMBERS:		.word -15, 22, 11, 39
						.word	-7, 10, 20, -32
