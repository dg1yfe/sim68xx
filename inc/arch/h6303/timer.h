/* Automagically generated Wed Oct  9 07:41:10 GMT+0100 1996 - dont edit */
#ifndef H6303_TIMER_H
#define H6303_TIMER_H

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif


/* ../../src/arch/h6303/timer.c */
extern int tcsr1_getb P_((u_int offs));
extern int tcsr1_putb P_((u_int offs, u_char value));
extern int ocr1_putb P_((u_int offs, u_char value));

extern void tcsr2_getb P_((u_int offs));
extern void tcsr2_putb P_((u_int offs, u_char value));
extern void ocr2_putb P_((u_int offs, u_char value));

extern int timer_inc P_((u_int ncycles));

#undef P_
#endif /* H6303_TIMER_H */
