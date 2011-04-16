/* Automagically generated Fr 15 Apr 2011 09:30:58 CEST - dont edit */
#ifndef ERROR_H
#define ERROR_H

#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

//extern FILE *fopen _P((int fprintf (FILE *, const char *, ...), int fputc (int, FILE *)));
extern FILE    *fopen(const char * __restrict, const char * __restrict);
extern int error _P((va_list format, ...));
extern int warning _P((va_list format, ...));

#undef _P
#endif /* ERROR_H */
