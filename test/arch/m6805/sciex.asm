*********************************************
* Simple 68HC05 SCI Program Example         *
*********************************************

BRATE	EQU	$0D	-,-,SCP1,SCP0;-,SCR2,SCR1,SCR0
SCCR1	EQU	$0E	R8,T8,-,M;WAKE,-,-,-
SCCR2	EQU	$0F	TIE,TCIE,RIE,ILIE;TE,RE,RWU,SBK
SCDAT	EQU	$11	Read - RDR; Write - TDR
SCSR	EQU	$10	TDRE,TC,RDRF,IDLE;OR,NF,FE,-

TEMP	EQU	$A0	One byte temp storage location
TEMPHI	EQU	$A1	Upper byte changed to ASCII
TEMPLO	EQU	$A2	Lower byte changed to ASCII

	ORG	$500	Program will start at $0500

INITIAL	LDA	#%00110000  Begin initialization
	STA	BRATE	    Baud rate to 4800 @2MHz Xtal
	LDA	#%00000000  Set up SCCR1	
	STA	SCCR1	    Store in SCCR1 register
	LDA	#%00001100  Set up SCCR2
	STA	SCCR2	    Store in SCCR2 register
START	JSR	GETDATA  Checks for receive data
	STA	TEMP	Store received ASCII data in temp
	AND	#$0F	Convert LSB of ASCII char to hex
	ORA	#$30	$3(LSB) = "LSB"
	CMP	#$39	3A-3F need to change to 41-46		
	BLS	ARN1	Branch if 30-39 OK
	ADD	#7	Add offset
ARN1	STA	TEMPLO	Store LSB of hex in TEMPLO
	LDA	TEMP	Read the original ASCII data
	LSRA		Shift right 4 bits
	LSRA
	LSRA
	LSRA
	ORA	#$30	ASCII for N is $3N (N=0-9)
	CMP	#$39	3A-3F need to change to 41-46
	BLS	ARN2	Branch if 30-39
	ADD	#7	Add offset
ARN2	STA	TEMPHI	MS nibble of hex to TEMPHI
	LDA	#$0D	Load hex value for "<CR>"
	BSR	SENDATA	Carriage return
	LDA	#$0A	Load hex value for "<LF>"
	BSR	SENDATA	Line feed
	LDA	#'$	Load hex value for "$"
	BSR	SENDATA	Print dollar sign
	LDA	TEMPHI	Get high half of hex value
	BSR	SENDATA	Print
	LDA	TEMPLO	Get low half of hex value
	BSR	SENDATA	Print
	BRA	START	Branch back to start

*** Get an SCI character, return w/ it in A
*
GETDATA	BRCLR	5,SCSR,GETDATA	RDRF = 1 ?
	LDA	SCDAT		OK, get
	RTS			** Return from GETDATA **

*** Send an SCI character, call sub w/ it in A
*
SENDATA	BRCLR	7,SCSR,SENDATA	TDRE = 1 ?
	STA	SCDAT		OK, send
	RTS			** Return **
