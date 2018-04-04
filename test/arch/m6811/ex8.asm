* Register definitions for 68HC11 registers (used for Ex 8-1 & 8-2)
PORTD  EQU   $1008    Port D data register
*                     " -  , -  ,SS* ,SCK ;MOSI,MISO,TxD ,RxD "
DDRD   EQU   $1009    Port D data direction
SPCR   EQU   $1028    SPI control register
*                     "SPIE,SPE ,DWOM,MSTR;CPOL,CPHA,SPR1,SPR0"
SPSR   EQU   $1029    SPI status register
*                     "SPIF,WCOL, -  ,MODF; -  , -  , -  , -  "
SPDR   EQU   $102A    SPI data register; Read-Buffer; Write-Shifter

* RAM variables (DAx used by Ex 8-1 & 8-2, SPIx used only by 8-1)
DA1    EQU   $00      6-bit val for D/A ch 1 "-,-,15,14;13,12,11,10"
DA2    EQU   $01      6-bit val for D/A ch 2 "-,-,25,24;23,22,21,20"
DA3    EQU   $02      6-bit val for D/A ch 3 "-,-,35,34;33,32,31,30"
DA4    EQU   $03      6-bit val for D/A ch 4 "-,-,45,44;43,42,41,40"
DA5    EQU   $04      6-bit val for D/A ch 5 "-,-,55,54;53,52,51,50"
DA6    EQU   $05      6-bit val for D/A ch 6 "-,-,65,64;63,62,61,60"
* Upper 2 bits of DAx should be 0 but will be ignored.
SPI1   EQU   $06      SPI packed byte 1 "--,--,--,--;65,64,63,62"
SPI2   EQU   $07      SPI packed byte 2 "61,60,55,54;53,52,51,50"
SPI3   EQU   $08      SPI packed byte 3 "45,44,43,42;41,40,35,34"
SPI4   EQU   $09      SPI packed byte 4 "33,32,31,30;25,24,23,22"
SPI5   EQU   $0A      SPI packed byte 5 "21,20,15,14;13,12,11,10"
* NOTE: Upper 4 bits of SPI1 are unused extras but will be 0.

***********************************************************************
* Example 8-1                                                         *
*                                                                     *
*  This example program uses the on-chip hardware SPI to drive an     *
* MC144110 six channel D to A converter peripheral.                   *
*                                                                     *
*  To try Ex 8-1, connect MC144110 to Port D pins on EVB, load        *
* program into EVB RAM, manually enter data for DA1 to DA6 and        *
* execute a GO to $C000.                                              *
***********************************************************************

       ORG   $C000    Start of user's RAM in EVB
INIT1  LDS   #$CFFF   Top of C page RAM
       LDAA  #$2F     -,-,1,0;1,1,1,1
*                     SS*-Hi, SCK-Lo, MOSI-Hi
       STAA  PORTD    So SS stays high when DDRD5 set
       LDAA  #$38     -,-,1,1;1,0,0,0
       STAA  DDRD     SS*, SCK, MOSI - Outs
*                     MISO, TxD, RxD - Ins
* DDRD5=1 so SS* pin is a general purpose output
       LDAA  #$57
       STAA  SPCR     SPI on as Master, CPHA=1, CPOL=0
*                     E/32 Clk rate
***
* Following two instructions call main routine for Ex 8-1
***
       BSR   UPDAT1   Xfer 5 8-bit words to MC144110
       JMP   $E000    Restart BUFFALO
***
UPDAT1 PSHX           Save registers X and A
       PSHY
       PSHA
       BSR   REFORM   Reformat data so SPI can xfer it
       LDX   #SPI1    Point at 1st byte to send via SPI
       LDY   #$1000   Point at on-chip registers
       BCLR  PORTD,Y %00100000  Drive SS* low
TFRLP1 LDAA  0,X      Get a byte to transfer via SPI
       STAA  SPDR     Write SPI data reg to start xfer
WAIT1  LDAA  SPSR     Loop to wait for SPIF
       BPL   WAIT1    SPIF is in MSB of SPSR
*                     (when SPIF set, SPSR neg)
       INX            Point to next SPI byte
       CPX   #SPI5+1  Done yet ?
       BNE   TFRLP1   If not, tfr another byte
       BSET  PORTD,Y %00100000  Drive SS* high
       PULA           When done, restore regs X, Y & A
       PULY
       PULX
       RTS            ** Return **

***********************************************************************
* REFORM - This subroutine reformats six 6 bit values into five 8 bit *
*          values so they can be sent by the SPI system.              *
*                                                                     *
*  The MC144110 needs 36 bits of information which is not a multiple  *
* of 8 bits; however, we can send five 8 bit words (40 bits) and the  *
* MC144110 will use only the last 36 bits.                            *
*                                                                     *
*       Original format               Change to this format           *
*    DA1 "-,-,15,14;13,12,11,10"   SPI1 "--,--,--,--;65,64,63,62"     *
*    DA2 "-,-,25,24;23,22,21,20"   SPI2 "61,60,55,54;53,52,51,50"     *
*    DA3 "-,-,35,34;33,32,31,30"   SPI3 "45,44,43,42;41,40,35,34"     *
*    DA4 "-,-,45,44;43,42,41,40"   SPI4 "33,32,31,30;25,24,23,22"     *
*    DA5 "-,-,55,54;53,52,51,50"   SPI5 "21,20,15,14;13,12,11,10"     *
*    DA6 "-,-,65,64;63,62,61,60"                                      *
***********************************************************************

REFORM PSHB           Save registers B and A
       PSHA
       LDAA  DA1      A="--,--,15,14;13,12,11,10"
       ASLA           A="--,15,14,13;12,11,10, 0"
       ASLA           A="15,14,13,12;11,10, 0, 0"
       LDAB  DA2      B="--,--,25,24;23,22,21,20"
       ANDB  #$3F     B=" 0, 0,25,24;23,22,21,20"
       LSRB           B=" 0, 0, 0,25;24,23,22,21" C="20
       RORA           A="20,15,14,13;12,11,10, 0"
       LSRB           B=" 0, 0, 0, 0;25,24,23,22" C="21
       RORA           A="21,20,15,14;13,12,11,10"
       STAA  SPI5     SPI5 is done
       STAB  SPI4     SPI4 intermediate value
       LDAA  DA4      A="--,--,45,44;43,42,41,40"
       LDAB  DA3      B="--,--,35,34;33,32,31,30"
       ASLB           B="--,35,34,33;32,31,30, 0"
       ASLB           B="35,34,33,32;31,30, 0, 0"
       ASLB           B="34,33,32,31;30, 0, 0, 0" C="35
       ROLA           A="--,45,44,43;42,41,40,35"
       ASLB           B="33,32,31,30; 0, 0, 0, 0" C="34
       ROLA           A="45,44,43,42;41,40,35,34"
       ORAB  SPI4     B="33,32,31,30;25,24,23,22"
       STAB  SPI4     SPI4 now complete
       STAA  SPI3     SPI3 done
       LDAA  DA5      A="--,--,55,54;53,52,51,50"
       ASLA           A="--,55,54,53;52,51,50, 0"
       ASLA           A="55,54,53,52;51,50, 0, 0"
       LDAB  DA6      B="--,--,65,64;63,62,61,60"
       ANDB  #$3F     B=" 0, 0,65,64;63,62,61,60"
       LSRB           B=" 0, 0, 0,65;64,63,62,61" C="60
       RORA           A="60,55,54,53;52,51,50, 0"
       LSRB           B=" 0, 0, 0, 0;65,64,63,62" C="61
       RORA           A="61,60,55,54;53,52,51,50"
       STAA  SPI2     SPI2 done
       STAB  SPI1     SPI1 done
       PULA           Restore registers A and B
       PULB
       RTS            ** Return **

***********************************************************************
* Example 8-2                                                         *
*                                                                     *
*  This example program uses a software equivalent of the SPI to      *
* drive an MC144110 six channel D to A converter peripheral.  The     *
* physical hookup is the same as that of the previous example to make *
* comparisons easier.                                                 *
*                                                                     *
*  To try Ex 8-2, connect MC144110 to Port D pins on EVB, load        *
* program into EVB RAM, manually enter data for DA1 to DA6 and        *
* execute a GO to $C100.                                              *
***********************************************************************

       ORG   $C100
INIT2  LDS   #$CFFF   Top of C page RAM
       LDAA  #$2F     -,-,1,0;1,1,1,1
       STAA  PORTD    PD5/SS*-Lo,PD4/SCK-Lo,PD3/MOSI-Hi
       LDAA  #$38     -,-,1,1;1,0,0,0
       STAA  DDRD     PD5, PD4, PD3 =Outs; Others =Ins
       LDAA  #$04
*            "SPIE,SPE,DWOM,MSTR;CPOL,CPHA,SPR1,SPR0"
       STAA  SPCR     Make sure SPI off
***
* Following two instructions call main routine for Ex 8-2
***
       BSR   UPDAT2   Xfer six 6 bit words to MC144110
       JMP   $E000    Restart BUFFALO
***
UPDAT2 PSHX           Save X, Y and A
       PSHY
       PSHA
       LDY   #DA6     Point at 1st D/A value to xfer.
       LDX   #$1000   Point at register area.
TFRLP2 LDAA  #$20     1st pntr to MSB of 6 bit data val
       BCLR  PORTD,X %00100000  PD5(SS*) Falling edge
       NOP            Need more dly for MC144110 specs.
       NOP
NXTBIT BSET  PORTD,X %00010000  PD4(SCK) Rising edge
       BITA  0,Y      Test sense of bit to be sent
       BEQ   ZBIT     If zero skip around
       BSET  PORTD,X %00001000  PD3(MOSI) Hi bit
       BRA   ENDBIT
ZBIT   BCLR  PORTD,X %00001000  PD3(MOSI) Lo bit
       BRA   ENDBIT   Want Lo time to match Hi time
ENDBIT BCLR  PORTD,X %00010000  PD4(SCK) Falling edge
       LSRA           Pointer to nxt lower bit position
       BNE   NXTBIT   Done if pointer shifted past LSB
       DEY            Point at next value to send
       CPY   #DA1-1   Done yet ?
       BNE   TFRLP2   If not go back to top of loop
       BSET  PORTD,X %00100000  PD5(SS*) Rising edge
       PULA           Restore X, Y and A
       PULY
       PULX
       RTS            ** RETURN **

