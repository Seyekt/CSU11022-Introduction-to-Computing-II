;
; CS1022 Introduction to Computing II 2018/2019
; Lab 2 - Recursion
;

N	EQU	10

	AREA	globals, DATA, READWRITE

; N word-size values

SORTED	SPACE	N*4		; N words (4 bytes each)


	AREA	RESET, CODE, READONLY
	ENTRY

	;
	; copy the test data into RAM
	;

	LDR	R4, =SORTED
	LDR	R5, =UNSORT
	LDR	R6, =0
whInit	CMP	R6, #N
	BHS	eWhInit
	LDR	R7, [R5, R6, LSL #2]
	STR	R7, [R4, R6, LSL #2]
	ADD	R6, R6, #1
	B	whInit
eWhInit
	

	;
	; call your sort subroutine to test it
	;
	
	LDR	R0, =0x40000000
	MOV	R1, #N
	
	;LDR	R1, =3			; Where we wish to take the first value and store the second
	;LDR	R2, =6			; Where we wish to store the firsT value and take the second
	
	
	BL	SORT

STOP	B	STOP


	; SWAP subroutine
	; Void stem function which swaps two elements in a one-dimensional array of word-sized integers
	; Parameters:
	; 	R0: the starting address of the array
	; 	R1: i - the index of the first element to be swapped
	; 	R2: j - the index of the second element to be swapped
	
SWAP	PUSH	{R4, LR}		; save registers

	LDR	R3, [R0, R1, LSL #2]	; load the element at index i into R3
	LDR	R4, [R0, R2, LSL #2]	; load the element at index j into R4
	
	STR	R3, [R0, R2, LSL #2]	; store the element at index i at index j
	STR	R4, [R0, R1, LSL #2]	; store the element at index j at index i
	
	POP	{R4, PC}		; return

	; SORT subroutine
	; Void leaf function which sorts all the elements of a one-dimensional array of word-sized integers
	; Parameters:
	; 	R0: the starting address of the array
	; 	R1: N - the length of the array in words
	
SORT	PUSH	{R4-R6, LR}		; save registers
	
SORT0	MOV	R2, #0			; boolean swapped = false

	MOV	R3, #1			; i = 1
SORT1	CMP	R3, R1
	BHS	SORT2
	ADD	R3, R3, #1		; i++
	
	SUB	R4, R3, #1		; i - 1 = i - 1
	
	LDR	R5, [R0, R3, LSL #2]	; i
	LDR	R6, [R0, R4, LSL #2]	; i - 1
	CMP	R6, R5			; if ( array[i-1] > array[i] ), swap 
	BLS	SORT3			; else
	
	PUSH	{R1-R3}		
	MOV	R1, R4
	MOV	R2, R3
	BL	SWAP			;swap( array, i-1, i ) 
	POP	{R1-R3}
	
	MOV	R2, #1			; swapped = true
	
SORT3	B	SORT1			
	
SORT2	CMP	R2, #1			; if swapped
	BEQ	SORT0	
	
	POP	{R4-R6, PC}		; return

UNSORT	DCD	9,3,0,1,6,2,4,7,8,5

	END


