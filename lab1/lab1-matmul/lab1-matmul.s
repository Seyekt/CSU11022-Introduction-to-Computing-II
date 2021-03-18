;
; CS1022 Introduction to Computing II 2018/2019
; Lab 1 - Matrix Multiplication
;

;1   	90	100	110	120
;2	202	228	254	280
;3	314	356	398	440
;4	426	484	542	600

;1	 5A


N	EQU	4

	AREA	globals, DATA, READWRITE

; result matrix R

ARR_R	SPACE	N*N*4		; 4 * 4 * word-size values


	AREA	RESET, CODE, READONLY
	ENTRY

	LDR	R0, =ARR_A
	LDR	R1, =ARR_B
	LDR	R2, =ARR_R
	LDR	R3, =N

	; your program goes here
	
	LDR R4, =0				; i = 0
FOR1	CMP R4, #N				; i < N
	BHS EFOR1				; END FOR1
			
	LDR R5, =0				; j = 0
FOR2	CMP R5, #N				; j < N
	BHS EFOR2				; END FOR2
		
	LDR R6, =0				; r = 0
		
	LDR R7, =0				; k = 0
FOR3	CMP R7, #N					; k < N
	BHS EFOR3				; END FOR3
		
	MUL R8, R4, R3				; R8 = Value of = A[i, _ ]  // Move to correct row 
	ADD R8, R8, R7				; R8 = Value of = A[i, k ]  // Then to correct column
	LDR R9, [R0, R8, LSL #2]		; To place of A[i, k]
	
	MUL R10, R7, R3				; R8 = Value of = B[k, _ ]  // Move to correct row 
	ADD R10, R10, R5			; R8 = Value of = B[k, j ]  // Then to correct column
	LDR R11, [R1, R10, LSL #2]		; To place of B[k, j]
	
	MUL R11, R9, R11			; R = ( A[ i , k ] * B[ k , j ] )
	ADD R6, R11, R6				; R = R +( A[ i , k ] * B[ k , j ] )
		
	ADD R7, R7, #1				; k++;
	B FOR3					; Back to third loop
EFOR3
		
	MUL R12, R4, R3				; R12 = Value of R[i, _]
	ADD R12, R12, R5			; R12 = Value of R[i, j]
		
	STR R6, [R2, R12, LSL #2]		; R[ i , j ] = r ;
		
	ADD R5, R5, #1				; j++;
	B FOR2					; Back to second loop
EFOR2
	ADD R4, R4, #1				; i++;
	B FOR1					; Back to first loop
EFOR1

STOP	B	STOP

; two constant value matrices, A and B

ARR_A	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

ARR_B	DCD	 1,  2,  3,  4
	DCD	 5,  6,  7,  8
	DCD	 9, 10, 11, 12
	DCD	13, 14, 15, 16

	END
