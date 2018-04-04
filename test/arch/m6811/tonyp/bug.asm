; Demonstrates a bug with saving and restoring an interrupt
; stack frame.  A and B are stored during the interrupt (eg., SWI)
; and restored during the RTI instruction in the REVERSE order from
; the real MCU.  The D is a special case and is saved backwards during
; interrupts.

; Stack frame offsets after TSX
PC_                 equ       7
Y_                  equ       5
X_                  equ       3
A_                  equ       2
B_                  equ       1
D_                  equ       1         ;D offset but D is in *reversed* order
CCR_                equ       0

TESTVALUE           EQU       $55AA

; Use the T command to trace the code until you reach either Success
; or Failure
                    org       $F800
Start               lds       #$FF
                    clrd                ;zero all registers
                    clrx
                    clry

                    ldd       #TESTVALUE

                    swi                 ;SWI handler makes A=$55 and B=$AA

;check outcoming D
                    cmpd      #TESTVALUE
                    bne       Failure

Success             bra       *         ;If you end up here, simulation is correct

Failure             bra       *         ;If you end up here, simulation is wrong

SWI_Handler         tsy                 ;Y = SP+1

;check incoming D
                    ldd       #TESTVALUE          ;because of reversed order
                    cmpd      D_,y                ;D on stack, the two values
                    beq       Failure             ;should NOT match! If they do, error!

;prepare outgoing D
                    sta       A_,y
                    stb       B_,y

                    rti

                    org       $FFF6
                    dw        SWI_Handler

                    org       $FFFE
                    dw        Start

                    end       Start