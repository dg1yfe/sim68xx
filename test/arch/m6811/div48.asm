*  Demonstration program for 24 bit multiplication with 48 bit result
*  and 24 bit division of a 48 bit dividend.
*
*  The multiplication routine is typical for 6803 class machines.
*
*  The division routine is unusual in that it uses the divide instruction
*  of the 68HC11 to find a trial divisor, proceeding by bytes until the
*  division is complete.   A divide takes about 800us.    The code is
*  lengthy -- size was traded for speed.
*
*  If you find an error or you improve these routines by making them
*  faster and shorter or if you have an approach which is faster,
*  please contact me.
*
*     John Moran                (203)-575-3016
*     Bristol Babcock Inc.
*     1100 Buckingham St.
*     Watertown, Conn. 06795
*
*
* -----------------------------------------------------------------
* Definition of RAM use, assumes M68HC11EVB Evaluation Board
	ORG $DD00      ; Start of RAM.
CNTR     RMB 1  ; Counter for mul/div
DIVPTR   RMB 2  ; Ptr to MS byte of divisor
DIVCNT   RMB 1  ; Number of bytes in the divisor
DVDCNT   RMB 1  ; Number of bytes in the dividend
QPTR     RMB 2  ; Ptr to current byte of quotient
QCNT     RMB 1  ; Number of bytes remaining to be found in quotient
TRIALQ   RMB 1  ; Current quotient trial value

	ORG $DD50      ; Temp storage for multiply
A24      RMB 3  ; Argument for multiple precision mul
B24      RMB 3  ; Argument for multiple precision mul
A48      RMB 6  ; Product from multiple precision mul

	ORG $DD60      ; Temp storage for  divide
D24      RMB 3  ; Divisor
Q24      RMB 3  ; Quotient - Must immediately precede dividend
D48      RMB 6  ; Dividend

	ORG $DD70      ; Temp storage for  divide
TEMP     RMB 2  ; Work space for divide
*
*
* -----------------------------------------------------------------

* BUFFALO's terminal I/O Hooks
OUT1BYT  EQU    $FFBB
OUT1BSP  EQU    $FFBE
OUTSTRG  EQU    $FFC7
OUTCRLF  EQU    $FFC4
*
* =================================================================
* Code space  - at C000-DFFF for debug. 
	ORG $C000
* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
* Test routine entries:

         BRA    DIVTST  ; Use output of last multiply as dividend
         BRA    MUL24
         BRA    DIV24J


DIV24J:  JMP    DIV24   ; Extend branch range

* - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

*   Calculate the 48 bit unsigned product of two 24 bit unsigned numbers.
*   Place the multiplicand in A24, the multiplier in B24, then JSR MUL24.
*   Result is returned in A48.  Put smaller value in B24 when given a 
*   choice.
*             Note: A48 must immediately follow B24 in memory !!!!
*   B24 may overlap A48 to save space if desired - some changes req'd.
*   The approach used is similar to multiplication with pencil and paper,
*   where bytes are used as if they were digits. It may be extended to
*   any reasonable number of bytes quite easily.

MUL24:   PSHB           ; Preserve regs
         PSHA
         PSHX
         LDX    #B24    ; Address of args
         CLR    3,X     ; Clear A48
         CLR    4,X
         CLR    5,X
         CLR    6,X
         CLR    7,X
         CLR    8,X
         LDAA   #3      ; # bytes in multiplier
         STAA   CNTR
         OPT c
MULOOP:  LDAA   2,X
         BEQ    MULUP2  ; Skip if 0 multiplier
         LDAB   A24+2   ; Least signifigant byte of multiplicand
         MUL
         ADDD   7,X
         STD    7,X
         BCC    MUL1
         INC    6,X     ; Propagate the carry
         BNE    MUL1
         INC    5,X
MUL1:    LDAA   2,X
         LDAB   A24+1
         MUL
         ADDD   6,X
         STD    6,X
         BCC    MUL2
         INC    5,X     ; Propagate Carry
MUL2:    LDAA   2,X
         LDAB   A24     ; Most signifigant byte
         MUL
         ADDD   5,X
         STD    5,X     ; No carry possible on hi end
MULUP2:  DEX            ; Move left 1 byte in multiplier & result
         DEC    CNTR
         BNE    MULOOP
         PULX           ; Restore regs
         PULA
         PULB
         RTS

         OPT noc
*
*
*        This is a test routine for MUL24 and DIV24.
*        It calculates the product of two 24 bit numbers and then
*        divides this product by each of the original factors, checking
*        to ensure that the result is the other factor. It halts if an
*        error is found. You can insert breakpoints if an error is found
*        and then start again at C000 (Don't reload!!!) and it will 
*        repeat the offending calculation. 
*
*        Takes about 2ms for the multiply and 2 divides.
*
*        After each successful test, the factors are adjusted by adding
*        a prime number to select the next numbers to test.
*        
*        I let this test run for 9 days to check these routines.
*
DIVTST:  JSR    MUL24   ; CALCULATE PRODUCT
         LDD    A24
         STD    D24
         LDAB   A24+2
         STAB   D24+2
         JSR    DIVPROD
         LDAB   B24
         CMPB   Q24
         BNE    FAIL    ; QUIT IF ERROR
         LDAB   B24+1
         CMPB   Q24+1
         BNE    FAIL
         LDAB   B24+2
         CMPB   Q24+2
         BNE    FAIL
         LDD    B24     ; CHECK THE MULTIPLIER TOO
         STD    D24
         LDAB   B24+2
         STAB   D24+2
         JSR    DIVPROD
         LDAB   A24
         CMPB   Q24
         BNE    FAIL    ; QUIT IF ERROR
         LDAB   A24+1
         CMPB   Q24+1
         BNE    FAIL
         LDAB   A24+2
         CMPB   Q24+2
         BNE    FAIL
* Looks OK, calculate next numbers to use as factors
BUMPA:   LDD    #593    ; Prime number
         ADDD   A24+1
         STD    A24+1
         BCC    BUMPB
         INC    A24     ; Propagate carry
         BEQ    BUMPA   ; Avoid 0
BUMPB:   LDX    #B24 
         INC    2,X     ; 1 is prime
         BNE    BMPDUN
         JSR    PRINT   ; Show that we're still OK
         INC    1,X
         BNE    BMPDUN
         INC    0,X
         BEQ    BUMPB   ; Avoid 0
BMPDUN:  JMP    DIVTST  ;             LOOP FOREVER

*        Quotient didn't match one of the factors
FAIL:    BSR    PRINT
         LDX    #FAILSTR
         JSR    OUTSTRG ; Announce the failure
DIE:     NOP            ; Simulate a halt
         JMP    DIE

PRINT:   PSHX
         LDX    #A24    ; PRINT THE LAST ITEMS MULTIPLIED
         JSR    OUT1BYT
         JSR    OUT1BYT
         JSR    OUT1BSP
         JSR    OUT1BYT
         JSR    OUT1BYT
         JSR    OUT1BSP
         JSR    OUTCRLF
         PULX
         RTS

FAILSTR  FCC    ' FAIL'
         FCB    04

*


DIVPROD: LDX    #A48    ; Copy product to dividend
         LDAA   #6      ; 6 bytes = 48 bits
DIVTLP:  LDAB   0,X
         STAB   $10,X
         INX
         DECA
         BNE    DIVTLP
*                        ; Drop into divide subroutine
*
*
* Calculate the 24 bit unsigned quotient resulting from division of a
* 48 bit dividend by a 24 bit divisor. Place the divisor in D24 and the
* dividend in D48. The result will be returned in Q24.

*   The approach is similar to long division by hand, but here the
* IDIV instruction is used to form the trial quotient. Care is taken
* to ensure that the trial quotient is always <= the required quotient.

* The division routine can be modified to handle any reasonable number
* of bytes, but it is more challenging than extending the multiplication
* routine.

*   Typical operation is two passes through the loop per byte in the
* dividend.


DIV24:   PSHB
         PSHA
         PSHX
         CLR    Q24     ; Clear quotient to 0
         CLR    Q24+1
         CLR    Q24+2
         LDAB   #6      ; Size of dividend, max
         LDY    #D48    ; Count bytes in the dividend
DIV0:    TST    0,Y
         BNE    DIV1
         DECB
         BEQ    DIVER1  ; Done if dividend = 0, Return 0
         INY
         BRA    DIV0

DIVER1:  JMP    DIVBY0  ; Extend branch range

*  Find size of divisor and dividend & thus the hi byte of quotient.
*  Also do gross checks to avoid dividing by 0, etc.
DIV1:    STAB   DVDCNT  ; Save # bytes in dividend
         LDAA   #$FF
         NEGB
         ADDD   #D48+5  ; + Addr of LS Byte-1 in dividend
         XGDY           ; Y points to MSB of dividend
         LDA    #3      ; Count bytes in the divisor
         LDX    #D24
DIV1CT:  TST    0,X
         BNE    DIV2
         DECA
         BEQ    DIVER1  ; Quit if divide by 0, Return 0
         INX
         BRA    DIV1CT

DIV2:    STX    DIVPTR  ; Ptr to MSB of divisor
         STA    DIVCNT  ; Number of bytes in divisor
         SUBA   DVDCNT
         BGT    DIVER1  ; Quit if divisor > dividend, Return 0
         LDAB   1,Y     ; Get hi byte of dividend
         CMPB   0,X     ; IF hi byte of dividend > hi byte of divisor
         BLO    DIV3    ;  THEN one more byte needed in the quotient
         DECA
         DEY            ;  and in Dividend
DIV3:    TAB
         NEGA           ; Make it positive
         STAA   QCNT    ; # Bytes in quotient
         CMPA   #4      ; ??? MAKE THIS PREVENT OVERFLOW ???
         BGT    DIVER1  ; Quit if quotient too big, return 0
         LDAA   #$FF    ; Make it a negative 16 bit value
         ADDD   #Q24+2  ; Ptr to hi byte of quotient
         STD    QPTR

*  Decide whether to use 1 or 2 bytes as trial divisor
DIVLUP:  LDX    DIVPTR  ; Get ptr to MSB of divisor
         LDAA   DIVCNT  ; Get # bytes in divisor
         DECA
         BEQ    DIV1BY  ; Only 1 byte in divisor
         STA    CNTR    ; Temp, # bytes in divisor -1
         LDD    1,Y     ; Get hi word of dividend in B
         CPD    0,X     ; IF hi word of dividend < hi word of divisor
         BLO    DIVBYB  ;  THEN use only MSB of divisor
         BHI    DIVW2B  ; Divisor < Dividend  & 2+ bytes in divisor
         LDA    CNTR
         DECA
         BEQ    DIVWRD  ; BR if divisor = MSB's of dividend
         LDAB   3,Y     ; Get next byte of dividend in B
         CMPB   2,X     ; IF next byte of dividend < this byte of divisor
         BLO    DIVBYB  ;  THEN use only MSB of divisor, rounded up
         LDAB   #1      ;  ELSE Trial Quotient = 1
         BRA    DIVSTO

DIVBYB:  JMP    DIVBYT  ; Extend branch range
DIV1BY:  JMP    DIV1BYT

*  Trial divisor is 2 bytes. Round up if required.
DIVW2B:  LDA    CNTR
         DECA           ; Make A = 0 if exactly 2 bytes in divisor
DIVWRD:  LDX    0,X     ; Get MSW of divisor
         TSTA
         BEQ    DIVWNR  ; BR if exactly 2 bytes in divisor
         INX            ; Round divisor up
DIVWNR:  LDD    1,Y     ; Get MSW of dividend
         IDIV
         XGDX           ; Get trial quotient into B
*  Multiply divisor by trial quotient and subtract from dividend
DIVSTO:  STAB   TRIALQ  ; Save trial quotient
         LDX    QPTR
         ADDB   0,X     ; Add Trial Q to current Q
         STAB   0,X
         LDAB   DIVCNT
         STAB   CNTR
         LDX    DIVPTR
         LDAA   0,X     ; Get hi byte of divisor
         LDAB   TRIALQ  ; Get trial quotient byte
         MUL
         STD    TEMP    ; Seems crude, but it works...
         LDD    0,Y
         SUBD   TEMP    ; No borrow possible from hi byte
         STD    0,Y
         DEC    CNTR
         BEQ    DIVLND ; BR if divisor is 1 byte
         LDX    DIVPTR
         LDAA   1,X    ; Get next byte of divisor
         LDAB   TRIALQ
         MUL
         STD    TEMP
         LDD    1,Y
         SUBD   TEMP
         STD    1,Y 
         BCC    *+5
         DEC    0,Y     ; Propagate borrow
         DEC    CNTR
         BEQ    DIVLND  ; BR if divisor is 2 bytes
         LDX    DIVPTR
         LDAA   2,X
         LDAB   TRIALQ
         MUL
         STD    TEMP
         LDD    2,Y
         SUBD   TEMP
         STD    2,Y
         BCC    DIVLND
         LDX    0,Y     ; Propagate borrow
         DEX
         STX    0,Y
DIVLND:  LDD    0,Y
         BEQ    DIVDN0
         TSTA
         BEQ    DIVLN2  ; Almost always branches, 4000:1 or so
         LDX    DIVPTR  ; Ptr to MSB of divisor
         BRA    DIVBYR  ; Last divide by byte was too coarse, correct it

DIVDN0:  INY            ; Hi word of dividend=0, move 1 position right
         DEC    QCNT
         BLT    DIVDUN
         INC    QPTR+1
DIVLN2:  JMP    DIVLUP  ; Loop to do next byte

*  Trial divisor is hi byte of divisor.  Always round it up.
DIVBYT:  DEC    QCNT    ; Divisor > dividend, move 1 position right
         BLT    DIVDUN  ; BR if done
         INC    QPTR+1
         INY
DIVBYR:  LDAB   0,X     ; Get MSB of divisor
         CLRA
         XGDX
         INX            ; Round divisor up
         LDD    0,Y     ; Dividend, current hi 16 bits
         BEQ    DIVDN0  ; Shortcut on 0 dividend     ?? Does this help??
         IDIV           ; MSW of dividend / MSB of divisor = Trial Q
         XGDX           ; Get quotient in D
         TSTA
         BEQ    DIVBT2
         LDAB   #$F0    ; Overflow on this trial, force max 
DIVBT2:  JMP    DIVSTO

* Handle single byte divisor specially
DIV1BYT: LDAB   0,X     ; Get divisor, single byte
         CLRA   
         XGDX
DIV1SKP: CPX    0,Y
         BLS    DIV1BGO 
         DEC    QCNT   ; Divisor > Dividend,  move 1 position right
         BLT    DIVDUN  ; BR if done
         INC    QPTR+1
         INY
         BRA    DIV1SKP
DIV1BGO: LDD    0,Y     ; Dividend, current hi 16 bits
         IDIV           ; MSW of dividend / divisor = Trial Q
         XGDX           ; Get quotient in D
         JMP    DIVSTO

DIVDUN:
DIVBY0:  PULX           ; Restore regs
         PULA
         PULB
         RTS

	  END


