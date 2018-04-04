# Makefile Motorola free assemblers
MV	= mv
AS	= $(HOME)/bin/ashc5
#	Flags for generating symbol file
ASFLAGS	= - s
#	Flags for generating listing file
#ASFLAGS	= - cre l
RM	= rm -f

.SUFFIXES: .s19 .asm

.asm.s19:
	$(AS) $< $(ASFLAGS) > $*.sym

all: bittest.s19 monc8.s19 assist05.s19 sciex.s19 timerex.s19 timing.s19

clean:
	-$(RM) *.s19 *.sym *.lst


