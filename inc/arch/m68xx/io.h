/* Automagically generated Wed Oct  9 07:41:07 GMT+0100 1996 - dont edit */
#ifndef M68XX_IO_H
#define M68XX_IO_H

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif


/* ../../src/arch/m68xx/io.c */
extern int out_in P_((u_char *buf, int nbytes));
extern int out_print P_((int buf, int nbytes));
extern int io_poll P_((void));
extern int io_putb P_((u_char value));
extern int io_cmd P_((int argc, char *argv[]));

#undef P_
#endif /* M68XX_IO_H */
