
/*
 *	Memory access
 *
 *	This file contains memory accesss functions that typically vary
 *	with chip and board. As is, it provides support for a single I/O
 *	block through the 'ireg' interface.
 *
 *	For additional I/O (or special memory) blocks, 'mem_getb' will 
 *	probably have to be modified.
 *
 *	Functions reside in this file to make inlining possible.
 */
#ifndef MEMORY_H
#define MEMORY_H

#include "defs.h"		/* general definitions */
#include "chip.h"		/* chip specific: NIREGS */
#include "ireg.h"		/* chip specific: ireg_getb/putb_func[], ireg_start/end */

#define MEMSIZE 65536		/* Size of ram and breakpoint arrays */

/*
 * Memory variables
 *
 * Addresses used by mem_getb/putb should be set with command line options.
 * Disabling internal regs can be done by declaring ireg_start > ireg_end
 */
extern u_int	ram_start;	/* First valid RAM address */
extern u_int	ram_end;	/* Last valid RAM address */
extern u_char  *ram;		/* Physical storage for simulated RAM */

/*
 * The array 'breaks' is a sister array to 'ram'
 * where each address containing nonzero is a breakpoint.
 *
 * 'break_flag' is set if the breakpoint array 'breaks[i]' is set
 * for address 'i'.
 * There is currently no breaks_start and breaks_end variables,
 * so another start value than 0 will not work.
 */
extern u_char *breaks;		/* Physical storage for breakpoints */
extern int    break_flag;	/* Non-zero if an address containing a
				   breakpoint has been accessed by mem_xxx */
extern u_int  break_addr;	/* Last breakpoint address accessed */


/*
 *  mem_getb - called to get a byte from an address
 */
static int
mem_getb (addr)
	u_int addr;
{
	int offs = addr - ireg_start;

	if (breaks[addr]) {
		break_flag = 1; /* Signal execution loop to stop */
		break_addr = addr;
	}

	if (offs >= 0 && offs < NIREGS) {
		if (ireg_getb_func[offs])
			return (*ireg_getb_func[offs])(offs);
		else
			return iram[offs];
	} else if (addr >= ram_start && addr <= ram_end) {
		return ram[addr];
	} else {
		error ("mem_getb: addr=%04x, subroutine %04x\n",
			addr, callstack_peek_addr ());
		return 0;
	}
}

static int
mem_getw (addr)
	u_int addr;
{
	/* Make sure hi byte is accessed first */
	u_char hi = mem_getb (addr);
	u_char lo = mem_getb (addr + 1);
	return (hi << 8) | lo;
}

/*
 * mem_putb - called to write a byte to an address
 */
static void
mem_putb (addr, value)
	u_int   addr;
	u_char  value;
{
	int offs = addr - ireg_start; /* Address of on-chip memory */

	if (breaks[addr]) {
		break_flag = 1; /* Signal execution loop to stop */
		break_addr = addr;
	}

	if (offs >= 0 && offs < NIREGS) {
		if (ireg_putb_func[offs])
			(*ireg_putb_func[offs])(offs, value);
		else
			iram [offs] = value;
	} else if (addr >= ram_start && addr <= ram_end) {
		ram [addr] = value;
	} else {
		error ("mem_putb: addr=%04x, subroutine %04x\n",
			addr, callstack_peek_addr ());
	}
}

static void
mem_putw (addr, value)
	u_int addr;
	u_int value;
{
	mem_putb (addr, value >> 8);		/* hi byte */
	mem_putb (addr + 1, value & 0xFF);	/* lo byte */
}

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif


/* memory.c */
extern u_char *mem_init        P_(());
extern int     mem_print_ascii P_((u_int startaddr, u_int nbytes));
extern int     mem_print       P_((u_int startaddr, u_int nbytes, u_int nperline));

#undef P_

#endif
