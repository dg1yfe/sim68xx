# Makefile Motorola free assemblers
MV	= mv
AS	= $(HOME)/bin/as11
ASFLAGS	= - s
RM	= rm -f

.SUFFIXES: .s19 .asm

.asm.s19:
	$(AS) $< $(ASFLAGS) > $*.sym
.asm.sym:
	$(AS) $< $(ASFLAGS) > $@

all: bigtst00.s19 68mon.s19 timing.s19 buf.s19 buf_d3.s19 buf_k4.s19
sym:              68mon.sym timing.sym buf.sym buf_d3.sym buf_k4.sym

clean:
	-$(RM) *.s19 *.sym *.lst buf*.asm

buf.s19:	buf.asm
buf_d3.s19:	buf_d3.asm
buf_k4.s19:	buf_k4.asm

buf.asm:
	$(CO) -r3.4 -p buffalo.asm > $@
buf_k4.asm:
	$(CO) -rK4  -p buffalo.asm > $@
buf_d3.asm:
	$(CO) -rD3  -p buffalo.asm > $@


