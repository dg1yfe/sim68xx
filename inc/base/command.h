/* Automagically generated Wed Oct  9 07:33:42 GMT+0100 1996 - dont edit */
#ifndef COMMAND_H
#define COMMAND_H

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif

extern int unassemble P_((unsigned int addr, int ninstr));
extern void sig_int_handler P_((int subcode));
extern int split P_((char **cmd, char *buf, int *argc));
extern int commandprompt P_((void));
extern int commandinit P_((void));
extern int print_help P_((void));
extern int command P_((unsigned char *buf));
extern int commandloop P_((FILE *ifp));

#undef P_
#endif /* COMMAND_H */
