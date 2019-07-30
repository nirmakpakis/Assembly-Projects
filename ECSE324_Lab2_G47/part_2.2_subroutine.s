		.text
		.global	max_2	
max_2:		
		CMP R0, R1
		BXGE LR
		MOV R0, R1	
		BX LR
		.end
