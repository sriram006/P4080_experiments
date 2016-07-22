
.extern InterruptHandler	# void InterruptHandler(unsigned long exceptNumber)
.extern __reset

/***************************************************************************
 * Register names
 */
.equ r0,	0
.equ r1,	1
.equ rsp,	1
.equ r2,	2
.equ r3,	3
.equ r4,	4
.equ r5,	5
.equ r6,	6
.equ r7,	7
.equ r8,	8
.equ r9,	9
.equ r10,	10
.equ r11,	11
.equ r12,	12
.equ r13,	13
.equ r14,	14
.equ r15,	15
.equ r16,	16
.equ r17,	17
.equ r18,	18
.equ r19,	19
.equ r20,	20
.equ r21,	21
.equ r22,	22
.equ r23,	23
.equ r24,	24
.equ r25,	25
.equ r26,	26
.equ r27,	27
.equ r28,	28
.equ r29,	29
.equ r30,	30
.equ r31,	31

.globl gInterruptVectorTable, gInterruptVectorTableEnd	#, reset

.section	.intvec	,"awx"

##############################################################################
#
#	isr_prologue
#
#	Saves the necessary registers for an interrupt service routine
#
##############################################################################

isr_prologue: 	.macro

				stwu     rsp,-80(rsp)
				stw      r0,8(rsp)
				mfctr    r0
				stw      r0,12(rsp)
				mfxer    r0
				stw      r0,16(rsp)
				mfcr     r0
				stw      r0,20(rsp)
				mflr     r0
				stw      r0,24(rsp)
				stw      r3,40(rsp)
				stw      r4,44(rsp)
				stw      r5,48(rsp)
				stw      r6,52(rsp)
				stw      r7,56(rsp)
				stw      r8,60(rsp)
				stw      r9,64(rsp)
				stw      r10,68(rsp)
				stw      r11,72(rsp)
				stw      r12,76(rsp)
				mfsrr0   r0
				stw      r0,28(rsp)
				mfsrr1   r0
				stw      r0,32(rsp)

				.endm


##############################################################################
#
#	isr_epilogue
#
#	Restores the necessary registers for an interrupt service routine
#
##############################################################################

isr_epilogue: 	.macro

				lwz      r0,32(rsp)
				mtsrr1   r0
				lwz      r0,28(rsp)
				mtsrr0   r0
				lwz      r3,40(rsp)
				lwz      r4,44(rsp)
				lwz      r5,48(rsp)
				lwz      r6,52(rsp)
				lwz      r7,56(rsp)
				lwz      r8,60(rsp)
				lwz      r9,64(rsp)
				lwz      r10,68(rsp)
				lwz      r11,72(rsp)
				lwz      r12,76(rsp)
				lwz      r0,24(rsp)
				mtlr     r0
				lwz      r0,20(rsp)
				mtcrf    0xff,r0
				lwz      r0,16(rsp)
				mtxer    r0
				lwz      r0,12(rsp)
				mtctr    r0
				lwz      r0,8(rsp)
				addi     rsp,rsp,80
				rfi

				.endm


##############################################################################
#
#	cisr_prologue
#
#	Saves the necessary registers for a critical interrupt service routine
#
##############################################################################

cisr_prologue: 	.macro

				stwu     rsp,-80(rsp)
				stw      r0,8(rsp)
				mfctr    r0
				stw      r0,12(rsp)
				mfxer    r0
				stw      r0,16(rsp)
				mfcr     r0
				stw      r0,20(rsp)
				mflr     r0
				stw      r0,24(rsp)
				stw      r3,40(rsp)
				stw      r4,44(rsp)
				stw      r5,48(rsp)
				stw      r6,52(rsp)
				stw      r7,56(rsp)
				stw      r8,60(rsp)
				stw      r9,64(rsp)
				stw      r10,68(rsp)
				stw      r11,72(rsp)
				stw      r12,76(rsp)
				mfspr    r0,58
				stw      r0,28(rsp)
				mfspr    r0,59
				stw      r0,32(rsp)
				.endm


##############################################################################
#
#	cisr_epilogue
#
#	Restores the necessary registers for a critical interrupt service routine
#
##############################################################################

cisr_epilogue: 	.macro


				lwz      r0,32(rsp)
				mtspr    59,r0
				lwz      r0,28(rsp)
				mtspr    58,r0
				lwz      r3,40(rsp)
				lwz      r4,44(rsp)
				lwz      r5,48(rsp)
				lwz      r6,52(rsp)
				lwz      r7,56(rsp)
				lwz      r8,60(rsp)
				lwz      r9,64(rsp)
				lwz      r10,68(rsp)
				lwz      r11,72(rsp)
				lwz      r12,76(rsp)
				lwz      r0,24(rsp)
				mtlr     r0
				lwz      r0,20(rsp)
				mtcrf    0xff,r0
				lwz      r0,16(rsp)
				mtxer    r0
				lwz      r0,12(rsp)
				mtctr    r0
				lwz      r0,8(rsp)
				addi     rsp,rsp,80
				rfci
				.endm


##############################################################################
#
#	disr_prologue
#
#	Saves the necessary registers for a debug interrupt service routine
#
##############################################################################

disr_prologue: 	.macro

				stwu     rsp,-80(rsp)
				stw      r0,8(rsp)
				mfctr    r0
				stw      r0,12(rsp)
				mfxer    r0
				stw      r0,16(rsp)
				mfcr     r0
				stw      r0,20(rsp)
				mflr     r0
				stw      r0,24(rsp)
				stw      r3,40(rsp)
				stw      r4,44(rsp)
				stw      r5,48(rsp)
				stw      r6,52(rsp)
				stw      r7,56(rsp)
				stw      r8,60(rsp)
				stw      r9,64(rsp)
				stw      r10,68(rsp)
				stw      r11,72(rsp)
				stw      r12,76(rsp)
				mfspr    r0,574
				stw      r0,28(rsp)
				mfspr    r0,575
				stw      r0,32(rsp)
				.endm


##############################################################################
#
#	disr_epilogue
#
#	Restores the necessary registers for a debug interrupt service routine
#
##############################################################################

disr_epilogue: 	.macro


				lwz      r0,32(rsp)
				mtspr    575,r0
				lwz      r0,28(rsp)
				mtspr    574,r0
				lwz      r3,40(rsp)
				lwz      r4,44(rsp)
				lwz      r5,48(rsp)
				lwz      r6,52(rsp)
				lwz      r7,56(rsp)
				lwz      r8,60(rsp)
				lwz      r9,64(rsp)
				lwz      r10,68(rsp)
				lwz      r11,72(rsp)
				lwz      r12,76(rsp)
				lwz      r0,24(rsp)
				mtlr     r0
				lwz      r0,20(rsp)
				mtcrf    0xff,r0
				lwz      r0,16(rsp)
				mtxer    r0
				lwz      r0,12(rsp)
				mtctr    r0
				lwz      r0,8(rsp)
				addi     rsp,rsp,80
				rfdi
				.endm
				
##############################################################################
#
#	mcisr_prologue
#
#	Saves the necessary registers for a machine check interrupt service routine
#
##############################################################################

mcisr_prologue: 	.macro

				stwu     rsp,-80(rsp)
				stw      r0,8(rsp)
				mfctr    r0
				stw      r0,12(rsp)
				mfxer    r0
				stw      r0,16(rsp)
				mfcr     r0
				stw      r0,20(rsp)
				mflr     r0
				stw      r0,24(rsp)
				stw      r3,40(rsp)
				stw      r4,44(rsp)
				stw      r5,48(rsp)
				stw      r6,52(rsp)
				stw      r7,56(rsp)
				stw      r8,60(rsp)
				stw      r9,64(rsp)
				stw      r10,68(rsp)
				stw      r11,72(rsp)
				stw      r12,76(rsp)
				mfspr	 r0,570
				stw      r0,28(rsp)
				mfspr    r0,571
				stw      r0,32(rsp)				
				.endm


##############################################################################
#
#	misr_epilogue
#
#	Restores the necessary registers for a machine check interrupt service routine
#
##############################################################################

mcisr_epilogue: 	.macro


				lwz      r0,32(rsp)
				mtspr    571,r0
				lwz      r0,28(rsp)
				mtspr    570,r0
				lwz      r3,40(rsp)
				lwz      r4,44(rsp)
				lwz      r5,48(rsp)
				lwz      r6,52(rsp)
				lwz      r7,56(rsp)
				lwz      r8,60(rsp)
				lwz      r9,64(rsp)
				lwz      r10,68(rsp)
				lwz      r11,72(rsp)
				lwz      r12,76(rsp)
				lwz      r0,24(rsp)
				mtlr     r0
				lwz      r0,20(rsp)
				mtcrf    0xff,r0
				lwz      r0,16(rsp)
				mtxer    r0
				lwz      r0,12(rsp)
				mtctr    r0
				lwz      r0,8(rsp)
				addi     rsp,rsp,80
				rfmci
				.endm				

gInterruptVectorTable:


##############################################################################
#
#	IVOR0 - 0x0100 critical

#
##############################################################################
		.org	0x100

		cisr_prologue

		li		r3,0x0100
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		cisr_epilogue


##############################################################################
#
#	IVOR1 - 0x0200 Machine Check
#
##############################################################################
		.org 	0x200

        mcisr_prologue

		li		r3,0x0200
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

        mcisr_epilogue


##############################################################################
#
#	IVOR2 - 0x0300 Data Storage
#
##############################################################################
		.org	0x300

		isr_prologue

		li		r3,0x0300
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR3 - 0x0400 Instruction Storage
#
##############################################################################
		.org	0x400

		isr_prologue

		li		r3,0x0400
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR4 - 0x0500 External Interrupt
#
##############################################################################
		.org	0x500

		isr_prologue

		li		r3,0x0500
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR5 - 0x0600 Alignment
#
##############################################################################
		.org	0x600

		isr_prologue

		li		r3,0x0600
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR6 - 0x0700 Program
#
##############################################################################
		.org	0x700

        nop
		isr_prologue

		li		r3,0x0700
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR7 - 0x0800 Floating point unavailable
#
##############################################################################
		.org	0x800

        nop
		isr_prologue

		li		r3,0x0800
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue
		
##############################################################################
#
#	IVOR10 - 0x0900 Decrementer
#
##############################################################################
		.org	0x900

		isr_prologue

		li		r3,0x0900
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR12 - 0x0B00 Watchdog timer interrupt
#
##############################################################################
		.org	0xB00

		cisr_prologue

		li		r3,0x0B00
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		cisr_epilogue
		
##############################################################################
#
#	IVOR8 - 0x0C00 System Call
#
##############################################################################
		.org	0xC00

		isr_prologue

		li		r3,0x0C00
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR11 - 0x0F00 Fixed interval timer
#
##############################################################################
		.org	0xF00

		isr_prologue

		li		r3,0x0F00
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue

##############################################################################
#
#	IVOR14 - 0x1000 	Instruction TLB Miss
#
##############################################################################
		.org	0x1000

		isr_prologue

		li		r3,0x1000
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue
		
##############################################################################
#
#	IVOR13 - 0x1100 	Data TLB Miss
#
##############################################################################
		.org	0x1100

		isr_prologue

		li		r3,0x1100
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		isr_epilogue
		
##############################################################################
#
#	IVOR15 - 0x1500	Debug
#
##############################################################################
		.org	0x1500

        nop
		disr_prologue

		li		r3,0x1500
		lis		r4,InterruptHandler@h
		ori		r4,r4,InterruptHandler@l
		mtlr	r4
		blrl

		disr_epilogue

gInterruptVectorTableEnd:
