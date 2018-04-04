*********************************************
* Simple 68HC05 Program Example             *
*
* 1s delay between each character
*********************************************
MEMSIZ	EQU	$2000	Address space
START	EQU	$60	Program start

TEMP1	EQU	$50	One byte temp storage location
temp2	EQU	TEMP1+1

baud	equ	$0d
sccr1	equ	$0e
sccr2	equ	$0f
scsr	equ	$10
scdr	equ	$11


	ORG	START	Program will start at START
main:
	lda	#$30
	sta	temp2
mloop:
	lda	#20
mloop2:	jsr	dly50
	deca
	bne	mloop2
	lda	temp2
	jsr	putc
	inca
	and	#$3f
	sta	temp2
	bra	mloop
		
***
* DLY50 - Subroutine to delay ~50mS
* Save original accumulator value
* but X will always be zero on return
***

dly50	STA	TEMP1	Save accumulator in RAM
	LDA	#32	Do outer loop 32 times
OUTLP	CLRX		X used as inner loop count
INNRLP	DECX		0-FF, FF-FE,...1-0 256 loops
	BNE	INNRLP	6cyc*256*1µS/cyc = 1.536mS
	DECA		32-31, 31-30,...1-0
	BNE	OUTLP	1545cyc*32*1µS/cyc=49.440mS
	LDA	TEMP1	Recover saved Accumulator val
	RTS		** Return **



*
*	getc --- get a character from the terminal
*
*	A gets the character typed, X is unchanged.
*
*
getc	brclr	5,scsr,getc	RDRF = 1 ?
	lda	scdr
	rts

*
*	putc --- print a on the terminal
*
*	X and A unchanged
*
putc	brclr	7,scsr,putc	TDRE = 1 ?
	sta	scdr
	rts


reset:
	lda	#%00110000 
	sta	baud	    baud rate to 4800 @2mhz xtal
	lda	#%00000000  set up sccr1	
	sta	sccr1	    store in sccr1 register
	lda	#%00001100  set up sccr2
	sta	sccr2	    store in sccr2 register
	jmp	main


	org	MEMSIZ-10 start of vectors
*
	fdb	reset 	exit wait state
	fdb	reset 	timer interrupt
	fdb	reset	external interrupt
	fdb	reset	swi
	fdb	reset	power on vector

