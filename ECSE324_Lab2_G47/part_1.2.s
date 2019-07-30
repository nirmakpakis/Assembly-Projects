			.text
			.global _start	

_start:
			LDR R4, =RESULT
			LDR R2, [R4, #4]
			ADD R2,R2,#-1
			ADD R3, R4, #8
			LDR R0, [R3]
			BL LOOP
			STR R0, [R4]
			B END


LOOP:		ADD R3, R3, #4
			LDR R1, [R3]
			CMP R1, R0
			MOVGT R0, R1
			SUBS R2, R2, #1
			MOVEQ PC,LR
			PUSH {LR}
			BL LOOP
            POP {LR}
			BX LR


END:		B END

RESULT:		.word	0
N:			.word 	4
NUMBERS:	.word 	4, 5, 6, 3
