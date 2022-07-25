/* <<<                                  */
/* Copyright (c) 1994-1996 Arne Riiber. */
/* All rights reserved.                 */
/* >>>                                  */
#include <stdio.h>

#include "defs.h"
#include "chip.h"
#include "memory.h"	/* ireg_getb/putb */
#include "ireg.h"

#ifdef USE_PROTOTYPES
#endif

/*
 * Start/end of internal register block
 */
u_int	ireg_start = 0;
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
};


/*
 *  Pointers to functions to be called for writing internal registers
 */
int (*ireg_putb_func[NIREGS]) P_((u_int offs, u_char val)) = {
};

#undef P_
