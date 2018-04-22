; Print.s
; Student names: change this to your names or look very silly
; Last modification date: change this to the last modification date or look very silly
; Runs on LM4F120 or TM4C123
; EE319K lab 7 device driver for any LCD
;
; As part of Lab 7, students need to implement these LCD_OutDec and LCD_OutFix
; This driver assumes two low-level LCD functions
; ST7735_OutChar   outputs a single 8-bit ASCII character
; ST7735_OutString outputs a null-terminated string 
Counter 		EQU			-4
NumTen			EQU			-4
	IMPORT 	writedata
	IMPORT 	writecommand
    IMPORT   ST7735_OutChar
    IMPORT   ST7735_OutString
    EXPORT   LCD_OutDec
    EXPORT   LCD_OutFix
	PRESERVE8

    AREA    |.text|, CODE, READONLY, ALIGN=2
    THUMB

  

;-----------------------LCD_OutDec-----------------------
; Output a 32-bit number in unsigned decimal format
; Input: R0 (call by value) 32-bit unsigned number
; Output: none
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutDec
			PUSH {R11}
			MOV R11, SP
			ADD SP, #Counter
		
		
			PUSH {R4-R11}
			MOV R6, R0
			MOV R7, #10
		
			MOV R10, #0						;COUNTER 
			MOV R1, R6						; R1 HAS INPUT
loopD1		UDIV R1, R1, R7					; DIVIDE INPUT/10
			CMP R1, #0						;CHECK IF 0
			ADD R10, #1						;ADD 1 TO COUNTER
			BNE loopD1						; IF NOT 0 LOOP BACK
			STR R10, [R11,#Counter]			;
			SUBS R10, #1					;SUB COUNTER
			BNE loopD4						
			ADD R0, #0x30					;MAKING IT A CHARACTER
			PUSH {LR,R1-R3}
			BL ST7735_OutChar				;OUTPUT CHARACTER
			POP {LR,R1-R3}
			POP {R4-R11}
			BX LR
			
loopD4		MOV R2, R7						;PUT 10 IN R2
loopD2		SUBS R10, #1					;SUB 1 FROM COUNTER
			BEQ loopD3						;GO TO D3, IF SUB 1 =0
			MUL R2,R7						; MULTIPLY 10*R2
			B loopD2						;TRYING TO GET COUNTER TO 0
loopD3		UDIV R4, R6, R2					;INPUT/R2(10.....)
			MUL R5, R4, R2					;	
			SUB R5, R6, R5					; INPUT-R5
			MOV R0, R4						;
			ADD R0, #0x30					;MAKING IT A CHARACTER
			PUSH {LR,R1-R3}
			BL ST7735_OutChar				;OUTPUT CHARACTER
			POP {LR,R1-R3} 
			MOV R6, R5
			UDIV R2, R7
			CMP R2, #0
			BNE loopD3
			POP {R4-R11}
			
			MOV SP,R11 
			POP {R11}		
		
		


      BX  LR
;* * * * * * * * End of LCD_OutDec * * * * * * * *

; -----------------------LCD _OutFix----------------------
; Output characters to LCD display in fixed-point format
; unsigned decimal, resolution 0.001, range 0.000 to 9.999
; Inputs:  R0 is an unsigned 32-bit number
; Outputs: none
; E.g., R0=0,    then output "0.000 "
;       R0=3,    then output "0.003 "
;       R0=89,   then output "0.089 "
;       R0=123,  then output "0.123 "
;       R0=9999, then output "9.999 "
;       R0>9999, then output "*.*** "
; Invariables: This function must not permanently modify registers R4 to R11
LCD_OutFix

			PUSH {R11}
			MOV R11,SP
			ADD SP,#NumTen
			
			PUSH {R4-R11}
			MOV R7, #10
			STR R7,[R11,#NumTen]
			MOV R9, #1000						;THOUSANDTHS
			MOV R8, #100						;HUNDRETHS
			UDIV R1, R0, R8					
			UDIV R1, R1, R8				
			CMP R1, #0
			BNE loopF1							;VALUE TOO BIG
			MOV R4, R0
			
			
			;MAKING INTO NUMBERS
			
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar					;OUTPUTS FIRST NUM
			POP {LR}
			MOV R0, #0x2E
			PUSH {LR}
			BL ST7735_OutChar					;OUTPUTS DECIMAL
			POP {LR}
			
			UDIV R9, R7
			MOV R4, R10
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar					;OUTPUTS SECOND NUM					
			POP {LR}
			
			UDIV R9, R7
			MOV R4, R10
			UDIV R2, R4, R9
			MUL R10, R2, R9
			SUB R10, R4, R10
			MOV R0, R2
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar					;OUTPUTS THIRD NUM
			POP {LR}
			
			MOV R0, R10
			ADD R0, #0x30
			PUSH {LR}
			BL ST7735_OutChar					;OUTPUTS FOURTH NUM
			POP {LR}
			POP {R4-R11}
			
			MOV SP,R11
			POP {R11}
			BX LR
			
			
	; TOO BIG OUTPUT BELOW		
			
			
loopF1		MOV R0, #0x2A				;STAR
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2E				;DECIMAL
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A				;STAR
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A				;STAR
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			MOV R0, #0x2A				;STAR
			PUSH {LR}
			BL ST7735_OutChar
			POP {LR}
			POP {R4-R11}

     BX   LR
 
     ALIGN
;* * * * * * * * End of LCD_OutFix * * * * * * * *

     ALIGN                           ; make sure the end of this section is aligned
     END                             ; end of file
