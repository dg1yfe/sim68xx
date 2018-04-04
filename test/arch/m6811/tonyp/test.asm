; Test for possible bug in SIM6811

                    #listoff
                    #include  811E2.INC           ;found in ASM11 distribution
                    #liston

                    #ROM
Start               lds       #STACKTOP
                    clrd
                    clrx
                    clry

                    bsr       Initialize

                    lda       #'>'

Loop                bsr       PutChar
                    bsr       GetKey

                    bra       Loop


Initialize          lda       #$30
                    sta       BAUD

                    clr       SCCR1               ; 8 BIT, NO WAKE UP, 1 STOP BIT

                    lda       #$0C                ; NO INTERRUPT, TX ENABLE, RX ENABLE
                    sta       SCCR2
                    rts

PutChar             tst       SCSR
                    bpl       PutChar ;wait  until TDRE=1
                    sta       SCDR
                    rts
; Keypressed:
;  return C=0 if A contains char read from SCI
;  return C=1 if no char read from SCI
Keypressed          pshx
                    ldx       #REGS
                    sec                           ;Assume no character received
                    brclr     [SCSR,X,#$20,Keypressed1 ;If no char waiting, get out
                    lda       SCDR
                    clc                           ;Character received
Keypressed1         pulx
                    rts

; GetKey:
;  wait until a char is read from SCI, return it with C=0 and char in A
GetKey              bsr       Keypressed
                    bcs       GetKey
                    rts

                    #VECTORS
                    org       $FFFE
                    fdb       Start     ; FFFE

                    end       Start
