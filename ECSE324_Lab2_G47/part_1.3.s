

				.text
				.global _start
_start:
				MOV R0, #5
				BL fib
				B END

fib:			PUSH {LR}
				CMP R0, #2		  // If R0 is less than 2 return 1
				BLT returnOne 
				ADD R1, R0, #-1     // n-1
				ADD R2, R0, #-2     // n-2
				PUSH {R2}
				MOV R0, R1		    // Recurse on n-1
				BL fib					
				POP {R2}		    //POP F(n-2)
				PUSH {R0}		    //STORE F(n)
				MOV R0, R2
				BL fib			
				MOV R2, R0       // Recurse on n-1
				POP {R1}		 // POP F(n-1)
				ADD R0, R1, R2 	 // F(n)=F(n-1)+F(n-2)
				POP {LR}
				MOV PC, LR			

returnOne:		MOV R0, #1
				POP {LR}
				MOV PC, LR

END:			B END


//F(4) = F(3) + F(2)
// 	   = F(2)+F(1) + F(1) + F(0)
//	   = F(1)+F(0)+F(1)+F(1)+F(0)

