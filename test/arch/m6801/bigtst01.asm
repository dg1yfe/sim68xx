*
* 6801 instruction test - assumes 6800 instruction set already tested
*
* (Unfinished)
*

* abx
	ldx	#$1000
	ldab	#$55
	abx
	cpx	#$1055
	bne	*

* addd_imm ()   {reg_setaccd (alu_addword (reg_getaccd () ,getword_imm (), 0));}
* addd_dir ()   {reg_setaccd (alu_addword (reg_getaccd () ,getword_dir (), 0));}
* addd_ext ()   {reg_setaccd (alu_addword (reg_getaccd () ,getword_ext (), 0));}
* addd_ind_x () {reg_setaccd (alu_addword (reg_getaccd () ,getword_ix  (), 0));}


* brn
	brn	*


* jsr_dir
* ldd_imm ()    {reg_setaccd (alu_bittestword (getword_imm ()));}
* ldd_dir ()    {reg_setaccd (alu_bittestword (getword_dir ()));}
* ldd_ext ()    {reg_setaccd (alu_bittestword (getword_ext ()));}
* ldd_ind_x ()  {reg_setaccd (alu_bittestword (getword_ix ()));}
* lsld_inh ()   {reg_setaccd (alu_shlword (reg_getaccd (), 0));}
* lsrd_inh ()   {reg_setaccd (alu_shrword (reg_getaccd (), 0));}
* mul_inh ()


*
* pshx - assumes pulb/pula OK
*
	ldx	pattern
	pshx
	pulb
	pula
	cmpb	lo(pattern)
	bne	*
	cmpa	hi(pattern)
	bne	*
*
* pulx - assumes pshb/psha OK
*
	ldab	lo(pattern)
	ldaa	hi(pattern)
	pshb
	psha
	pulx
	cpx	pattern
	bne	*

* std direct - check same as {staa,stab} direct

	ldaa	hi(pattern)
	ldab	lo(pattern)
	std	direct
	eora	direct
	bne	*
	eorb	direct+1
	bne	*

* std_ext () - analogue to std direct
std_ind_x ()	{mem_putw (getaddr_ix (),  alu_bittestword (reg_getaccd ()));}

subd_imm ()   {reg_setaccd (alu_subword (reg_getaccd (), getword_imm (), 0));}
subd_dir ()   {reg_setaccd (alu_subword (reg_getaccd (), getword_dir (), 0));}
subd_ext ()   {reg_setaccd (alu_subword (reg_getaccd (), getword_ext (), 0));}
subd_ind_x () {reg_setaccd (alu_subword (reg_getaccd (), getword_ix  (), 0));}
