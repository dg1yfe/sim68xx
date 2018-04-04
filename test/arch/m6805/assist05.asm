       ttl    assist05
*
*             Monitor for the 68hc05c family
*
*      Adapted from
*
*             Monitor for the MC146805E2 Evaluation Board
*
*
*         (c) copyright 1985 motorola, inc.
*
*
*      the monitor has the following commands:
*
*       r              print registers
*
*       d              download from standard host
*
*       h              host communication
*
*       a              display/change a register
*
*       x              display/change x register
*
*       c              display/change condition codes
*
*       e              display/change timer data register
*
*       f              display/change timer control register
*
*       p              display/change program counter
*
*       i              display/change irq vector
*
*       j              display/change timer vector
*
*       k              display/change timer vector (wait mode)
*
*       b              display breakpoints
*
*       b n xxxx       set breakpoint n
*
*       b n 0          clear breakpoint 
*
*       t              trace one instruction
* 
*       t xxxx         trace xxxx instructions
*
*       m xxxx         memory examine/change
*
*             type     <cr>  to examine next
*                      ^     to eamine previous
*                      =     to examine same
*                      hh    to change hex data
*                      .     to terminate command
*                      
*      g               continue execution from current pc
*
*      g xxxx          go execute pgm at specified address
*
*
*
*
*
*
*
*
monstr   equ    $1800    start of monitor
ramstart equ    $0050	Start of RAM
stkmax   equ    $00ff	Max. value of stack pointer
*
* Use duart or sci
* For sci, set sci=1, duart=0
* For duart, set sci=0, duart=address of duart
*
*duart   equ    $17f0    duart address
duart	equ	0
sci	equ    1        sci sybolic constant

    IF sci
baud	equ	$0d
sccr1	equ	$0e
sccr2	equ	$0f
scsr	equ	$10
scdr	equ	$11
    ENDIF

numbkp equ    3        number of breakpoints
prompt equ    '>       prompt character
timer  equ    8        timer data register
timec  equ    9        timer control register
*
*             equates
*
*
eot    equ    $04      end of text
cr     equ    $0d      carriage return
lf     equ    $0a      line feed
sp     equ    $20      space
bell   equ    $07      control-g (bell)
swiop  equ    $83      software interrupt op code
jmpop  equ    $cc      extended jump op code
ctla	equ	$01	host communications default terminator
*
*             work ram 
*
*
       org    ramstart

bkptbl rmb    3*numbkp breakpoint table
asave  rmb    1        temp save for a 
swiflg rmb    1        swi function flag
work1  rmb    1        chrin/load/store/putbyt
work2  rmb    1        load/store/putbyte 
addrh  rmb    1        high address byte
addrl  rmb    1        low address byte
work3  rmb    1        load/store/punch
work4  rmb    1        store/punchpunch   
work5  rmb    1        trace/punch
work6  rmb    1        trace
work7  rmb    1        trace
work8  rmb    1        timer restoration
work9  rmb    1        timer restoration
workd  rmb    1        timer restoration
worke  rmb    1        timer restoration
pncnt  rmb    1        punch breakpoint
chksum rmb    1        punch
cmd	rmb	3
total	rmb	1
savea	rmb	1
sava	rmb	1
savex	rmb	1
vecram rmb    12       vectors
dummy	rmb	1	Cleared to get Z=1
*
*
*
*
*
       org    monstr   start of monitor
*
*             monitor base string/table page
*             (must be at the begining of a page)
*
*
*
mbase  equ    *        start of work page in rom
*                      msgup must be the first in the page
msgup  fcc    /assist05c 1.0/  fire-up message
msgnul fcb    eot      end of string
msgerr fcc    /- error -/
       fcb    bell
       fcb    eot
msgpc	fcc	/  Pc  A  X  Cc S/
	fcb	eot
vectab fcb    jmpop
       fdb    tirq
       fcb    jmpop
       fdb    tirq 
       fcb    jmpop
       fdb    irq
       fcb    jmpop
       fdb    swi
*
*
*      g - start execuction
*             also used for p - display/set pc
*
*
cmdg   lda    work4
       bit    #$80
       bne    nodipc   don't display pc if a g command
       jsr    putsp    send a space
       jsr    locstk   obtain current sp-3
       lda    7,x      current pc high
       jsr    putbyt   print pc high in hex
       lda    8,x      current pc low
       jsr    putbyt   print pc low in hex
nodipc jsr    getadr   obtain input address
       bcc    next     do continue if done
gaddr  jsr    locstk   obtain current sp-3t-3       
       lda    addrh    load pc high
       sta    7,x      into stack
       lda    addrl    load pc low
       sta    8,x      into stack also
next   lda    work4
       bit    #$80
       bne    cont     if g command then continue
       jmp    cmdnnl   else just p command - don't continue
cont   jsr    scnbkp   init breakpoint scan parameters
goinsb lda    bkptbl,x load high byte

       cmp    #$00     check to see if empty
       bne    gstore
       lda    bkptbl+1,x  get next byte
       cmp    #$00     really empty?
       beq    gonob

gstore lda    bkptbl,x  go get byte again
       sta    addrh    store high address
sta    lda    bkptbl+1,x load low address
       sta    addrl    load low
       jsr    load     load opccode 
       sta    bkptbl+2,x store into table
       lda    #swiop   replace with opcode
       jsr    store    store in place
gonob  incx            to
       incx            next
       incx            breakpoint
       lda    pncnt    count low
       deca
       sta    pncnt
       bne    goinsb   loop if more
       lda    swiflg   flag breakpoints are in
       coma
       sta    swiflg
       lda    work9    reset control register 
       sta    timec
       lda    work8
       sta    timer    then user enviornment
       lda    workd    then the user's vectors
       sta    vecram+4
       lda    worke
       sta    vecram+5
       rti             restart program
cmdmin jmp    cmderr
*
*
*      m - examine/change memory
*      mchnge - register change entry point
*
*
*
cmdm   jsr    getadr   obtain address value
       bcc    cmdmin   invalid if no address
cmdmlp jsr    prtadr   print out address and space
mchnge bsr    load     load acc w/byte
       jsr    crbyts   print with a space
       jsr    getnyb   see if change wanted
       bcc    cmdmdl   branch no
       jsr    getby2   obtain full byte
       bne    cmdmin   terminate if invalid hex
       bcc    cmdmdl   branch if other delimiter
       bsr    store    store new value
       bcs    cmdmin   branch of store fails
       jsr    chrin    obtain delimiter
*      
*      check out delimiters 
cmdmdl cmp    #$0d     ? to next byte
       beq    cmdmlf   branch if so
       cmp    #'^      ? to previous byte
       beq    cmdmbk   branch if so
       cmp    #'=      ? reexamine same byte
       beq    cmcmpr   branch yes
       cmp    #'.      ? carriage return
       beq    cmdmen1   branch yes
       jsr    pcrlf    all else: give new line
cmdmen jmp    cmdnnl   enter command handler
cmdmbk lda    addrl    ? low byte zero?
       bne    cmdmb2   no, just adjust it
       lda    addrh
       deca
       sta    addrh    down high for carry
cmdmb2 lda    addrl    
       deca
       sta    addrl    down low byte
       bsr    pcrlf    to next line
       bra    cmdmlp   to next byte
cmcmpr bsr    pcrlf
       bra    cmdmlp
cmdmlf lda    #cr      send just a carriage return
       jsr    chrou2   output it
       bsr    ptrup1   up pointer by one
       bra    cmdmlp   to next byte

cmdmen1 jsr	pcrlf
	bra	cmdmen		add crlf to the <.>
*
*
*      load - load into a from address pointer addrh/addrl
*
*             input:  addrh/addrl = address
*
*             output: a=byte from pointed location
*                     x is transparent
*                     work1, work2, work3 used
*
*
load   stx    work1    save x
       ldx    #$c6     c6=lda 2 byte extended
ldstcm stx    work2    put opcode in place
       ldx    #$81     81=rts
       stx    work3    now the return
       jsr    work2    execute built in routine
       ldx    work1    restore x
       rts             and exit
*
*
*      store - store a at address in pointer addrh/addrl
*
*             input:   a=byte to store
*                      addrh/addrl= address
*             output:  c=0 store went ok
*                      c=1 store did not take (not ram)
*                      registers transparent (a not transparent on
*                      invalid store) 
*
*
store  stx    work1    save x
       ldx    #$c7     c7=sta 2 byte extended
       bsr    ldstcm   call store routine
       sta    work4    save value stored
       bsr    load     attempt load
       cmp    work4    valid store?
       beq    strts    branch if valid
       sec             show invalid store
strts  rts             return
*
*
*      ptrup1 - increment memory pointer
*
*
ptrup1 lda    addrl
       inca   
       sta    addrl    increment low byte
       bne    prtrts   non zero means no carry
       lda    addrh
       inca
       sta    addrh    increment high byte
prtrts rts             return to caller
*
*
*      putbyt - print a in hex
*
putbyt sta    work1    save a
       lsra            shift to 
       lsra            left hex
       lsra            digit
       lsra            shift high nybble down
       bsr    putnyb   print it
       lda    work1    
*
*      fall into putnyb
*
*
*      putnyb - print lower nybble of a in hex
*               a,x transparent
*
*
putnyb and    #$f      mask off high nybble
       add    #'0      add ascii zero
       cmp    #'9      check for a-f
       bhi    putny2
       jmp    chrout   ok, send out
putny2 add    #'a-'9-1 adjustment for hex a-f
       jmp    chrout   now send out
*
*
*      pdata   - print monitor string after cr/lf
*      pdata1  - print monitor string
*      pcrlf   - print cr/lf
*      
*       input: x=offset to string in base page
*                      
*
pcrlf  ldx    #msgnul-mbase load null string address
pdata  lda    #cr      prepare carriage return
pdloop jsr    chrout   send next character
pdata1 lda    mbase,x  load next character
       incx            bump pointer up one
       cmp    #eot     end of string?
       bne    pdloop   branch no
       rts             return done
*
*
*      getnyb  - obtain next hex character
*                
*                output:  c=0 not hex character,a=delimiter
*                         c=1 hex input, a=binary value
*                         work1 in use
*
getnyb equ    *
	jsr    chrin    get char
getnyb2 cmp    #'0
	blo    getnch   hex ?
       ora    #$20      mask for upper/lower case

       cmp    #'9
       bls    getnhx
       cmp    #'a       
       blo    getnch
       cmp    #'f
       bhi    getnch

       sub    #7
getnhx and    #$0f     clear ascii bits
       sec 
       rts
getnch clc
       rts
*
* getadr - build any size binary number from input
*          leading blanks skipped
*
* output: cc = 0 no number entered
*              1 addrh/addrl has number
*          a = delimiter
*         a,x volatile
*
* work1 used
*
getadr jsr    putsp
       lda    #$00
       sta    addrh    clear high byte
       bsr    getnyb   obtain first hex value
       bcs    getgtd   branch if got it
       cmp    #$20     is it a space?
       beq    getadr   loop if so
       clc             clear carry
       rts    return   no number
getgtd sta    addrl    initialize low value
getalp bsr    getnyb   obtain next hex
       bcc    getarg   branch if none
       asla            over
       asla            four
       asla            bits
       asla            for shift
       ldx    #4       loop four times
getasf asla            shift next bit
       sta    asave
       lda    addrl
       rola
       sta    addrl    into low byte
       lda    addrh
       rola
       sta    addrh    into hi byte
       lda    asave
       decx            count down
       bne    getasf   loop until done
       bra    getalp   do next hex
getarg sec             show number obtained
       rts
*
* chrin - obtain next input character
*
* output: a = character received
*         x  is transparent
*         nulls ignored
*         all characters echoed out
*
* work1 used
* 
chrin
    IF duart	* Use DUART
	lda	duart+1	get status
	lsra		test rcvr reg flag
	bcc	chrin	loop until char recvd
	lda	duart+3	get character
    ENDIF
    IF sci	* Use SCI
	lda	scsr	get status
	bit	#$20	RDRF
	beq	chrin	loop until char recvd
	lda	scdr	get character
    ENDIF
       and    #$7f     and off parity
       beq    chrin    ignore nulls
       sta    work1
       bsr    chrout   echo character
       lda    work1
       rts
*
* hochrin - obtain next character from host port
*           same characteristics as chrin
*
hochrin
    IF duart
	lda	duart+9		get status
	lsra
	bcc	hochrin		check rdrf
	lda	duart+$0b
	and	#$7f		off with the parity
	rts
    ENDIF
    IF sci
	bra	chrin
    ENDIF

*
*
* puts - print a space character
* x unchanged
*
putsp lda     #sp      load a space char
*
* fall into chrout
* * chrout - send a character to terminal
*          cr has added line feed
*
* input: a = ascii char to send
*
* a nopt transparent
*
chrout cmp    #cr      cr to send ?
       bne    chrou2   
       bsr    chrou2   recursive call for cr
       lda    #lf      send lf char

chrou2  sta     savea 
chrou3
    IF duart
	lda     duart+1  get status register
	bit	#$04	check tdre
	beq	chrou3  branch till done
        lda     savea
        sta     duart+3  write data register
    ENDIF
    IF sci
	lda	scsr
	bit	#$80		TDRE
	beq	chrou3
	lda	savea
	sta	scdr
    ENDIF
	rts

*
*  hosout - send character to host
*
hosout sta savea
chrouh
    IF duart
	lda	duart+9	get status
	bit	#$04		check tdre
	beq	chrouh		branch till done
	lda	savea
	sta	duart+$0b	send character
	rts
    ENDIF
    IF sci
	bra	chrout
    ENDIF

*
* reset - power-on reset routine
*
* init duart (both sides), put out startup msg
*
reset  clrx
       clra
clear  sta   bkptbl,x     clear breakpoint table
       incx
       cpx   #$0a
       bne   clear

       ldx    #11      move vector table to ram to allow changes on fly
rst    lda    vectab,x 
       sta    vecram,x
       decx
       bpl    rst      
*      

    IF duart
	lda 	#$06		mode
	sta 	duart
	sta	duart+8

	lda	#$bb	baud
	sta	duart+1
	sta	duart+9

	lda	#$07	one stopbit
	sta	duart
	sta	duart+8

	lda	#$80	counter mode
	sta	duart+4
	sta	duart+$c
	
	lda	#$08
	sta	duart+5
	sta	duart+$d
	
	lda	#$15	init cmd register
	sta	duart+2
	sta	duart+$a
    ENDIF

    IF sci
*
* sci initialization
*
	lda	#%00110000 
	sta	baud	    baud rate to 4800 @2mhz xtal
	lda	#%00000000  set up sccr1	
	sta	sccr1	    store in sccr1 register
	lda	#%00001100  set up sccr2
	sta	sccr2	    store in sccr2 register
    ENDIF

       jsr    scnbkp   clear breakpoints
*
resren lda    #$0
       sta    swiflg   setup monitor entrance value
       swi             enter monitor
       bra    resren   reenter if 'g'
*
* command handler
*
cmdpdt jsr    pdata    send msg out
cmd1   jsr    pcrlf    to new line
cmdnnl lda    #prompt  ready prompt char
       jsr    chrout   send it out
       jsr    rembkp   remove breakpoints
       jsr    chrin    get char from user
       ora    #$20     mask for uc or lc
       clrx            zero for some commands
       cmp    #$0d     ignore a cr
       beq    cmdnnl
       cmp    #'c      dis/chg cc reg ?
       beq    cmdc
       cmp    #'x      dis/chg x reg ?
       beq    cmdx
       cmp    #'a      dis/chg a reg
       beq    cmda
       cmp    #'r      display all registers
       bne    notv
       jmp    regr
notv   cmp    #'g      go ?
       bne    notg
       lda    work4
       ora    #$80
       sta    work4
isp    jmp    cmdg     go to it
*
notg   cmp    #'m      memory display/change ?
       bne    notm
       jmp    cmdm
notm   cmp    #'t      trace ?
       bne    notw
       jmp    cmdt
notw   equ    *        
       cmp    #'b      breakpoint command ?
       beq    bpnt     yes
       cmp    #'p      pc command ?
       bne    notp
       lda    work4
       and    #$7f
       sta    work4
       bra    isp
*
notp   equ    *
       cmp    #'e     display/change timer data
       beq    cmde
       cmp    #'f      display/change timer control
       beq    cmdf
       cmp    #'i      displ/chng interrupt vector
       beq    cmdi
       cmp    #'j      displ/chng timer vector
       beq    cmdj
	cmp	#'d		download
	beq	downld
	cmp	#'h		host comm
	beq	hostit
       cmp    #'k      displ/chng timer wait vector 
       bne    cmderr
       jmp    cmdk
*
cmderr ldx    #msgerr-mbase load error string
tocpdt jmp    cmdpdt        and send it out
regr   jmp    cmdr
bpnt   jmp    cmdb
downld	jmp	down
hostit	jmp	host
*
* x - display/change x register
*
cmdx   incx
*
* a - display change acc
*
cmda   incx
*
* c - display/change cc register
*
cmdc   jsr    putsp    space before value
       stx    work1    save index value
       jsr    locstk   locate stack address
       txa             stack-2 to a
       add    work1    add proper offset
       add    #4       make up for address return difference
       sta    addrl    and set inlow
       lda    #$0
       sta    addrh
tomchg jmp    mchnge   now enter memory change command
*
* e - display/change timer data register
*
cmde   jsr    putsp    give a space
       lda    #work8/256  highhbyte of work8 address *******
       sta    addrh    save in memory pointer
       lda    #work8%256  low byte of work88address
       sta    addrl    save in memory pointer
       jmp    mchnge   handle as memory change
*
* f - display/change timer control register
*
cmdf   jsr    putsp    give a space
       lda    #work9/256  hi byte of work9 address ******
       sta    addrh
       lda    #work9%256  lo byte of work9 address
       sta    addrl
       jmp    mchnge   handle as memory change
*
* i - display/change interrupt vector
*
cmdi   jsr    putsp    give a space
       lda    vecram+7 get current vector hi byte
       jsr    putbyt   display it
       lda    vecram+8 get lo byte
       jsr    putbyt   display it
       jsr    putsp    separate with a space
       jsr    getadr   get address from user
       bcc    cmdinc   no number entered ?
*
cmdiok sta    vecram+7 save hi byte of vector
       lda    addrl    get lo byte 
       sta    vecram+8 save lo byte of vector
*
cmdinc jmp    cmdnnl   return to command handler
*
* j - display/change timer interrupt vector
*
cmdj   jsr    putsp    give a space
       lda    workd    get user vector hi byte
       jsr    putbyt   display in hex
       lda    worke    get user vector lo byte
       jsr    putbyt   display in hex
       jsr    putsp    give a space
       jsr    getadr   get address  from user
       bcc    cmdjnc   no number ?
cmdjok equ    *
       sta    workd    save hi byte
       lda    addrl
       sta    worke
cmdjnc jmp    cmdnnl   return to command handler
*
* k - display/change timer wait mode vector
*
cmdk   jsr    putsp    give a space
       lda    vecram+1 get current vector hi byte
       jsr    putbyt   display it in hex
       lda    vecram+2 getllo byte
       jsr    putbyt   display in hex
       jsr    putsp    give a space separation
       jsr    getadr   get new vector from user
       bcc    cmdknc   no number input ?
*
cmdkok equ    *
       sta    vecram+1 save hi byte of new vector
       lda    addrl    get lo byte
       sta    vecram+2 save lo byte
*
cmdknc jmp    cmdnnl   return to command handler
*
* swi handler
*
* determine processing swiflg value
*
swi    lda    timec    save user timer environemt
       sta    work9    first the control register
       lda    #$40     then mask timer
       sta    timec
       lda    timer    then save the timer register
       sta    work8
       lda    vecram+4 then save users vector
       sta    workd
       lda    vecram+5
       sta    worke
       lda    #tirq/256   set timer vector for monitors use ******
       sta    vecram+4
       lda    #tirq%256
       sta    vecram+5
       clrx            default to startup msg
       lda    swiflg   is this reset
       bne    swichk   if not, remove breakpoints
       inca
       sta    swiflg   show we are now initialized
       jmp    cmdpdt     to command handler
*
swichk jsr    scnbkp
swirep lda    bkptbl,x restore opcode
       bmi    swinob
       sta    addrh
       lda    bkptbl+1,x
       sta    addrl
       lda    bkptbl+2,x
       jsr    store
*
swinob incx
       incx
       incx
       lda    pncnt
       deca
       sta    pncnt
       bne    swirep
*
* trace one instruction if pc at a breakpoint
*
       jsr    locstk   findsstack
       lda    8,x      get pc and adjust
       sub    #1
       sta    work4    save pc low byte
       lda    7,x
       sbc    #0
       sta    work3    save pc hi byte
       stx    work5
       jsr    scnbkp
*
switry lda    bkptbl,x
       bmi    swicmp
       cmp    work3
       bne    swicmp
       lda    bkptbl+1,x
       cmp    work4
       bne    swicmp
       ldx    work5
       sta    8,x
       lda    work3
       sta    7,x
       lda    #$0
       sta    work7
       lda    #1
       sta    work6
       jmp    trace
*
swicmp incx
       incx
       incx
       lda    pncnt
       deca
       sta    pncnt
       bne    switry
*
* fall into register display for breakpoint
*
* r - display registers
*
cmdr	jsr	pcrlf		add text for register displays
	stx	savex
	ldx	#msgpc-mbase
	jsr	pdata
	ldx	savex
	jsr	pcrlf

	jsr    putsp    give a space
       bsr    locstk   locate stack-4
       lda    7,x
       sta    7,x
       jsr    putbyt   display in hex
       lda    8,x      offset into pc lo byte
       bsr    crbyts   to hex and space
       lda    5,x      offset to accc
       bsr    crbyts   to hex and space
       lda    6,x      offset to x reg
       bsr    crbyts
       lda    4,x      offset to cc reg
       ora    #$e0     set unused bits on
       sta    4,x      restore
       bsr    crbyts   hex and space
       txa    stack    pointer -3
       add    #8       to users stack pointer
       bsr    crbyts   hex and space
gtocmd jmp    cmd1     return to command handler
*
* print address subroutine (x unchanged)
*
prtadr lda    addrh    load hi byte
       jsr    putbyt   displayphex
       lda    addrl    load lo byte
crbyts jsr    putbyt   hex out
       jmp    putsp    follow with a space
*
* locstk - locate callers stack pointer
*
* returns x=stack pointer-3
*
* a volatile
*
locstk bsr    locst2   leave address on stack
stkhi  equ    */256	hi byte on stack *******
stklow equ    *%256	low byte on stack
       rts
*
* locst2 - search stack area for (stkhi,stklow)
*
locst2 ldx    #stkmax  loaddhigh stack word address
loclop lda    #stkhi   high byte for compare
locdwn decx            to next lower byte in stack
       cmp    ,x       this the same ?
       bne    locdwn   if not, try next lower
       lda    #stklow  compare with low address byte
       cmp    1,x      found return address ?
       bne    loclop   loop if not
       rts
*
* b - breakpoint clear, set, or display
*
cmdb   jsr    chrin    read next character
       cmp    #$20     display only ?
       bne    bdsply   branch if so
       bsr    pgtadr   obtain breakpoint number
       tstx            any high byte value
       bne    bkerr    if so, error
       deca            down count by one
       cmp    #numbkp  too high ?
       bhs    bkerr    if so, error
       asla            times two
       add    addrl    plus one for three times
       deca
       sta    work2    save address
       bsr    pgtadr   obtain address
       ldx    work2    reload entry pointer
       sta    bkptbl+1,x save low address
       bne    bknocl   branch if not zero
       lda    addrh    load high address
       bne    bkncr    branch not null a
       sta    bkptbl,x store as high byte
       jmp    cmd1     end command
*
bknocl lda    addrh    load high address
bkncr  sta    bkptbl,x store high byte
       jsr    load     load byte at the address
       coma            invert it
       jsr    store    attempt store
       bcs    bkerr1   error if did not store
       coma            restore proper value
       jsr    store    store it back
       bra    gtocmd   end command
*
* display breakpoints
*
bdsply jsr    scnbkp   prepare scan of table
bdsplp lda    bkptbl,x obtain high byte
       cmp    #$00     see if cleared
       bne    godisp   it's not, go display em
       lda    bkptbl+1,x  what about lower byte
       cmp    #$00        is it a 00 also
       beq    bdskp       yep, its unused slot

godisp lda    bkptbl,x   go get 1st byte againo
       jsr    putbyt   print out high byte
       lda    bkptbl+1,x load low byte
       bsr    crbyts   print it out with a space
*
bdskp  incx            to next entry
       incx
       incx
       lda    pncnt
       deca
       sta    pncnt    count down
       bne    bdsplp   loop if more
       jmp    cmd1   end command
bkerr  jmp    cmderr   give error response

bkerr1 clra
       sta    bkptbl,x
       sta    bkptbl+1,x     clear out old stuff
       bra    bkerr
*
pgtadr jsr    getadr   obtain input address
       bcc    bkerr    abort if none
       ldx    addrh    ready high byte
       lda    addrl    ready low byte
       rts
*
* t - trace instruction(s) command
*
cmdt   lda    #1       default count
       sta    addrl    to one get adr clears addrh
       jsr    getadr   build address if any
       lda    addrh    save value in temporary
       sta    work7    locations for later
       lda    addrl    
       sta    work6
*
* setup timer to trigger interrupt
*
trace  equ    *
       jsr    locstk
       lda    4,x      get current user i mask
       and    #8
       sta    work5
       lda    7,x      get current user pc
       sta    addrh
       lda    8,x
       sta    addrl
       jsr    load     get opcode
       cmp    #$83     swi ?
       bne    trace3   ifsso, inc user pc
       lda    addrl
       add    #1       
       sta    8,x
       lda    addrh
       adc    #0
       sta    7,x
       bra    tirq     continue to trace
*
trace3 cmp    #$9b     sei ?
       bne    trace2   if so, set it in the stack
       lda    4,x
       ora    #8
       sta    4,x
       lda    addrl
       add    #1
       sta    8,x
       lda    addrh
       adc    #0
       sta    7,x
       bra    tirq     continue to trace
*
trace2 cmp    #$9a     cli ?
       bne    trace1
       lda    #$0
       sta    work5
*
trace1 lda    4,x
       and    #$f7
       sta    4,x
       lda    #16      then setup timer
       sta    timer
       lda    #8
       sta    timec
       rti             execute one instruction
*
* tirq - timer interrupt routine
*
tirq   equ    *
       lda    #$40     restore i mask to proper state
       sta    timec
       jsr    locstk
       lda    4,x
       ora    work5
       sta    4,x     
*
* see if more tracing is desired
*
       lda    work6
       deca
       sta    work6
       bne    trace
       lda    work7
       beq    disreg
       deca
       sta    work7
       bra    trace
disreg jmp    cmdr
*
* int - interrupt routine
*
irq    equ    *
       jmp    cmderr   hardware interrupt unused
*
* twirq - timer interrupt routine - wait mode
*
twirq  equ    *
       jmp    cmderr   timer wait interrupt unused
*
* delbpk - delete breakpoint subroutine
*
rembkp bsr    scnbkp   setup parameters
       bpl    remrts   return if not in
remlop lda    bkptbl,x load high address
       bmi    remnob   skip if null
       sta    addrh
       lda    bkptbl+1,x load low address
       sta    addrl
       lda    bkptbl+2,x  load opcode
       jsr    store
*
remnob equ    *
       incx            to next entry
       incx
       incx
       lda    pncnt
       deca
       sta    pncnt    count down
       bne    remlop   loop if more
       lda    swiflg   make positive to show removed
       coma   
       sta    swiflg
remrts rts
*
* setup for breakpoint table scan
*
scnbkp equ    *
       lda    #numbkp
       sta    pncnt
       clrx
       lda    swiflg
       rts

iserr0 jmp	cmderr
*
********************************************************
*
*	download from standard host only
*		D <command> <cr>
*
********************************************************
*
down	jsr	pcrlf		start new line on terminal
	jsr	chrin		get 1st char after "d"

load1	cmp	#$0d		is it <cr>?
	beq	iserr0		yes - error
	cmp	#$20		no, is it a space?
	bne	load2		no, start of command
	jsr	chrin		yes, extract lead character
	bra	load1		test for valid start character

load0	jsr	chrin		get next char in buffer from term
load2	jsr	hosout		go send to host
	cmp	#$0d		ready, at end of command?
	bne	load0		no, get next character
	jsr	pcrlf		clear line for him
	jmp	cmdlt		go check for s1-s9

*
*	clbyte -
*
*	load subroutne to read next byte, adjust
*	checksum, and decrement count

*	output:            A = Byte
*                     cc = reflects count decrement
*

clbyte	jsr	hgetbyt		obtain next byte from host
	bcs	clbyt1		if one
	jmp	cmdmin		error if none
clbyt1	sta	work2		save value
	add	chksum		add to checksum
	sta	chksum		replace
	lda	work2		reload value
	decx			count down
	rts
*
*	hgetbyt - ready byte in hex subroutine gotten from host
*
*		output:  c=0,z=1   no number
*		         c=0,z=0   invalid number
*		         c=1,z=1   A=binary byte value
*
hgetbyt	jsr	getnyb1		get next hex digit
	bcc	hgetbrz		return no number
hgetby2	asla			shift
	asla			over
	asla			by
	asla			four
	sta	work2
	jsr	getnyb1		getlow hex
	tsta			force z=0
	bcc	hgetbrt		return if invalid number
	ora	work2		combine hex digits
hgetbrz	clr	dummy		set z=1
hgetbrt	rts			return to caller

getnyb1	jsr	hochrin		get input from host
	jsr	getnyb2		make sure it's ok
	rts


*
*	getbyt - same as above, but done for term port
*
getby2	asla
	asla
	asla
	asla
	sta	work2
	jsr	getnyb	Returns c=0/1 for invalid/valid hex char
*
* The code here would not run on 6805 simulator as it was,
* either by a difference 6800/6805 (small chance),
* or this program was not initially bug free
*
* code removed marked '---', code added marked '+++'
*
*---	tsta		Force z=0? will fail if a=00, also sets c=0 on 6800
	bcc	getbrt
	ora	work2
getbrz	clr	dummy	Set z=1 (and c=0)
	sec		*+++ Set c=1
getbrt	rts




*
*
*	search for an 'S'
*
cmdlt	jsr	hochrin		read a character from host
cmdlss	cmp	#'S		is it an s?
	bne	cmdlt		loop if not
	jsr	hochrin		read second character
	cmp	#'9		is it a 9?
	beq	cleof		branch to end of file
	cmp	#'1		an s1 record?
	bne	cmdlss		nope, try again
*
*	read address and count
*
	lda	#$00
	sta	chksum		zer0 checksum
	jsr	clbyte		obtain size of record
	tax			start countdown in x reg
	jsr	clbyte		obtain start address
	sta	addrh		store it
	jsr	clbyte		obtain low address
	sta	addrl		store it
*
*	now load text
*
clload	jsr	clbyte		next char
	beq	cleor		branch if count done
	jsr	store		store character
	jsr	ptrup1		up address pointer
	bra	clload		loop until count depleted
*
*	end of record
*
cleor	lda	chksum
	inca
	sta	chksum
	beq	cmdlt
	jmp	cmderr
*
*	end of file
*
cleof	jsr	clbyte		read s9 length
	tax			prepare s9 flush count
cleofl	jsr	clbyte		skip hex pair
	bne	cleofl		branch more
	jmp	cmd1	





*
******************************************************************
*
*	"h"	host communications
*
*	     h [<exit char>]
*
*****************************************************************
*
host
    IF duart
	ldx	#ctla		default terminator
	jsr	chrin		go get next character
	cmp	#$0d		cr?
	beq	strm		yes, set default terminator
	tax
strm	stx	sava		save it
	jsr	pcrlf		new line
host1	bsr	tsthst		test for host input
*
*	test for terminal input
*
tsttrm	lda	duart+1		terminal input?
	rora			shift rxrdy to carry bit
	bcc	host1		nope, check host
	lda	duart+3		yep, get character
	tax			save it (parity unmasked)
	and	#$7f		now mask
	cmp	sava		char = terminator?
	beq	mtop		yep, terminate mode.
dowth	lda	duart+9		get status of host mode
	bit	#$04		
	beq	dowth		wait till ready to xmit
	stx	duart+$0b	send it!
	bra	host1		continue
  ENDIF

mtop	jmp	cmd1		* Immediately return

  IF duart
*
*	test for host input
*
tsthst	lda	duart+9		host input?	
	rora			shift rxrdy to carry bit
	bcc	return		no char pending
	ldx	duart+$0b	yep, get character
tstwait	lda	duart+01		status of terminal port?
	bit	#$04		wait till txrdy
	beq	tstwait		
	stx	duart+3		send the char to the terminal
return	rts
  ENDIF

*
* interrupt vectors
*
       org    $1ff6
*
       fdb    vecram   timer interrupt wait mode
       fdb    vecram+3 timer interrupt
       fdb    vecram+6 external interrupt handler
       fdb    vecram+9 swi handler
       fdb    reset    power-on vector
*
       end

