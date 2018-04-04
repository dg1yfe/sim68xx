# Makefile Motorola free assemblers
MV	= mv
AS	= $(HOME)/bin/as0
#	Flags for generating symbol file
ASFLAGS	= - s
#	Flags for generating listing file
#ASFLAGS	= - cre l
RM	= rm -f

.SUFFIXES: .s19 .asm

.asm.s19:
	$(AS) $< $(ASFLAGS) > $*.sym

all: bigtst00.s19

clean:
	-$(RM) *.s19 *.sym *.lst

