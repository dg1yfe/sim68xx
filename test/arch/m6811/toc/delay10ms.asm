;create a 10 ms delay - in 2MHz system, 10 ms = 20,000 E
;clock cycles
TENMS EQU 20000 ;clocks = 10ms
REGS EQU $1000 ;registers and offsets
TCNT EQU $0E
TFLG1 EQU $23
TOC1 EQU $16
OC1F EQU %100000000 ;output compare 1 flag
SBASE EQU $DFFF
ORG $C000
START LDS #SBASE
LDX #REGS
LDD TCNT,X ;get 1st TCNT value
ADDD #TENMS ;add delay desired
STD TOC1,X ;store in TOC1
LDAA #OC1F ;reset flag and wait till set
STAA TFLG1,X
LOOP BRCLR TFLG1,X OC1F LOOP ;wait till flag set
	