		.text
		.global _start


//Part 1.1: different variations of the built in Push and Pop

_start:
		MOV R0, #1     
PushFirst:
		STMIA SP!, {R0}
Inc2:
		ADD R0,R0,#1
PushSecond:
		STM SP!, {R0}
Inc3:
		ADD R0,R0,#1
PushThird:
		STR R0, [SP], #4
PopFirst:
		LDMDB SP!, {R0}
PopSecond:
		LDMDB SP!, {R0}
PopThird:
		LDR R0, [SP,#-4]

END: B END

RESULT: .word 4
