;Source Int. Vector Jump Address
; IC1 $FFEE-$FFEF $00E8
; IC2 $FFEC-$FFED $00E5
; IC3 $FFEA-$FFEB $00E2
; OC1 $FFE8-$FFE9 $00DF
; OC2 $FFE6-$FFE7 $00DC
; OC3 $FFE4-$FFE5 $00D9
; OC4 $FFE2-$FFE3 $00D6
; OC5 $FFE0-$FFE1 $00D3
; TOF $FFDE-$FFDF $00D0

;Example:using interrupts generated
; by TCNT overflow
SBASE	EQU $DFFF
NTIM	EQU 30 ;max number of TOF to count
BELL	EQU $05 ;BELL character
TOF	EQU %10000000 ;timer over flag bit
TOI	EQU %10000000 ;Timer Overflow Interrupt
TFLG2	EQU $1025 ;address of TFLG2
TMSK2	EQU $1024 ;address of TMSK2
TOFVEC	EQU $00D0 ;Int. Jump Table location
	ORG $D000
COUNT RMB 1 ;count the TOF number
	ORG TOFVEC ; interrupt jump table entry
	JMP TOFISR

	ORG $C000
	SEI ;turn interrupts off
	LDS #SBASE ;init stack
	CLR COUNT
	LDAA #TOF ;clear TOF first
	STAA TFLG2
	LDAA #TOI ;enable timer overflow int.
	STAA TMSK2
	CLI ;turn interrupts on
	: ;can perform any useful task
	:

; TOF interrupt service routine
; NOTE CPU registers are automatically saved
; when an interrupt occurs
; NOTE regs are not pushed on stack because that
; is automatic for an interrupt
TOFISR
	INC COUNT
	LDAA COUNT ;check if count=max times
	CMPA #NTIM
	BNE ENDIF
	LDAA #BELL ;else ring the BELL
	JSR RINGBELL
	CLR COUNT
ENDIF LDAA #TOF ;clear TOF
	STAA TFGL2
	RTI ; note NOT RTS
RINGBELL
	;; detail is not important
	RTS
	