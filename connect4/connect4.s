;
; CS1022 Introduction to ComPUTing II 2018/2019
; Mid-Term Assignment - Connect 4 - SOLUTION
;
; GET, PUT and PUTs subroutines provided by jones@scss.tcd.ie
;

PINSEL0	EQU	0xE002C000
U0RBR	EQU	0xE000C000
U0THR	EQU	0xE000C000
U0LCR	EQU	0xE000C00C
U0LSR	EQU	0xE000C014
	
SPACES	EQU	42	
ROWS	EQU	6
COLUMNS	EQU	7

	AREA	globals, DATA, READWRITE
	
	;
	; copy the test data into RAM
	;

	
BOARD	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	DCB	0,0,0,0,0,0,0
	
SORTED	SPACE	SPACES		; N words (1 byte each)


	AREA	RESET, CODE, READONLY
	ENTRY
	
	

	; initialise SP to top of RAM
	LDR	R13, =0x40010000	; initialse SP

	; initialise the console
	BL	inithw

	;
	; Main
	;
	
START	LDR	R0, =str_go
	BL	PUTS
	
	LDR	R0, =str_newl
	BL	PUTS
	
	BL	initializeBoard
	
	MOV	R4, #0			; start with red's turn 
	MOV	R5, #0			; boolean win = false
	
LOOP0	BL	drawBoard		

	CMP	R5, #1			; win?
	BEQ	WIN2			; if so, end game and determine winner

	MOV	R1, R4			; restore turn
	BL	makeMove
	MOV	R4, R1			; back up turn
	
	BL	checkForWin		
	MOV	R6, R0			; back up address of input piece
	MOV	R5, R1			; back up value of boolean win
	
	B	LOOP0			; repeat
	
WIN2	LDRB	R5, [R6]		; load the value of the winning piece
	CMP	R5, #0x59		; is this piece 'Y'?
	BEQ	YELLOWWIN		; if so, yellow has won
	LDR	R0, =str_red_win
	BL	PUTS			; print "Red wins!"
	B	STOP			; end
	
YELLOWWIN
	LDR	R0, =str_yellow_win
	BL	PUTS			; print "Yellow wins!"

STOP	B	STOP


;
; Subroutines
;

; initializeBoard subroutine
	; Void leaf function which initializes the board by copying values defined in flash ROM by the DCB statements at the beginning of the program.
	; to an area in RAM, converting each to the ASCII character '0' as it does so. It takes no parameters.
	
initializeBoard

	PUSH	{R4-R7, LR}
	
	LDR	R4, =SORTED
	LDR	R5, =BOARD
	LDR	R6, =0
iB0	CMP	R6, #SPACES
	BHS	iB1
	LDRB	R7, [R5, R6]		; load byte
	ADD	R7, #0x30		; convert to ASCII
	STRB	R7, [R4, R6]		; store character
	ADD	R6, R6, #1		; increment by 1
	B	iB0
iB1
	POP	{R4-R7, PC}

; drawBoard subroutine
	; Void function which displays the board by reading the contents of RAM.
	; It takes no parameters.

drawBoard

	PUSH	{R4-R7, LR}
	
	LDR	R0, =str_header
	BL	PUTS
	 
	LDR	R4, =SORTED	; starting address of board data
	MOV	R5, #0		; row counter to 6
	MOV	R6, #0		; column counter to 7
	
ROWSTRT	CMP	R5, #ROWS
	BHS	drawBoard0
	MOV	R0, R5
	ADD	R0, R0, #0x31	; + 1
	BL 	PUTwithSpace	
	
drawBoard1	
	CMP	R6, #COLUMNS
	BHS	ROWEND
	MOV	R7, #7		; size of rows
	MUL	R7, R5, R7	; row number by row size
	ADD	R7, R7, R6	; plus column number
	LDRB	R0, [R4, R7]
	BL 	PUTwithSpace
	ADD	R6, R6, #1
	B	drawBoard1
	
ROWEND

	ADD	R5, R5, #1
	MOV	R6, #0
	
	LDR	R0, =str_newl
	BL 	PUTS
	
	B	ROWSTRT
	
drawBoard0

	POP	{R4-R7, PC}
	
	
	; makeMove subroutine
	; Subroutine which allows the player to place a piece into the board. 
	; Parameters:
	; 	R1: boolean turn,  false - red, true - yellow
	; Returns:
	;	R0: address in memory of placed piece
	;	R1: boolean turn
	

makeMove

	PUSH	{R4-R7, LR}
	
	CMP	R1, #1			; is it yellow's turn?
	BEQ	makeMove0
	
	MOV	R7, #1			; make it yellow's turn next
	LDR	R0, =str_red_turn
	BL	PUTS
	MOV	R5, #0x52		; piece is 'R'
	B	makeMove1
	
makeMove0

	MOV	R7, #0			; make it red's turn next
	LDR	R0, =str_yellow_turn
	BL	PUTS
	MOV	R5, #0x59		; piece is 'Y'
	
makeMove1
	BL	GET			; get character
	BL	PUT			; put character
	CMP	R0, #0x71		; is character q?
	BEQ	START			; if so, restart
	CMP	R0, #0x31		; < 0x31 / '1'?
	BLO	makeMove1
	CMP	R0, #0x37		; > 0x37 / '7'?
	BHI	makeMove1
	SUB	R0, R0, #0x31		; convert to column to int, -1 because 0 is the first column
	
	MOV	R3, #5			; row number
	MOV	R1, #7			; size of rows
	MUL	R2, R3, R1		; row number by row size
	ADD	R2, R2, R0		; plus column number

	LDR	R4, =SORTED		; starting address of board data

makeMove3
	ADD	R3, R4, R2
	CMP	R3, #0x4000002A		; is address within range?
	BLO	makeMove1		; if not, make player choose another column
	LDRB	R6, [R4, R2]		
	CMP	R6, #0x30
	BEQ	makeMove2
	SUB	R2, R2, #7		; previous row
	B	makeMove3
	
makeMove2
	
	
	STRB	R5, [R4, R2]		; finally store letter

	MOV	R1, R7			; return turn
	
	ADD	R0, R4, R2		; return address
	
	POP	{R4-R7, PC}


; checkForWin subroutine
	; Void leaf function which sorts all the elements of a one-dimensional array of word-sized integers
	; Parameters:
	; 	R0: the address of the newest disc added
	; Returns:
	; 	R0: the address of the newest disc added 
	;	R1: boolean , 1 for win

checkForWin

	PUSH	{R4-R8, LR}
	
	MOV	R8, R0			; backup address				
	MOV	R7, #1			; counter

	LDRB	R5, [R0]		; check vertically
chkWin0	CMP	R7, #4			; is count 4?
	BHS	WIN			; if so, then the game is won
	LDRB	R6, [R0, #7]!		; next row, only need check downwards
	CMP	R5, R6			; is R5 == R6?
	BNE	CHECKHORIZONTAL		; if not, then no vertical win, check horizontally.
	ADD	R7, R7, #1
	B	chkWin0

CHECKHORIZONTAL

	MOV	R0, R8			; reset address

chkWin1	LDRB	R6, [R0, #-1]!		; check if leftmost red or yellow disc
	CMP	R6, R5
	BNE	DONE1
	B	chkWin1
	
DONE1	

	MOV	R7, #0			; counter
	
chkWin2	CMP	R7, #4			; is count four
	BHS	WIN
	LDRB	R6, [R0, #1]!		; next column
	CMP	R5, R6			
	BNE	CHECKDIAGONAL
	ADD	R7, R7, #1
	B	chkWin2

CHECKDIAGONAL

	MOV	R0, R8			; reset address

chkWin3	LDRB	R6, [R0, #-8]!		; check if diagonal space (up and left) is a red or yellow disc
	CMP	R6, R5
	BNE	DONE2
	B	chkWin3
	
DONE2	

	MOV	R7, #0			; counter
	
chkWin4	CMP	R7, #4			; is count 4?
	BHS	WIN
	LDRB	R6, [R0, #8]!		; next column
	CMP	R5, R6			
	BNE	CHECKDIAGONAL2
	ADD	R7, R7, #1
	B	chkWin4

CHECKDIAGONAL2

	MOV	R0, R8			; reset address

chkWin5	LDRB	R6, [R0, #-6]!		; check if diagonal space (up and right) is a red or yellow disc
	CMP	R6, R5
	BNE	DONE3
	B	chkWin5
	
DONE3	

	MOV	R7, #0			; counter
	
chkWin6	CMP	R7, #4			; is count 4?
	BHS	WIN
	LDRB	R6, [R0, #6]!		; next column
	CMP	R5, R6			
	BNE	NOWIN
	ADD	R7, R7, #1
	B	chkWin6

NOWIN
	
	MOV	R1, #0			; win = false

	B	END01			; end subroutine
	
WIN	MOV	R1, #1			; win = true

END01	MOV	R0, R8			; reset address
	POP	{R4-R8, PC}	


; PUTwithSpace subroutine
	; Void function which prints out the input charcater to the console with a space
	; Parameters:
	; 	R0: the input character	

PUTwithSpace

	PUSH	{LR}
	
	LDR	R1, =0x400000DA
	STRB	R0, [R1]
	MOV	R0, #0x20		; space
	STRB	R0, [R1, #1]
	MOV	R0, #0x0		; null
	STRB	R0, [R1, #2]
	MOV	R0, R1
	
	BL	PUTS
	
	POP	{PC}

;
; inithw subroutines
; performs hardware initialisation, including console
; parameters:
;	none
; return value:
;	none
;
inithw
	LDR	R0, =PINSEL0		; enable UART0 TxD and RxD signals
	MOV	R1, #0x50
	STRB	R1, [R0]
	LDR	R0, =U0LCR		; 7 data bits + parity
	LDR	R1, =0x02
	STRB	R1, [R0]
	BX	LR

;
; GET subroutine
; returns the ASCII code of the next character read on the console
; parameters:
;	none
; return value:
;	R0 - ASCII code of the character read on the console (byte)
;
GET	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
GET0	LDR	R0, [R1]		; wait until
	ANDS	R0, #0x01		; receiver data
	BEQ	GET0			; ready
	LDR	R1, =U0RBR		; R1 -> U0RBR (Receiver Buffer Register)
	LDRB	R0, [R1]		; GET received data
	BX	LR			; return

;
; PUT subroutine
; writes a character to the console
; parameters:
;	R0 - ASCII code of the character to write
; return value:
;	none
;
PUT	LDR	R1, =U0LSR		; R1 -> U0LSR (Line Status Register)
	LDRB	R1, [R1]		; wait until transmit
	ANDS	R1, R1, #0x20		; holding register
	BEQ	PUT			; empty
	LDR	R1, =U0THR		; R1 -> U0THR
	STRB	R0, [R1]		; outPUT charcter
PUT0	LDR	R1, =U0LSR		; R1 -> U0LSR
	LDRB	R1, [R1]		; wait until
	ANDS	R1, R1, #0x40		; transmitter
	BEQ	PUT0			; empty (data flushed)
	BX	LR			; return

;
; PUTS subroutine
; writes the sequence of characters in a NULL-terminated string to the console
; parameters:
;	R0 - address of NULL-terminated ASCII string
; return value:
;	R0 - ASCII code of the character read on the console (byte)
;
PUTS	STMFD	SP!, {R4, LR} 		; push R4 and LR
	MOV	R4, R0			; copy R0
PUTS0	LDRB	R0, [R4], #1		; GET character + increment R4
	CMP	R0, #0			; 0?
	BEQ	PUTS1			; return
	BL	PUT			; PUT character
	B	PUTS0			; next character
PUTS1	LDMFD	SP!, {R4, PC} 		; pop R4 and PC


;
; hint! Put the strings used by your program here ...
;

str_go
	DCB	"Let's play Connect 4!!", 0xA, 0xD, 0x0

str_header
	DCB	0xA, 0xD, 0x20, 0x20, "1 2 3 4 5 6 7", 0xA, 0xD, 0x0

str_red_turn
	DCB	"RED: choose a column for your next move (1-7, q to restart): ", 0xA, 0xD, 0x0
	
str_yellow_turn
	DCB	"YELLOW: choose a column for your next move (1-7, q to restart): ", 0xA, 0xD, 0x0
	
str_red_win
	DCB	0xA, 0xD, "Red wins!", 0xA, 0xD, 0x0
	
str_yellow_win
	DCB	0xA, 0xD, "Yellow wins!", 0xA, 0xD, 0x0


str_newl
	DCB	0xA, 0xD, 0x0
	


	END
