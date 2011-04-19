/* <<<                                  */
/* Copyright (c) 1994-1996 Arne Riiber. */
/* All rights reserved.                 */
/* >>>                                  */
#include <assert.h>
#include <stdio.h>

#include "defs.h"
#include "chip.h"
#include "cpu.h"
#include "ireg.h"
#include "memory.h"
#include "optab.h"
#include "reg.h"
#include "sci.h"
#include "timer.h"
#include "symtab.h"

#ifdef USE_PROTOTYPES
#include "instr.h"
#endif


/*
 *  reset - jump to the reset vector
 */
reset ()
{
	reg_setpc (mem_getw (RESVECTOR));
	reg_setiflag (1);
}


/*
 * instr_exec - execute an instruction
 */
instr_exec ()
{
	/*
	 * Get opcode from memory,
	 * inc program counter to point to first operand,
	 * Decode and execute the opcode.
	 */
	struct opcode *opptr;
	int interrupted = 0;		/* 1 = HW interrupt occured */

#ifndef M6800
	if (!reg_getiflag ())
	{
		/*
		 * Check for interrupts in priority order
		 */
		if ((ireg_getb (TCSR) & OCF1) && (ireg_getb (TCSR) & EOCI1)) {
			int_addr (OCFVECTOR);
			interrupted = 1;
		} else if (serial_int ()) {
			int_addr (SCIVECTOR);
			interrupted = 1;
		}
	}
#if 0
	/*
	 * 6301 Address check error: Trap if address is outside RAM/ROM
	 * This must be modified to check mode (single-chip/extended) first
	 */
	if ((reg_getpc() <= ramstart) || reg_getpc() >  ramend)
	{
		error ("instr_exec: Address error: %04x\n", reg_getpc());
		trap();		/* Highest pri vector after Reset */
	}
#endif /* 0 */
#endif /* M6800 */

	if (interrupted) /* Prepare cycle count for register stacking */
	{
		opptr = &opcodetab[0x3f]; /* SWI */
	}
	else
	{
		opptr = &opcodetab [mem_getb (reg_getpc ())];
		reg_incpc (1);
		(*opptr->op_func) ();
	}

	cpu_setncycles (cpu_getncycles () + opptr->op_n_cycles);
	timer_inc (opptr->op_n_cycles);
	return 0;
}



/*
 * instr_print - print (unassemble) an instruction
 */
instr_print (u_int addr)
{
	u_short		 pc	= addr;
	u_char		 op	= mem_getb (pc);
	struct opcode	*opptr	= &opcodetab[op];
	char		*symname;

	/*
	 * In case somebody changes the opcodemap, verify it
	 */
	assert (opptr->op_value == op);

	printf ("%04x\t", pc);

	switch(opptr->op_addrmode)
	{
		case 0:	// Immediate
		{
			printf ("%02x %02x\t\t",  mem_getb (pc), mem_getb (pc+1));
//			printf ("%02x\t\t",  mem_getb (pc));
			printf (opptr->op_mnemonic, mem_getb (pc + 1));
			break;
		}
		case 1: // Direct
		{
			printf ("%02x %02x\t\t",  mem_getb (pc), mem_getb (pc+1));
			printf (opptr->op_mnemonic, mem_getb (pc + 1));
			if (symname = sym_find_name (mem_getb (pc + 1)))
				printf ("\t%s", symname);
			break;
		}
		case 2: // Extended
		{
			printf ("%02x %02x %02x\t", mem_getb (pc),
					mem_getb (pc + 1), mem_getb (pc + 2));
			printf (opptr->op_mnemonic, mem_getw (pc + 1));
			if (symname = sym_find_name (mem_getw (pc + 1)))
				printf ("\t%s", symname);
			break;
		}
		case 3: // Indexed
		{
			printf ("%02x %02x\t\t",  mem_getb (pc), mem_getb (pc+1));
			printf (opptr->op_mnemonic, mem_getb (pc + 1));
			if (symname = sym_find_name (reg_getix() + mem_getb (pc + 1)))
				printf ("\t%s", symname);
			break;
		}
		case 4: // Implied
		{
			printf ("%02x\t\t",  mem_getb (pc));
			printf (opptr->op_mnemonic, mem_getb (pc + 1));
			break;
		}
		case 5: // Relative
		{
			signed char offset = (signed char) mem_getb (pc + 1);

			printf ("%02x %02x\t\t",  mem_getb (pc), mem_getb (pc+1));
			printf (opptr->op_mnemonic, mem_getb (pc + 1));
			if (symname = sym_find_name (pc + offset))
				printf ("\t%s", symname);
			break;
		}
		case 6: // Immediate Direct
		{
			printf ("%02x %02x %02x\t", mem_getb (pc),
					mem_getb (pc + 1), mem_getb (pc + 2));
			printf (opptr->op_mnemonic, mem_getb (pc + 1), mem_getb(pc + 2));
			if (symname = sym_find_name (mem_getb (pc + 2)))
				printf ("\t%s", symname);
			break;
		}
		case 7: // Immediate Indexed
		{
			printf ("%02x %02x %02x\t", mem_getb (pc),
					mem_getb (pc + 1), mem_getb (pc + 2));
			printf (opptr->op_mnemonic, mem_getb (pc + 1), mem_getb(pc + 2));
			if (symname = sym_find_name (reg_getix() + mem_getb (pc + 2)))
				printf ("\t%s", symname);
			break;
		}

	}

	/* printf ("\t[%d]\n", cpu_getncycles ()); */
	putchar ('\n');
	return opptr->op_n_operands + 1;
}
