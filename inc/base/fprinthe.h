/* Automagically generated Fr 15 Apr 2011 09:30:58 CEST - dont edit */
#ifndef FPRINTHE_H
#define FPRINTHE_H

#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

extern FILE *fopen _P((int fprintf (FILE *, const char *, ...), int fputc (int, FILE *)));
extern int void _P(((int )));
extern int getrlimit _P((int getrusage (int, struct rusage *), int setrlimit (int, const struct rlimit *)__asm (0 0 )));
extern pid_t wait _P((pid_t waitpid (pid_t, int *, int )__asm (0 0 )));
extern void abort _P((int atexit (void (*)(void ))));
extern int fprinthex _P((FILE *fp, unsigned char *buf, int len));

#undef _P
#endif /* FPRINTHE_H */
