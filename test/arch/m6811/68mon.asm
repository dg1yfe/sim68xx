;
;                ' 6811 ML monitor'
;            (c) MARCH 1992 KEITH VASILAKES
;
;   This is a small ml monitor that I origonally wrote on my Commodore 64 
;  using a symbolic crossassembler I wrote in 6502 assembly. The assembler 
;  was nice if nonstandard and lacking features such as conditional assembly
;  includes, etc. Shortly after finishing 68mon I broke down and 
;  bought an Amiga 2000HD, this allowed me to use AS11 and the Buffalo 
;  monitor. As it turns out Buffalo is a huuuuge, designed to run on EVB 
;  boards and dosn't like other systems. So I reserected 68mon quickly 
;  ported it to as11 and here is the result. Its not much but then again
;  its not supposed to be.
;
;    68mon neither requires nor expects expansion ram and uses only five 
;  bytes of zero page ram for variables,unless INTERRUPTS is defined which
;  uses another 48 bytes. 68mon keeps track of two stacks,
;  one monitor stack and one user stack. If the INTERRUPTS variable is 
;  defined 68mon allows the use of all of the 68HC11 interrupts via a 
;  pseudovector system ala Barfalo mon, 68mon however uses different memory
;  locations so be carefull. ( I implemented my vectors before noticeing 
;  Buffalo's pattern )
;    68mon supports some standard monitor functions that are
;  listed below including an intell upload ( if defined that is ) for those 
;  cases when intell hex makes more sense such as when an s19 file has been 
;  converted to intel hex ( such as for my EPROM blaster )and the s19 code 
;  doesn't exist.
;
;    Note that 68mon has some usefull functions that can   be called from your 
;  assembly language program. these functions include string IO character
;  conversion, and serial port support. See 68mon.h for a complete listing
;
;    Not supported is writing to the eeprom, changing the baud rate  There may 
;  be other functions missing, oh well , feel free to add them, and your name 
;   to the list at the top. just remember 68mon is supposed to be small and 
;  light, make it possible to undefine unnessary code like INTERRUPTS for 
;  those who need lots of room.
;
;
;LEGAL STUFF:
;  This program is hereby released into the public domain. It my not be sold
;   in any form for any price. If included with hardware offered for sale,
;   the words "Pubic Domain Monitor 68Mon V1.2" must be clearly visable on all
;   sales literature.
;
;  Usage:
;    Assemble using AS11 or compatable assembler. 68Mon is setup to reside
;    at $E000 but isn"t too picky about where it's at. Programs written to
;    run under 68Mon must end in an SWI or the results are undefined ( crash )
;    note that as soon as an illegal opcode is encountered controll is
;    returned to 68Mon. Be carefull of page zero especially the stack
;    pointers at $00F8 and $00FA
;
;
;
;
; V1.1       ADD S19 UPLOAD  **************DONE*******************
; V1.2       ADD HELP ( LIST COMMANDS ) ***DONE*****************
; V1.?       ADD XON / XOFF ($13 = XOFF, $11 = XON )  YUCK !!!
;
INTELL		EQU 1        ; allows the use of intell hex uploads
;
INTERRUPTS	EQU 1        ; define 'INTERRUPTS' to enable the use of the 
                             ; pseudo interrupts. comment this out to 
                             ; free up 48 bytes of valuable chip RAM
PORTD       EQU  $1008
DDRD        EQU  $1009
SPCR        EQU  $1028
BAUD        EQU  $102B
SCCR1       EQU  $102C
SCCR2       EQU  $102D
SCSR        EQU  $102E
SCDAT       EQU  $102F
;
       IF INTERRUPTS&1
            ORG  $0000       ; pseudo interrupts similar to Barfalomon but
                             ; notice the different adresses and order !
                             ;
PSCI        EQU  0           ; serial comunication interface (RS232)
PSPI        EQU  0003        ; sync serial port
PPAC        EQU  0006        ; pulse accumulator input edge
PPACOV      EQU  0009        ;   "       "       overflow
PTOF        EQU  $000C       ; timer overflow
PTIOC45     EQU  $000F       ; in capt 4 / out comp 5
PTOC4       EQU  $0012       ; output compare 4
PTOC3       EQU  $0015       ;   "      "     3
PTOC2       EQU  $0018       ;   "      "     2
PTOC1       EQU  $001B       ;   "      "     1
PTIC3       EQU  $001E       ; input capture  3
PTIC2       EQU  $0021       ;   "      "     2
PTIC1       EQU  $0024       ;   "      "     1
PRTI        EQU  $0027       ; real time interrupt
PIRQ        EQU  $002A       ; irq
PXIRQ       EQU  $002D       ; xirq
       ENDIF
            ORG  $E000       ; start of eprom
;
SP          EQU  $20
CR          EQU  $0D 
LF          EQU  $0A
ESC         EQU  $1B
;XON         EQU  $11        cant quite figure this out yet ????
;XOFF        EQU  $13
*************************ZERO PAGE USAGE**********
TEMPX       EQU  $00FE
FLAG        EQU  $00FD
CHECK       EQU  $00FC		; USED FOR SUMCHECK
S19FLG      EQU  $00FB		; CURRENT LINE IS S9 RECORD
S0FLAG		EQU  $00FA		; CURRENT LINE IS S0 RECORD

MONSTACK    EQU  $00F9
USRSTACK    EQU  $00F7
**************************************************
STACK       EQU  $00F6
USTACK      EQU  $00D0
;
TRAPP       FCB CR,LF
            FCB CR,LF
            FCC  '    ******** ILLEGAL OPCODE TRAP !!! ********'
            FCB CR,LF
            FCB 0
PROMPT      FCB CR,LF
            FCC  '               68Mon V1.2 (C) 1992 Keith Vasilakes'
            FCB CR,LF
            FCB 0
COLD        LDS  #STACK
            LDAA #$20
            ORAA SPCR
            STAA SPCR
            LDAA #$30
            STAA BAUD
            LDAA #$0C
            STAA SCCR2
            CLR  FLAG       ;CLR ECCO (BIT 7 ) = ECCO CHARS
;
    IF INTERRUPTS&1
;
            LDAA #$7E
            LDX  #PSEUDOVECT
            STX  PSCI+1
            STAA PSCI
            STX  PSPI+1
            STAA PSPI
            STX  PPAC+1
            STAA PPAC
            STX  PPACOV+1
            STAA PPACOV
            STX  PTOF+1
            STAA PTOF
            STX  PTIOC45+1
            STAA PTIOC45
            STX  PTOC4+1
            STAA PTOC4
            STX  PTOC3+1
            STAA PTOC3
            STX  PTOC2+1
            STAA PTOC2
            STX  PTOC1+1
            STAA PTOC1
            STX  PTIC3+1
            STAA PTIC3
            STX  PTIC2+1
            STAA PTIC2
            STX  PTIC1+1
            STAA PTIC1
            STX  PRTI+1
            STAA PRTI
            STX  PIRQ+1
            STAA PIRQ
            STX  PXIRQ+1
            STAA PXIRQ
;
     ENDIF
;
            CLI
;
            BRA  MON68
;
MONSWI      STS  USRSTACK
            LDS  #STACK
            BRA  MON68
;
MONTRAP     STS  USRSTACK
            LDS  #STACK
            LDX  #TRAPP
            JSR  PRINT
MON68       LDX  #PROMPT    ;SWI CALLS MONITOR
            JSR  PRINT
            JSR  REG1
MAIN        LDAA #'>'
            JSR  CHROUT
            LDAB #3
            LDX  #CMDTAB
            JSR  CHRIN
            JSR  TOUPPER
            CMPA #CR
            BNE  LOOP
            LDAA #LF
            JSR  CHROUT
            BRA  MAIN
LOOP        CMPA 0,X
            BEQ  CALL
            TST  0,X
            BEQ  NOTFOUND   ;END OF TABLE
            ABX
            BRA  LOOP
NOTFOUND    BSR  ERROR
            BRA  MAIN
;
ERROR       LDAA #'?'
            JSR  CHROUT
            LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JSR  CHROUT
            SEC
            RTS
;
CALL        LDX  1,X
            JSR  0,X
            BRA  MAIN
;
PRINT       LDAA 0,X
            BEQ  PREND
            JSR  CHROUT
            INX
            BRA  PRINT
PREND       RTS
;
INWORD      PSHB
            PSHA
            JSR  INBYTE
            BCS  WRDERR
            TAB
            JSR  INHEX
            BCS  WRDERR
            PSHA
            PSHB
            PULX
            PULA
            PULB
            RTS
WRDERR      PULA
            PULB
            BRA  ERROR
;
OUTWORD     PSHA
            PSHX
            PULA
            JSR  OUTHEX     ;PRINT 2 HEX CHRS
            PULA
            JSR  OUTBYTE    ;PRINT 2 HEX CHRS + SPACE
            PULA
            RTS
;
INBYTE      BSR  INHEX      ;ALLOW LEADING SPACES
            BCC  INB1
            CMPA #SP
            BEQ  INBYTE
INB1        RTS             ;RETURNS W CARRY SET IF NOT SP OR HEX
;
INHEX       PSHB
INH1        BSR  CHRIN
            BSR  FASCII
            BCS  INHERR
            TAB
            BSR  CHRIN
            BSR  FASCII
            BCS  INHERR
            ASLB
            ASLB
            ASLB
            ASLB
            ABA
            CLC 
INHERR      PULB
            RTS             ;RETURNS WITH ERROR CHAR IN ACCA
;
OUTHEX      PSHA
            PSHA
            ANDA #$F0
            LSRA
            LSRA
            LSRA
            LSRA
            JSR  TOASCII
            JSR  CHROUT
            PULA
            ANDA #$0F
            JSR  TOASCII
            JSR  CHROUT
            PULA
            RTS
;
OUTBYTE     BSR  OUTHEX
            PSHA
            LDAA #SP
            JSR  CHROUT
            PULA
            RTS
;
FASCII      BSR  TOUPPER
            CMPA #$30
            BLO  GETEND
            CMPA #$39
            BLS  FASC1
            CMPA #$41
            BLO  GETEND
            CMPA #$46
            BHI  GETEND
            SUBA #$07
FASC1       SUBA #$30
            CLC
            RTS
;
TOASCII     CLC
            ADDA #$90
            DAA
            ADCA #$40
            DAA
            RTS
;
TOUPPER     CMPA #$61
            BLO  END
            CMPA #$7A
            BHI  END
            SUBA #$20
END         RTS
;
TOLOWER     CMPA #$41
            BLO  END1
            CMPA #$5A
            BHI  END1
            ADDA #$20
END1        RTS
;
CHRIN       BSR  GETIN
            BCS  CHRIN
            TST  FLAG
            BMI  END1
            BRA  CHROUT
;
GETIN       LDAA SCSR
            ANDA #$20
            BEQ  GETEND
            LDAA SCDAT
            CLC
            RTS
GETEND      SEC
            RTS
;
CHROUT      BSR  PUTOUT
            BCS  CHROUT
            RTS
;
PUTOUT      PSHB
PUTOUT1     LDAB SCSR
            ANDB #$80
            BEQ  PUTOUT2
            STAA SCDAT
            PULB
            CLC
            RTS
PUTOUT2     PULB
            SEC
            RTS
;
CMDTAB      FCB 'M'
            FDB  MEMEX
            FCB 'G'
            FDB  GO
         IF INTELL&1
            FCB 'U'
            FDB UPLOAD
         ENDIF
            FCB 'F'
            FDB FILL
            FCB 'R'
            FDB REGISTER
            FCB 'C'
            FDB CONTINUE
            FCB 'S'
            FDB S19UPLOAD
            FCB '?'
            FDB HELP
            FCB 0
;
MEMEX       JSR  INWORD
            BCS  ERR
            STX  TEMPX
MEMX        JSR  INBYTE     ;CHANGE MEMORY
            BCS  READ0
            STAA 0,X
            INX
            BRA  MEMX
;
READ0       CMPA #ESC
            BEQ  ERR    
            LDX  TEMPX
            LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JSR CHROUT
READ        JSR  OUTWORD    ;PRINT ADDRESS
            LDAB #$10         ;NUMBER OF BYTES PER LINE
READ1       LDAA 0,X
            JSR  OUTBYTE
            INX
            DECB
            BNE  READ1
            LDX  TEMPX
            LDAB #$10
READ2       LDAA 0,X
            CMPA #SP
            BLO  READ4
            CMPA #$80
            BLS  READ3
READ4       LDAA #'.'
READ3       JSR  CHROUT
            INX
            DECB
            BNE  READ2
            STX  TEMPX
            JSR  GETIN      ;PRINT DATA UNTIL KEYPRESS
            BCS  READ0
READ5       LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JSR  CHROUT
            RTS
;
;
FILLERR     PULX
ERR         SEC
            RTS
;
FILL        JSR  INWORD     ;GET FROM ADDRESS
            BCS  ERR
            PSHX
            JSR  INWORD     ;GET TO ADDRESS
            BCS  FILLERR
            STX  TEMPX
            JSR  INBYTE     ;GET FILL VALUE
            BCC  FILLX
            LDAA #$FF       ;IF NO FILL VALUE,FILL WITH NOP'S
FILLX       PULX
FILL1       STAA 0,X
            INX
            CPX  TEMPX
            BLS  FILL1
            LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JMP  CHROUT
;
       IF INTELL&1
;
UPLOAD      LDAA FLAG
            PSHA
            ORAA #%10000000 ; BIT 7 SET = NO ECCO
            STAA FLAG
            LDAA #CR 
            JSR  CHROUT
            LDAA #LF
            JSR  CHROUT
            LDAA #'.'
            JSR  CHROUT
UPSTART     JSR  CHRIN
            BCS  ERROR1
            CMPA #':'
            BNE  UPEND
            CLR  CHECK
            JSR  INBYTE     ;GET NUM OF BYTES
            BCS  ERROR1
            PSHA            ;SAVE NUMBER OF BYTES (WILL BE USED IN ACCB LATER)
            ADDA CHECK
            STAA CHECK
            JSR  INWORD     ;GET ADDRESS
            BCC  UPOK 
            PULA
            BRA  ERROR1
UPOK        PSHX
            XGDX
            ADDA CHECK
            STAA CHECK
            ADDB CHECK
            STAB CHECK
            PULX
            PULB            ;GET BACK NUMBER OF FCBS
            JSR  INBYTE     ;GET NULL (?) FCB
            ADDA CHECK
            STAA CHECK
            INCB
UPLOAD1     JSR  INBYTE
            BCS  ERROR1
            DECB
            BEQ  END2
            STAA 0,X
            ADDA CHECK
            STAA CHECK
            INX
            BRA  UPLOAD1
END2        NEG  CHECK
            CMPA CHECK
            BNE  ERROR1
            JSR  CHRIN      ;GETCR AT END OF LINE
            BRA  UPSTART
UPEND       PULA
            STAA FLAG
            LDAA #1
            ORAA FLAG
            STAA FLAG
            RTS
ERROR1      PULA     
            STAA FLAG
            JMP  ERROR
;
       ENDIF
;
REGNAME     FCC '  SXHINZVC  AB AA  IX   IY   PC   SP'   
;                  12345678  12 12 1234 1234 1234 1234  
            FCB CR,LF
            FCB 0
REGISTER    JSR  CHRIN
            CMPA #CR
            BEQ  REG1
            BRA  GOERR
REG1        LDAA #LF
            JSR  CHROUT
            LDX  #REGNAME
            JSR  PRINT
            LDAA #SP
            JSR  CHROUT
            JSR  CHROUT
            LDX  USRSTACK
            INX
            LDAB 0,X
            LDAA #8
            STAA TEMPX
REG         CLRA
            ASLB
            ADCA #'0'
            JSR  CHROUT
            DEC  TEMPX
            BNE  REG
            LDAA #SP
            JSR  CHROUT
            JSR  CHROUT
            LDAA 1,X
            JSR  OUTBYTE    ;ACCB
            LDAA 2,X
            JSR  OUTBYTE    ;ACCA
            LDD  3,X
            XGDX
            JSR  OUTWORD    ;INX
            XGDX
            LDD  5,X
            XGDX
            JSR  OUTWORD    ;INY
            XGDX
            LDD  7,X
            XGDX
            JSR  OUTWORD    ;PC
            LDX  USRSTACK
            JSR  OUTWORD    ;SP
            LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JSR  CHROUT
            RTS
;
GO          JSR  INWORD
            BCS  GOERR
            JSR  CHRIN
            CMPA #CR
            BNE  GOERR
            LDS  #USTACK
            JMP  0,X        ; CALL USER PROG,X
;
GOERR       RTS
;
CONTINUE    JSR  CHRIN
            CMPA #CR
            BNE  GOERR
            LDS  USRSTACK  ; CONTINUE FROM LAST SWI
            RTI
;
HELP        LDX  #HELPLIST
            JSR  PRINT
            RTS
HELPLIST    FCB  CR,LF,CR,LF,CR,LF,CR,LF,CR,LF
            FCC  'COMMANDS:'
            FCB  CR,LF,CR,LF
            FCB  CR,LF
            FCB  CR,LF
            FCC  '?        DISPLAYS THIS SCREEN',CR
            FCB  CR,LF,CR,LF
            FCC  'F [xxxx] [yyyy] [zz] FILL MEMORY FROM xxxx to yyyy with zz '
            FCB  CR,LF,CR,LF
            FCC  'M [xxxx] MEMORY EXAMINE, DISPLAYS DATA AT xxxx UNTIL ANY KEY IS PRESSED'
            FCB  CR,LF,CR,LF
            FCC  'M [xxxx] [yy zz ...] MEMORY CHANGE, WRITES yy TO xxxx AND zz TO xxxx +1'
            FCB  CR,LF,CR,LF
            FCC  'G xxxx   TRANSFERS CONTROLL TO PROGAM AT xxxx. PROG IS GIVEN ITS OWN'
            FCB  CR,LF,CR,LF
            FCC  '          STACK AND MUST END WITH A SWI TO RETURN TO THE MONITOR'
            FCB  CR,LF,CR,LF
            FCC  'R        DISPLAYS USER REGISTERS'
            FCB  CR,LF,CR,LF
            FCC  'C        CONTINUES A USER PROGRAM AFTER A SWI, LIKE A BREAKPOINT'
            FCB  CR,LF,CR,LF
            FCC  'S        UPLOADS A MOTO S19 HEX FILE'
            FCB  CR,LF,CR,LF
      IF INTELL&1      
            FCC  'U        UPLOADS AN INTEL HEX FILE'
            FCB  CR,LF,CR,LF
      ENDIF
            FCB  CR,LF
            FCB  0
;
S19UPLOAD   LDAA FLAG
            PSHA
;            ORAA #%10000000 ; BIT 7 SET = NO ECCO
;            STAA FLAG
            LDAA #CR
            JSR  CHROUT
            LDAA #LF
            JSR  CHROUT
SUPSTART    CLR  S19FLG
			CLR  S0FLAG
            JSR  CHRIN
            BCS  SERROR1
            CMPA #'S'
            BNE  SERROR1
            JSR  CHRIN
            CMPA #'1'
            BEQ  SUPSTRT
            CMPA #'0'
			BNE  CHKS9
			LDAA #$FF
			STAA S0FLAG		;SET FLAG TO NOT STORE THIS LINE
			BRA  SUPSTRT
CHKS9		CMPA #'9'
            BNE  SERROR1
            LDAA #$FF       ;S9 RECIEVED SET FLAG TO JUMP TO ADDRESS AT END
            STAA S19FLG
SUPSTRT     CLR  CHECK
            JSR  INBYTE     ;GET NUM OF BYTES
            BCS  SERROR1
            PSHA            ;SAVE NUMBER OF BYTES (WILL BE USED IN ACCB LATER)
            ADDA CHECK
            STAA CHECK
            JSR  INWORD     ;GET ADDRESS
			STX  TEMPX
            BCC  SUPOK 
            PULA
            BRA  SERROR1
SUPOK       PSHX
            XGDX
            ADDA CHECK
            STAA CHECK
            ADDB CHECK
            STAB CHECK
            PULX
            PULB            ;GET BACK NUMBER OF BYTES
            SUBB #2
SUPLOAD1    JSR  INBYTE
            BCS  SERROR1
            DECB			; dec byte count
            BEQ  SEND2
			TST  S0FLAG		; IF S0 DONT STORE DATA
			BNE  NOSTORE
            STAA 0,X
NOSTORE     ADDA CHECK
            STAA CHECK
            INX
            BRA  SUPLOAD1
SEND2       COM  CHECK
            CMPA CHECK		;Compare Checksum at end of line with calculated checksum
            BNE  SERROR1
            JSR  CHRIN      ;GETCR AT END OF LINE
            TST  S19FLG
            BEQ  SUPSTART
SUPEND      PULA
            STAA FLAG		;LOCAL ECCO ON
            LDAA #1			;DOWNLOAD OK
            ORAA FLAG
            STAA FLAG
			LDX  TEMPX		; EXECUTE PROGRAM AT S9 ADDRESS
			JMP  0,X
SERROR1     PULA     
            STAA FLAG
            JMP  ERROR
;
PSEUDOVECT  RTI
;
;
**********VECTORS*******************
;
            ORG  $FFD6
      IF INTERRUPTS&1
;
SCI         FDB  PSCI
SPI         FDB  PSPI
PACC        FDB  PPAC
PACCOV      FDB  PPACOV
TOVF        FDB  PTOF
TIOC45      FDB  PTIOC45
TOC4        FDB  PTOC4
TOC3        FDB  PTOC3
TOC2        FDB  PTOC2
TOC1        FDB  PTOC1
TIC3        FDB  PTIC3
TIC2        FDB  PTIC2
TIC1        FDB  PTIC1
RTI         FDB  PRTI
IRQ         FDB  PIRQ
XIRQ        FDB  PXIRQ
;
     IF INTERRUPTS^1	*ELSE
;
SCI         FDB  PSEUDOVECT
SPI         FDB  PSEUDOVECT
PACC        FDB  PSEUDOVECT
PACCOV      FDB  PSEUDOVECT
TOVF        FDB  PSEUDOVECT
TIOC45      FDB  PSEUDOVECT
TOC4        FDB  PSEUDOVECT
TOC3        FDB  PSEUDOVECT
TOC2        FDB  PSEUDOVECT
TOC1        FDB  PSEUDOVECT
TIC3        FDB  PSEUDOVECT
TIC2        FDB  PSEUDOVECT
TIC1        FDB  PSEUDOVECT
RTI         FDB  PSEUDOVECT
IRQ         FDB  PSEUDOVECT
XIRQ        FDB  PSEUDOVECT
;
     ENDIF
;
SWI         FDB  MONSWI
TRAP        FDB  MONTRAP
COP         FDB  COLD
COP1        FDB  COLD
RESET       FDB  COLD

            END
