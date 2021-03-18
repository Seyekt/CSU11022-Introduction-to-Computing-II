;
; CS1022 Introduction to Computing II 2018/2019
; Lab 4 - countdown
;
T0IR		EQU	0xE0004000
T0TCR		EQU	0xE0004004
T0MR0		EQU	0xE0004018
T0MCR		EQU	0xE0004014

PINSEL4		EQU	0xE002C010

FIO2DIR1	EQU	0x3FFFC041
FIO2PIN1	EQU	0x3FFFC055

EXTINT		EQU	0xE01FC140
EXTMODE		EQU	0xE01FC148
EXTPOLAR	EQU	0xE01FC14C

VICIntSelect	EQU	0xFFFFF00C
VICIntEnable	EQU	0xFFFFF010
VICVectAddr0	EQU	0xFFFFF100
VICVectPri0	EQU	0xFFFFF200
VICVectAddr	EQU	0xFFFFFF00

VICVectT0	EQU	4
VICVectEINT0	EQU	14

Irq_Stack_Size	EQU	0x80

Mode_USR        EQU     0x10
Mode_IRQ        EQU     0x12
I_Bit           EQU     0x80            ; when I bit is set, IRQ is disabled
F_Bit           EQU     0x40            ; when F bit is set, FIQ is disabled


	AREA	RESET, CODE, READONLY
	ENTRY

	; Exception Vectors

	B	Reset_Handler	; 0x00000000
	B	Undef_Handler	; 0x00000004
	B	SWI_Handler	; 0x00000008
	B	PAbt_Handler	; 0x0000000C
	B	DAbt_Handler	; 0x00000010
	NOP			; 0x00000014
	B	IRQ_Handler	; 0x00000018
	B	FIQ_Handler	; 0x0000001C

;
; Reset Exception Handler
;
Reset_Handler

	;
	; Initialize Stack Pointers (SP) for each mode we are using
	;

	; Stack Top
	LDR	R0, =0x40010000

	; Enter undef mode and set initial SP
	MSR     CPSR_c, #Mode_IRQ:OR:I_Bit:OR:F_Bit
	MOV     SP, R0
	SUB     R0, R0, #Irq_Stack_Size

	; Enter user mode and set initial SP
	MSR     CPSR_c, #Mode_USR
	MOV	SP, R0


	;
	; Initialise peripherals here
	;
	;   Initialise TIMER0 (see timer-int example)
	;   Initialise VIC for TIMER0 interrupts (see timer-int example)
	;   Initialise P2.10 for EINT0 (see button-int example)
	;   Initialise VIC for EINT0 interrupts (see button-int example)
	;   Don't start TIMER0 yet!! We're waiting for a button press
	;

STOP	B	STOP


;
; Software Interrupt Exception Handler
;
Undef_Handler
	B	Undef_Handler

;
; Software Interrupt Exception Handler
;
SWI_Handler
	B	SWI_Handler

;
; Prefetch Abort Exception Handler
;
PAbt_Handler
	B	PAbt_Handler

;
; Data Abort Exception Handler
;
DAbt_Handler
	B	DAbt_Handler

;
; Interrupt ReQuest (IRQ) Exception Handler (top level - all devices)
;
IRQ_Handler
	SUB	lr, lr, #4	; for IRQs, LR is always 4 more than the
				; real return address
	STMFD	sp!, {r0-r3,lr}	; save r0-r3 and lr

	LDR	r0, =VICVectAddr; address of VIC Vector Address memory-
				; mapped register

	MOV	lr, pc		; can’t use BL here because we are branching
	LDR	pc, [r0]	; to a different subroutine dependant on device
				; raising the IRQ - this is a manual BL !!

	LDMFD	sp!, {r0-r3, pc}^ ; restore r0-r3, lr and CPSR

;
; Fast Interrupt reQuest Exception Handler
;
FIQ_Handler
	B	FIQ_Handler


;
; TIMER0 IRQ Handler (device-specific handler called by top-level IRQ_Handler)
;
Timer_Handler

	STMFD	sp!, {r4-r5, lr}

	;
	; your timer irq handler goes here
	; see timer-int example to see how to handle TIMER interrupts
	; load the current time, decrement, store back to memory
	;
	; if the time is 0, reconfigure P2.10 as GPIO output and turn
	;   on the LED
	;

	LDMFD	sp!, {r4-r5, pc}


;
; EINT0 IRQ Handler (device-specific handler called by top-level IRQ_Handler)
;
Button_Handler

	STMFD	sp!, {r4-r5, lr}

	;
	; your EINT0 (button) irq handler goes here
	; see button-int example to see how to handle EINT0 interrupts
	;
	; if this is he first press, you need to start TIMER0
	;   and set the remaining time to 5 seconds
	;
	; otherwise, you need to add another 5 seconds to the remaining time
	;
	; remember, changing the remaining time means loading the remaining
	;   time, changing it and storing it back again
	;

	LDMFD	sp!, {r4-r5, pc}


	AREA	TestData, DATA, READWRITE

time	SPACE	4


	END
