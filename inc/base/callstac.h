/* Automagically generated Fr 15 Apr 2011 09:30:58 CEST - dont edit */
#ifndef CALLSTAC_H
#define CALLSTAC_H

#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

extern int callstack_push _P((unsigned int addr));
extern int callstack_pop _P((void));
extern int callstack_peek_addr _P((void));
extern int callstack_peek_stack _P((void));
extern int callstack_nelem _P((void));
extern int callstack_print _P((void));
extern int callstack_trace _P((int on));

#undef _P
#endif /* CALLSTAC_H */
