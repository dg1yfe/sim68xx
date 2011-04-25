#ifndef INSTR_H
#define INSTR_H

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif

#if defined(H6303)
extern u_int rti_pc;
#endif

extern void reset P_((void));
extern int instr_exec P_((void));
extern u_int instr_print P_((u_int addr));

#undef P_
#endif /* INSTR_H */
