/* <<<                                  */
/* Copyright (c) 1994-1996 Arne Riiber. */
/* All rights reserved.                 */
/* >>>                                  */
#include <stdio.h>

#include "defs.h"
#include "chip.h"
#include "memory.h"	/* ireg_getb/putb */
#include "sci.h"
#include "ireg.h"

#ifdef USE_PROTOTYPES
#endif

/*
 * Start/end of internal register block
 *
 * Note: 6800 does not have internal registers, but due to the limitations of
 * the simulator architecture, I have added the Altair 680 ACIA as an internal
 * peripheral (otherwise the 6800 wouldn't be able to do anything with no I/O)
 *
 * Note: there is a strapping port at 0xf002 which has to return bit 7 = 0 or
 * the Altair 680 monitor won't start -- but I have not implemented this for
 * the time being and instead it's just memory which will be initialized to 0
 */
u_int	ireg_start = 0xf000;
u_char	iram[NIREGS];

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif

/*
 *  Pointers to functions to be called for reading internal registers
 */
int (*ireg_getb_func[NIREGS]) P_((u_int offs)) = {
/* 0xf000 */
	sr_getb, rdr_getb
};

/*
 *  Pointers to functions to be called for writing internal registers
 */
int (*ireg_putb_func[NIREGS]) P_((u_int offs, u_char val)) = {
/* 0xf000 */
	cr_putb, tdr_putb
};

#undef P_
