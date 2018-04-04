;;;Bugs with dissasembly output in SimnCcpu:
	
g_target = 0x4be0
g_len	 = 0x4e22

;;;  Source text:
	
	sty	g_target			; set global target pointer
   	ldy	10,x				; byts	->Y
   	sty	g_len				; set global buf len
   	
	pshy
   	pshb
   	psha

;;; More B.Kolby reported bugs go here

	ldy	g_len
	cpd	g_len
	cpy	g_len
		
;;; Additional bugs found A.Riiber
	iny
	dey
	
