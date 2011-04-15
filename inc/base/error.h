/* Automagically generated Wed Oct  9 07:33:48 GMT+0100 1996 - dont edit */
#ifndef ERROR_H
#define ERROR_H

#if defined(__STDC__) || defined(__cplusplus)
# define P_(s) s
#else
# define P_(s) ()
#endif

extern int error P_((va_list format, ...));
extern int warning P_((va_list format, ...));

#undef P_
#endif /* ERROR_H */
