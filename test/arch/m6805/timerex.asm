*********************************************
* Simple 68HC05 Timer Program Example       *
*********************************************

DDRC	EQU	$06	Data direction control, port C
PORTC	EQU	$02	Direct address of port C (LED)
OCMPHI	EQU	$16	Output compare high reg.
OCMPLO	EQU	$17	Output compare low reg.
TSR	EQU	$13	ICF,OCF,TOF,0;0,0,0,0

	ORG	$A0	A convenient addr for PGMR board
TENSEC	RMB	1	Used to count 39 out compares
TEMP	RMB 	1	One byte temp for 16 bit OCMP add

	ORG	$350

INIT	LDA	#%01000000  Make DDR bit for LED a one
	STA	DDRC	So Red LED pin is an output
	
BEGIN	LDA	#%01000000  Port C bit 6 is red LED
	EOR	PORTC	Toggle red LED on PGMR board
	STA	PORTC	Red LED will change every 10 Sec
	LDA	#39	10 sec = 38 rev + 9,632 ticks
	STA	TENSEC	Counter for timer out compares 

**********************************************************************
* For XTAL=2MHz (Int proc. clk=1MHz) Timer Ö4 makes 1 count = 4µS    *
* Counter rolls from $FFFF to 0 every 65,536 counts (262.144 mS)     *
* 10 Sec Ö 262.144 mS = 38 revs of timer & 9,632 counts remainder    *
* 10 Sec = 2,500,000 counts @ 4µS/count.  38 * 65,536 = 2,490,368    *
* 2,500,000 - 2,490,368 = 9632.  9632 (decimal) = $25A0              *
*                                                                    *
* To time 10 Sec, read initial count, add 9632 (remainder count)     *
* store to out compare reg ("schedule a compare").  When OCF flag =1 *
* clear it & next compare will occur when timer counts 65,536 counts *
* count the first compare plus 38 more compares (full revs).         *
**********************************************************************

	LDA	#$A0	Lower half hex equiv of 9632
	ADD 	OCMPLO	Low half of a 16 bit add
	STA	TEMP	Temp. store until OCMPHI is added
	LDA	#$25	Upper half hex equiv of 9632
	ADC	OCMPHI	High half of 16 bit add (w/ carry)
	STA 	OCMPHI	Update OCMP hi 
	LDA	TEMP	Get previous saved OCMP low
	STA	OCMPLO	Update OCMP lo after OCMP hi 

**********************************************************************
* You add low half first due to possible carry, then add high byte   *
* including any carry (ADC).  You should update out compare high     *
* byte first to avoid an erroneous compare value (compare lockout    *
* after OCMPHI till OCMPLO prevents this potential problem.          *
**********************************************************************

LOOP	BRCLR	6,TSR,LOOP Checks for out comp. flag
	LDA	OCMPLO	   To clear OCF flag
	DEC	TENSEC	   Ten seconds count down
	BNE	LOOP	   Loop until 10 sec done

	BRA	BEGIN	Repeat so PC6 toggles /10 Sec
