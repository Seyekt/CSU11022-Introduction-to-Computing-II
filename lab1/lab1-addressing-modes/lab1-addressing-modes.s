;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Addressing Modes Partial Solution
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	; for convenience, let's initialise test array [0, 1, 2, ... , N-1]

	LDR	R0, =ARRAY
	LDR	R1, =0
L1	CMP	R1, #N
	BHS	L2
	STR	R1, [R0, R1, LSL #2]
	ADD	R1, R1, #1
	B	L1
L2

	; initialise registers for your program

	LDR	R0, =ARRAY	; array start address
	LDR	R1, =N		; size of array (words)

	; your program goes here

	; Q.1.1
	; immediate offset
	; 83 instructions

	MOV	R4, #0			; R4 = 0 / Count
L3	CMP	R4, R1			; CMP R4 w/ R1 
	BHS	L4				; Is the count equal to the array? When it is, finish
	LDR	R5, [R0]		; Load the (first) value from the array
	MUL	R6, R5, R5		; Square that value
	STR	R6, [R0]		; Store that value back and increment to to next index (word up) to load next value
	ADD	R0, R0, #4		; Increment address by 4
	ADD	R4, R4, #1		; Increase count
	B	L3
L4
	
	; Q.1.2
	; Immediate Offset and Register Offset
	
	;MOV	R4, #0			; R4 = 0 / Count
;L3	CMP	R4, R1			; CMP R4 w/ R1 
	;BHS	L4				; Is the count equal to the array? When it is, finish
	;MOV	R8, #4
	;MUL	R7, R4, R8		; Multiply the count by 4
	;LDR	R5, [R0, R7]	; Load the (first) value from the array
	;MUL	R6, R5, R5		; Square that value
	;STR	R6, [R0, R7]	; Store that value back and increment to to next index (word up) to load next value
	;ADD	R4, R4, #1		; Increase count
	;B	L3				; Repeat till finished array
;L4

	; Q.1.3
	; Immediate Offset and Scaled Register Offset (e.g. [Rn, Rm, LSL #shift])
	
	;MOV	R4, #0					; R4 = 0 / Count	
;L3	CMP	R4, R1					; CMP R4 w/ R1 
	;BHS	L4						; Is the count equal to the array? When it is, finish
	;LDR	R5, [R0, R4, LSL #2]	; Load the (first) value from the array
	;MUL	R6, R5, R5				; Square that value
	;STR	R6, [R0, R4, LSL #2]	; Store that value back and increment to to next index (word up) to load next value
	;ADD	R4, R4, #1				; Increase count
	;B	L3						; Repeat till finished array
;L4

	; Q.1.4
	; Immediate Offset and Pre- or Post-indexed (e.g. [Rn], #offset or [Rn,#offset]!)

	;;MOV	R4, #0				; R4 = 0 / Count
;;L3	CMP	R4, R1				; CMP R4 w/ R1 
	;;BHS	L4					; Is the count equal to the array? When it is, finish
	;;LDR	R5, [R0]			; Load the (first) value from the array
	;;MUL	R6, R5, R5			; Square that value
	;;STR	R6, [R0], #4		; Store that value back and increment to to next index (word up) to load next value
	;;ADD	R4, R4, #1			; Increase count
	;;B	L3					; Repeat till finished array
;;L4	

	
STOP	B	STOP

	END