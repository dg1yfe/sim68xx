	TTL timing.asm (c) AR 1994

P3	EQU	$0006

	org $f000

*-------------------------------------------------------------------
* main
*-------------------------------------------------------------------
main
	LDS	#$FF		Initialiser Stack Pointer.

	ldaa	#100		;0.01 s * 100 = 1s
	jsr	PAUSE
exit
	jmp	exit


	ttl WDOG
******************************************************************************
***									   ***
***		W A T C	H   D O	G   R E	S E T				   ***
***									   ***
***		Antall klokkepulser:	25				   ***
***									   ***
***	Stack behov: 1 byte ( + 2 for returadresse )			   ***
******************************************************************************
WDOG	PSHA
	LDAA	P3
	ORAA	#%00000010		SETT WATCH DOG BIT HùYT
	STAA	P3
	ANDA	#%11111101		SETT WATCH DOG BIT LAVT
	STAA	P3
	PULA	
	RTS


	ttl PAUSE
******************************************************************************
***									   ***
***		P A U S	E						   ***
***									   ***
***		Pause subrutine.					   ***
***									   ***
***		Parameter inn:	A reg. gir en forsinkelse pÜ A*10 [ms].	   ***
***									   ***
***		Kaller opp:	WDOG					   ***
***									   ***
***		Stack behov: 5 byte ( + 2 for returadresse )		   ***
******************************************************************************
pause
*			# Klokkepulser
PAUSE	PSHA			 4
	PSHB			 4
Pau1	LDAB	#175		 2:::::
Pau2	JSR	WDOG		31::  :
	DECB			 1 :  :
	BNE	Pau2		 3::  :
	DECA			 1    :
	BNE	Pau1		 3:::::
	PULB			 3
	PULA			 3
	RTS			 5

*	Totalt # klokkepulser:
*		A * (175*35+6) + 19  =  6131* A + 19, + 3 fra JSR kall
*	Med en klokkefrekvens paa 614.4 kHz blir forsinkelsen
*		A*9.97884 + 0.03 [ms]


;------------------------------------------------------------------------------
; Interrupt vektorer: loades paa adresse $FFEE
;------------------------------------------------------------------------------
	org $FFEE

	ttl Interrupt vectors
******************************************************************************
***									   ***
***		I N T E	R R U P	T   V E	C T O R	 M A P			   ***
***									   ***
******************************************************************************

	fdb	main		Trap
	fdb	main		SCI (RDRF+ORFE+TDRE)
	fdb	main		TIMER OWERFLOW
	fdb	main		TIMER OUTPUT COMPARE
	fdb	main		TIMER INPUT CAPTURE
	fdb	main		IRQ
	fdb	main		SWI
	fdb	main		NMI
	fdb	main		RESET



