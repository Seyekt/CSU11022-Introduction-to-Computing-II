;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Array Move
;

N	EQU	16		; number of elements

	AREA	globals, DATA, READWRITE

; N word-size values

ARRAY	SPACE	N*4		; N words


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

	; the program goes here
	
	MOV	R4, #0					; R4 = 0 / Count
	MOV	R10, #0					; R10 = 0
L3	CMP	R4, R1					; CMP R4 w/ R1 
	BHS	L4					; Is the count equal to the array? When it is finish
	LDR	R5, [R0, R10]				; Load the (first) value from the array
	MUL	R6, R5, R5				; Square that value
	STR	R6, [R0, R10]				; Store that value back and increment to to next index (word up) to load next value
	ADD	R4, R4, #1				; Increase count
	ADD	R10, R10, #4				; Increase Word value by word
	B	L3					; Repeat till finished array
L4	

	LDR 	R1, =3					; Where we wish to take the first value and store the second
	LDR	R2, =6					; Where we wish to store the firs value and take the second
	
	CMP 	R1, R2
	BLT	L7

	SUB	R5, R1, R2				; R5 = Where we know to end the count; 6 - 3 = 3
	LDR 	R4, [R0, R1, LSL #2]			; R4 = Load the memory, move up to our first value we take (6th), Take the first value, store in register	
	MOV	R6, #0					; R6 = Create count = 0
	MOV	R9, R1					; R9 = R1 for later use
	
L5	CMP	R6, R5					; Compare counts
	BEQ	L6					; If equal, finish
	SUB	R8, R9, #1				; Move one place down from first value (i.e. index 5)
	LDR	R7, [R0, R8, LSL #2]			; Load that value
	STR	R7, [R0, R9, LSL #2]			; Store that value in one index above (i.e. index 6)
	SUB	R9, R9, #1				; Move first value down a place
	ADD 	R6, R6, #1				; Increase count by one
	B	L5	
L6	
	STR	R4, [R0, R1, LSL #2] 	; Store first value in second position
	
	B STOP
	
	
L7	SUB	R5, R2, R1				; R5 = Where we know to end the count; 6 - 3 = 3
	LDR 	R4, [R0, R2, LSL #2]			; R4 = Load the memory, move up to our first value we take (6th), Take the first value, store in register	
	MOV	R6, #0					; R6 = Create count = 0
	MOV	R9, R2					; R9 = R1 for later use
	
L8	CMP	R6, R5					; Compare counts
	BEQ	L9					; If equal, finish
	ADD	R8, R9, #1				; Move one place down from first value (i.e. index 5)
	LDR	R7, [R0, -R8, LSL #2]			; Load that value
	STR	R7, [R0, -R9, LSL #2]			; Store that value in one index above (i.e. index 6)
	ADD	R9, R9, #1				; Move first value down a place
	ADD 	R6, R6, #1				; Increase count by one
	B	L8	
L9	
	STR	R4, [R0, -R1, LSL #2] 			; Store first value in second position
	
	
	
STOP	B	STOP

	END
