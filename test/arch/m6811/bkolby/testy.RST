ASxxxx Assembler V02.01 MSOE  (Motorola 6811), page 1.



                              1 ;;;Bugs with dissasembly output in SimnCcpu:
                              2 	
                    4BE0      3 g_target = 0x4be0
                    4E22      4 g_len	 = 0x4e22
                              5 
                              6 ;;;  Source text:
                              7 	
   0000 18 FF 4B E0           8 	sty	g_target			; set global target pointer
   0004 1A EE 0A              9    	ldy	10,x				; byts	->Y
   0007 18 FF 4E 22          10    	sty	g_len				; set global buf len
                             11    	
   000B 18 3C                12 	pshy
   000D 37                   13    	pshb
   000E 36                   14    	psha
                             15 
                             16 ;;; More B.Kolby reported bugs go here
                             17 
   000F 18 FE 4E 22          18 	ldy	g_len
   0013 1A B3 4E 22          19 	cpd	g_len
   0017 18 BC 4E 22          20 	cpy	g_len
                             21 		
                             22 ;;; Additional bugs found A.Riiber
   001B 18 08                23 	iny
   001D 18 09                24 	dey
                             25 	
ASxxxx Assembler V02.01 MSOE  (Motorola 6811), page 2.

Symbol Table

    .__.ABS.=  0000 G   |     g_len   =  4E22     |     g_target=  4BE0 

ASxxxx Assembler V02.01 MSOE  (Motorola 6811), page 3.

Area Table

   0 _CODE      size   1F   flags 0
