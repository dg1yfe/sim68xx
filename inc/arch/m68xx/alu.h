/* Automagically generated Fr 15 Apr 2011 09:30:58 CEST - dont edit */
#ifndef M68XX_ALU_H
#define M68XX_ALU_H

#if defined(__STDC__) || defined(__cplusplus)
# define _P(s) s
#else
# define _P(s) ()
#endif

/* Headers for ../../src/arch/m68xx/alu.c */
extern int alu_addbyte _P((u_char val1, u_char val2, u_char carry));
extern int alu_addword _P((u_int val1, u_int val2, u_char carry));
extern int alu_andbyte _P((u_char val1, u_char val2));
extern int alu_bittestbyte _P((u_char value));
extern int alu_bittestword _P((u_int value));
extern int alu_clrbyte _P((u_char value));
extern int alu_combyte _P((u_char value));
extern int alu_decbyte _P((u_char value));
extern int alu_decword _P((u_int value));
extern int alu_incbyte _P((u_char value));
extern int alu_incword _P((u_int value));
extern int alu_negbyte _P((u_char value));
extern int alu_orbyte _P((u_char val1, u_char val2));
extern int alu_xorbyte _P((u_char val1, u_char val2));
extern int alu_shlbyte _P((u_int operand, u_char lsbit));
extern int alu_shrbyte _P((u_int operand, u_char msbit));
extern int alu_shlword _P((u_int operand, u_char lsbit));
extern int alu_shrword _P((u_int operand, u_char msbit));
extern int alu_subbyte _P((u_char val1, u_char val2, u_char carry));
extern int alu_subword _P((u_int val1, u_int val2, u_char carry));
extern int alu_testbyte _P((u_char operand));
/* End of headers for ../../src/arch/m68xx/alu.c */

#undef _P
#endif /* M68XX_ALU_H */
