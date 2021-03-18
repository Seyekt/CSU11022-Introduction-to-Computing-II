;
; CS1022 Introduction to Computing II 2018/2019
; Lab 3 - Floating-Point Addition
;

	AREA	RESET, CODE, READONLY
	ENTRY

;
; Test Data
;
FP_A	EQU	0x3fc00000 ;0x412c0000			;0x41C40000
FP_B	EQU	0x3fc00000 ;0x41960000


	; initialize system stack pointer (SP)
	LDR	SP, =0x40010000

	LDR	R0, =FP_A		; test value A
	LDR	R1, =FP_B		; test value B
	;LDR	R0, =FP_B
	
	
	;BL	fpdecode
	
	;BL	fpencode
	
	BL fpadd

STOP	B	STOP


;
; fpdecode
; decodes an IEEE 754 floating point value to the signed (2's complement)
; fraction and a signed 2's complement (unbiased) exponent
; parameters:
;	R0 - IEEE 754 float
; return:
;	R0 - fraction (signed 2's complement word)
;	R1 - exponent (signed 2's complement word)
;
fpdecode

	PUSH {R4-R10, LR}
	; Sort the IEEE-457 into their components
	; R4, Address of IEEE-457
	; R5, S =0/1
	; R6, E = 130
	; R7, F = 0111 1111 1111 1111 1111 1111
	
	LDR	R8, =0x40000000
	STR	R0, [R8]
	MOV	R4, R0			; Loads the IEEE-457 stored in R4
	MOV	R5, #0x10000000
	MOV	R6, #3
	LDRB	R6, [R8, R6] 
	AND	R5, R6, R5		; Determines whether s 0/1 in R5
	
	MOV	R6, #2
	LDRH	R6, [R8, R6]
	LDR	R7, =0x7F80			;0x0111 1111 1000 0000			,#0x7F80	
	AND	R6, R6, R7
	MOV	R6, R6, LSL #1		
	MOV	R6, R6, LSR #8		; R6 Now contains the E before the 127 minus, // Operation shift two bytes down, removing extra zero's
	MOV	R7, #127		
	SUB	R6, R6, R7		; Finds the E (130 - E Previous)
	
	MOV	R7, R0
	MOV	R7, R7, LSL #8
	MOV	R7, R7, LSR #8
	MOV 	R10, #0
removeZero
	MOV 	R8, #0x1
	AND 	R9, R7, R8
	CMP 	R9, #1
	BEQ	finished
	MOV 	R7, R7, LSR #1
	ADD 	R10, R10, #1
	B	removeZero
	
finished
	MOV	R7, R7, LSL R10
	MOV	R0, R7
	MOV	R1, R6
	POP {R4-R10, PC}

;
; fpencode
; encodes an IEEE 754 value using a specified fraction and exponent
; parameters:
;	R0 - fraction (signed 2's complement word)
;	R1 - exponent (signed 2's complement word)
; result:
;	R0 - IEEE 754 float
;
fpencode
	; Take the components and create the IEEE-457 
	; R4, Address of IEEE-457
	; R5, S =0/1
	; R6, E = 130
	; R7, F = 0111 1111 1111 1111 1111 1111
	PUSH {R4-R6, LR}
	MOV	R4, R0
	MOV	R5, R1
	ADD	R5, R5, #127
	MOV	R5, R5, LSL #23
	ORR	R6, R5, R4
	MOV	R0, R6
	POP {R4-R6,PC}


;
; fpadd
; adds two IEEE 754 values
; parameters:
;	R0 - IEEE 754 float A
;	R1 - IEEE 754 float B
; return:
;	R0 - IEEE 754 float A+B
;
fpadd

	PUSH {R4-R9, LR}
	
	MOV	R4, R1
	
	BL	fpdecode
	MOV	R6, R0		; fraction 1
	MOV	R7, R1		; exponent 1
	
	MOV	R0, R4
	BL	fpdecode
	MOV	R4, R0		; fraction 2
	MOV	R5, R1		; exponent 2
	
	CMP	R7, R5		; R0 must be greater
	BGE	SKIPSWAP	; if not, swap them
	
	MOV	R2, R7				
	MOV	R3, R5		
	MOV	R7, R3
	MOV	R5, R2
	
	MOV	R2, R6	
	MOV	R3, R4		
	MOV	R6, R3
	MOV	R4, R2
	
SKIPSWAP	
	
	
	
LOOP0
	CMP	R7, R5
	BEQ	END0
	MOV	R4, R4, LSR#1
	ADD	R5, R5, #1
	B	LOOP0

END0

	ADD R6, R6, #0x800000
	ADD R4, R6, #0x800000
	
	ADD	R0, R6, R4 	; fraction
	MOV	R1, R5		; exponent
	
	;LDR	R8, =0x400000	; 10000000000000000000000
	;LDR	R9, =0x3FFFFF	; 01111111111111111111111	mask for clearing bits
	;BIC	R9, R0, R9 
	
	;CMP	R8, R9
	;BEQ	ROUND
	
	

;ROUND

	BL fpencode

	POP {R4-R9,PC}

	;
	; your add subroutine goes here
	;

	END

