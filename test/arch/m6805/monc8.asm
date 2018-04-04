*
*		M C 6 8 H C 0 5 C 8   R O M   P A T T E R N
*
*	The monitor is substantially the  same	as  all  previous
*	monitors  for  the 6805.  The monitor uses serial I/O for
*	its communication with the operator.
*
*	The monitor uses serial I/O for its communication with the operator.
*	If on-chip SCI I/O is not used, serial input is  C2 and serial output
*	is C3, with software SCI routines. Baud rates are selected as follows:
*
*		C7  C1	C0   rate
*		--  --	--  --------
*		 1   0	 0   300 baud
*		 1   0	 1   1200 baud
*		 1   1	 0   4800 baud
*		 1   1	 1   9600 baud
*
*-----------------------------------------------------------------------------
*
*	I/O Register Addresses
*
porta	equ	$000	I/O port 0
portb	equ	$001	I/O port 1
portc	equ	$002	I/O port 2
portd	equ	$003	I/O port 3
ddr	equ	   4	data direction register offset (e.g. porta+ddr)
timer	equ	$008	8-bit timer register
tcr	equ	$009	timer control register
RAM	equ	$050	start of on-chip ram
*ZROM	equ	$080	start of page zero rom
ROM	equ	$160	start of main rom
MEMSIZ	equ    $2000	memory address space size

sci	equ	1	* 0 for software sci, 1 for on-chip sci

    IF sci&1
baud	equ	$0d
sccr1	equ	$0e
sccr2	equ	$0f
scsr	equ	$10
scdr	equ	$11
    ENDIF

*
*	Character Constants
*
CR	equ	$0D	carriage return
LF	equ	$0A	line feed
BL	equ	$20	blank
EOS	equ	$00	end of string

	org	ROM
******************************************************************************
*
*	R O M	M O N I T O R  for the	6 8 H C 0 5 C 8
*
*	The monitor has the following commands:
*
*	r --  Print registers.
*	      format is CCCCC AA XX PPP
*
*	a --  Print/change A accumulator.
*	      Prints the register value, then
*	      waits for new value.  Type
*	      any non-hex character to exit.
*
*	x --  Print/change X accumulator.
*	      Works the same as 'A', except modifies X instead.
*
*	m --  Memory examine/change.
*	      Type m AAA to begin,
*		then type: .  -- to re-examine current
*			   ^  -- to examine previous
*			   CR -- to examine next
*			   DD -- new data
*		Anything else exits memory command.
*
*	c --  Continue program.  Execution starts at
*		the location specified in the program
*		counter, and
*		continues until an  swi is executed
*		or until reset.
*
*	e --  Execute from address.  Format is
*		e AAAA.  AAAA is any valid memory address.
*
*	g --  Go from address, same as execute from address.
*
*	s --  Display Machine State.  All important I/O registers are
*		displayed.
*
*
*	Special Equates
*
PROMPT	equ	'.      prompt character
FWD	equ	CR	go to next byte
BACK	equ	'^      go to previous byte
SAME	equ	'.      re-examine same byte
*
*	Other
*
initsp	equ	$fF	initial stack pointer value
stack	equ	initsp-5  top of stack
*
*	ram variables
*
get	equ	RAM+0	4-byte no-mans land, see pick and drop subroutines
atemp	equ	RAM+4	acca temp for getc,putc
xtemp	equ	RAM+5	x reg. temp for getc,putc
char	equ	RAM+6	current input/output character
count	equ	RAM+7	number of bits left to get/send



*
*	state --- print machine state
*
*	 A  B  C  D TIM TCR
*	dd dd dd dd  dd  dd
*
*	header string for I/O register display
*
iomsg	fcb	CR,LF
	fcc	/ A  B	C  D TIM TCR/
*	fcb     20,43,20,20,44,20
*	fcb     54,49,4d,20,54,43
*	fcb     52
	fcb	CR,LF,EOS
*
state	clrx
state2	lda	iomsg,x get next char
	cmp	#EOS	quit?
	beq	state3	yes, now print values
	jsr	putc	no, print char
	incx		bump pointer
	bra	state2	do it again
state3
*
*	now print values underneath the header
*
	clrx
pio	lda	,x	start with I/O ports
	jsr	putbyt
	jsr	putspc
	incx
	cpx	#4	end of I/O?
	bne	pio	no, do more
*
	jsr	putspc
	lda	timer	now print the value in the timer
	jsr	putbyt
	jsr	putspc
	jsr	putspc
	lda	tcr	the control register too
	jsr	putbyt
	bra	monit	 all done
*
*	pcc --- print condition codes
*
*	string for pcc subroutine
*
ccstr	fcc	/HINZC/
*
pcc	lda	stack+1 condition codes in acca
	asla		move h bit to bit 7
	asla
	asla
	sta	get	save it
	clrx
pcc2	lda	#'.
	asl	get	put bit in c
	bcc	pcc3	bit off means print .
	lda	ccstr,x pickup appropriate character
pcc3	jsr	putc	print . or character
	incx		point to next in string
	cpx	#5	quit after printing all 5 bits
	blo	pcc2
	rts
*
*      seta --- examine/change accumulator A
*
seta   ldx	#stack+2 point to A
       bra	setany
*
*      setx --- examine/change accumulator X
*
setx	ldx	#stack+3 point to X
*
*	setany --- print (x) and change if necessary
*
setany	lda	,x	pick up the data, and
	jsr	putbyt	print it
	jsr	putspc
	jsr	getbyt	see if it should be changed
	bcs	monit	 error, no change
	sta	,x	else replace with new value
	bra	monit	 now return
*
*      regs --- print cpu registers
*
regs	bsr	pcc	print cc register
	jsr	putspc	separate from next stuff
	clr	get+1	point to page zero,
	lda	#stack+2
	sta	get+2
	jsr	out2hs	continue print with A
	jsr	out2hs	X and finally the
	jsr	out4hs	Program Counter
*
*	fall into main loop
*
*	monit --- print prompt and decode commands
*
monit	jsr	crlf	go to next line
	lda	#PROMPT
	jsr	putc	print the prompt
	jsr	getc	get the command character
	and	#%1111111 mask parity
	jsr	putspc	print space (won't destroy A)
	cmp	#'a     change A
	beq	seta
	cmp	#'x     change X
	beq	setx
	cmp	#'r     registers
	beq	regs
	cmp	#'e     execute
	beq	exec
	cmp	#'g
	beq	exec
	cmp	#'c     continue
	beq	cont
	cmp	#'m     memory
	beq	memory
	cmp	#'s     display machine state
	bne	monit2
	jmp	state	commands are getting too far away
*
monit2	equ	*
	lda	#'?     none of the above
	jsr	putc
	bra	monit	 loop around
*
*	exec --- execute from given address
*
exec	jsr	getbyt	get high nybble
	bcs	monit	 bad digit
	tax		save for a second
	jsr	getbyt	now the low byte
	bcs	monit	 bad address
	sta	stack+5 program counter low
	stx	stack+4 program counter high
*
*	cont --- continue users program
*
cont	rti		simple enough
*
*      memory --- memory examine/change
*
memory	jsr	getbyt	build address
	bcs	monit	 bad hex character
	sta	get+1
	jsr	getbyt
	bcs	monit	 bad hex character
	sta	get+2	address is now in get+1&2
mem2	jsr	crlf	begin new line
	lda	get+1	print current location
	and	#$1F	mask upper 3 bits (8K map)
	jsr	putbyt
	lda	get+2
	jsr	putbyt
	jsr	putspc	a blank, then
	bsr	pick	get that byte
	jsr	putbyt	and print it
	jsr	putspc	another blank,
	jsr	getbyt	try to get a byte
	bcs	mem3	might be a special character
	bsr	drop	otherwise, put it and continue
mem4	bsr	bump	go to next address
	bra	mem2	and repeat
mem3	cmp	#SAME	re-examine same?
	beq	mem2	yes, return without bumping
	cmp	#FWD	go to next?
	beq	mem4	yes, bump then loop
	cmp	#BACK	go back one byte?
	bne	xmonit	 no, exit memory command
	dec	get+2	decrement low byte
	lda	get+2	check for underflow
	cmp	#$FF
	bne	mem2	no underflow
	dec	get+1
	bra	mem2
*
*	convenient transfer point back to monit
*
xmonit	 jmp	 monit	  return to monit
*
*      utilities
*
*      pick --- get byte from anywhere in memory
*		this is a horrible routine (not merely
*		self-modifying, but self-creating)
*
*      get+1&2 point to address to read,
*      byte is returned in A
*      X is unchanged at exit
*
pick	stx	xtemp	save X
	ldx	#$D6	D6=lda 2-byte indexed
	bra	common
*
*
*	drop --- put byte to any memory location.
*		 has the same undesirable properties
*		 as pick
*	A has byte to store, and get+1&2 points
*	to location to store
*	A and X unchanged at exit
*
drop	stx	xtemp	save X
	ldx	#$D7	d7=sta 2-byte indexed
*
*
common	stx	get	put opcode in place
	ldx	#$81	81=rts
	stx	get+3	now the return
	clrx		we want zero offset
	jsr	get	execute this mess
	ldx	xtemp	restore X
	rts		and exit
*
*	bump --- add one to current memory pointer
*
*	A and X unchanged
*
bump	inc	get+2	increment low byte
	bne	bump2	non-zero means	no carry
	inc	get+1	increment high nybble
bump2	rts
*
*
*	out4hs --- print word pointed to as an address, bump pointer
*		   X is unchanged at exit
*
out4hs	bsr	pick	get high nybble
	and	#$1F	mask high bits
	bsr	putbyt	and print it
	bsr	bump	go to next address
*
*	out2hs --- print byte pointed to, then a space. bump pointer
*		   X is unchanged at exit
*
out2hs	bsr	pick	get the byte
	sta	get	save A
	lsra
	lsra
	lsra
	lsra		shift high to low
	bsr	putnyb
	lda	get
	bsr	putnyb
	bsr	bump	go to next
	bsr	putspc	finish up with a blank
	rts
*
*	putbyt --- print A in hex
*		A and X unchanged
*
putbyt	sta	get	save A
	lsra
	lsra
	lsra
	lsra		shift high nybble down
	bsr	putnyb	print it
	lda	get
	bsr	putnyb	print low nybble
	rts
*
*	putnyb --- print lower nybble of A in hex
*		A and X unchanged, high nybble
*		of A is ignored.
*
putnyb	sta	get+3	save A in yet another temp
	and	#$F	mask off high nybble
	add	#'0     add ascii zero
	cmp	#'9     check for A-F
	bls	putny2
	add	#'A-'9-1 adjustment for hex A-F
putny2	jsr	putc
	lda	get+3	restore A
	rts
*
*	crlf --- print carriage return, line feed
*		 A and X unchanged
*
crlf	sta	get	save
	lda	#CR
	jsr	putc
	lda	#LF
	bsr	putc
	lda	get	restore
	rts
*
*	putspc --- print a blank (space)
*		 A and X unchanged
*
putspc	sta	get	save
	lda	#BL
	bsr	putc
	lda	get	restore
	rts
*
*	getbyt --- get a hex byte from terminal
*
*	A gets the byte typed if  it  was  a  valid  hex  number,
*	otherwise  A gets the last character typed.  The c-bit is
*	set  on  non-hex  characters;	cleared   otherwise.	X
*	unchanged in any case.
*
getbyt	bsr	getnyb	build byte from 2 nybbles
	bcs	nobyt	bad character in input
	asla
	asla
	asla
	asla		shift nybble to high nybble
	sta	get	save it
	bsr	getnyb	get low nybble now
	bcs	nobyt	bad character
	add	get	c-bit cleared
nobyt	rts
*
*	getnyb --- get hex nybble from terminal
*
*	A gets the nybble typed if  it	was  in  the  range  0-F,
*	otherwise  A  gets the character typed.  The c-bit is set
*	on  non-hex  characters;   cleared   otherwise.    X   is
*	unchanged.
*
getnyb	bsr	getc	get the character
	and	#%1111111 mask parity
	sta	get+3	save it just in case
	sub	#'0     subtract ascii zero
	bmi	nothex	was less than '0'
	cmp	#9
	bls	gotit
	sub	#'A-'9-1 funny adjustment
	cmp	#$F	too big?
	bhi	nothex	was greater than 'F'
	cmp	#9	  check between 9 and A
	bls	nothex
gotit	clc		c=0 means good hex char
	rts
nothex	lda	get+3	get saved character
	sec
	rts		return with error
*
*
*	S e r i a l   I / O   R o u t i n e s - SCI
*
*
    IF sci&1		* Use on-chip SCI
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

    ENDIF		* Use on-chip SCI


*
*	S e r i a l   I / O   R o u t i n e s - S/W
*
*	These subroutines are modifications of the original NMOS
*	version.  Differences are due to the variation in cycle
*	time of CMOS instructions vs. NMOS.
*
*	Since the INT and TIMER interrupt vectors are used in the
*	bicycle odometer, the I-bit should  always  be	set  when
*	running  the  monitor.	Hence, the code that fiddles with
*	the I-bit has been eliminated.
*
*
*	Definition of serial I/O lines
*
*	Note: changing `in' or `out' will necessitate changing the
*	way `put' is setup during reset.
*
    IF sci^1		* Use software SCI

put	equ	portc	serial I/O port
in	equ	2	serial input line#
out	equ	3	serial output line#
*
*	getc --- get a character from the terminal
*
*	A gets the character typed, X is unchanged.
*
getc	stx	xtemp	save X
	lda	#8	number of bits to read
	sta	count
getc4	brset	in,put,getc4 wait for hilo transition
*
*	delay 1/2 bit time
*
	lda	put
	and	#%11	get current baud rate
	tax
	ldx	delays,x get loop constant
getc3	lda	#4
getc2	nop
	deca
	bne	getc2
	tstx		loop padding
	bset	in,put	ditto
	bset	in,put	CMOS ditto
	decx
	bne	getc3	major loop test
*
*	now we should be in the middle of the start bit
*
	brset	in,put,getc4 false start bit test
	tst	,x	more timing delays
	tst	,x
	tst	,x
*
*	main loop for getc
*
getc7	bsr	delay	(6) common delay routine
	brclr	in,put,getc6 (5)   test input and set c-bit
getc6	tst	,x	(4) timing equalizer
	nop		(2) CMOS equalization
	nop		(2) CMOS equalization
	nop		(2) CMOS equalization
	nop		(2) CMOS equalization
	nop		(2) CMOS equalization
	nop		(2) CMOS equalization
	ror	char	(5) add this bit to the byte
	dec	count	(5)
	bne	getc7	(3) still more bits to get(see?)
*
	bsr	delay	wait out the 9th bit
	lda	char	get assembled byte
	ldx	xtemp	restore x
*
	rts		and return
*
*	putc --- print a on the terminal
*
*	X and A unchanged
*
putc	sta	char
	sta	atemp	save it in both places
	stx	xtemp	don't forget about X
	lda	#9	going to put out
	sta	count	9 bits this time
	clrx		for very obscure reasons
	clc		this is the start bit
	bra	putc2	jump in the middle of things
*
*	main loop for putc
*
putc5	ror	char	(5) get next bit from memory
putc2	bcc	putc3	(3) now set or clear port bit
	bset	out,put
	bra	putc4
putc3	bclr	out,put (5)
	bra	putc4	(3) equalize timing again
putc4	jsr	delay,x (7) must be 2-byte indexed jsr
*			    this is why X must be zero
	coma		(3) CMOS equalization
	coma		(3) CMOS equalization
	coma		(3) CMOS equalization
	dec	count	(5)
	bne	putc5	(3) still more bits
*
	bset	in,put	 7 cycle delay
	bset	out,put    send stop bit
*
	bsr	delay	delay for the stop bit
	ldx	xtemp	restore X and
	lda	atemp	of course A
	rts
*
*	delay --- precise delay for getc/putc
*
delay	lda	put	first, find out
	and	#%11	what the baud rate is
	tax
	ldx	delays,x loop constant from table
	lda	#$F8	funny adjustment for subroutine overhead
del3	add	#$09
del2
	nop		CMOS equalization
	deca
	bne	del2
	tstx		loop padding
	bset	in,put	ditto
	bset	in,put	CMOS ditto
	decx
	bne	del3	main loop
	nop		CMOS equalization
	nop		CMOS equalization
	rts		with X still equal to zero
*
*	delays for baud rate calculation
*
*	This table must not be put on page zero since
*	the accessing must take 6 cycles.
*
delays	fcb	32	 300 baud
	fcb	8	1200 baud
	fcb	2	4800 baud
	fcb	1	9600 baud

   ENDIF	* Software SCI

*
*
*      reset --- power on reset routine
*
*
*

reset
*
*	run the monitor
*
*
* sci initialization
*
    IF sci&1
	lda	#%00110000 
	sta	baud	    baud rate to 4800 @2mhz xtal
	lda	#%00000000  set up sccr1	
	sta	sccr1	    store in sccr1 register
	lda	#%00001100  set up sccr2
	sta	sccr2	    store in sccr2 register
    ENDIF

    IF sci^1		* Use software SCI
	lda	#%1000	setup port for serial io
	sta	put	set output to mark level
	sta	put+ddr set ddr to have one output
    ENDIF
*
*	print sign-on message
*
	clrx
babble	lda	msg,x	get next character
	cmp	#EOS	last char?
	beq	mstart	yes, start monitor
	jsr	putc	and print it
	incx		advance to next char
	bra	babble	more message
mstart
	swi		push machine state and go to monitor routine
	bra	 reset	loop around
*
*	msg --- power up message
*
msg	fcb	CR,LF
	fcc	/68hc05c8/
	fcb     47,32
	fcb	EOS
	org	MEMSIZ-10 start of vectors
*
	fdb	reset 	exit wait state     \
	fdb	reset 	timer interrupt      |- odometer vectors
	fdb	reset	external interrupt  /
	fdb	monit	swi to main entry point
	fdb	reset	power on vector
