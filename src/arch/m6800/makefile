include ../../default.mk

ROOT	= ../../..
INCROOT	= $(ROOT)/inc
INCLUDES= -I$(INCROOT)/arch/m6800 -I$(INCROOT)/arch/m68xx -I$(INCROOT)/base
DEFINES	= -DUSE_PROTOTYPES -DHAS_SCI -DM6800
CPPFLAGS= $(DEFINES) $(INCLUDES)

# Directories to parent source files
BASE	= ../../base
M68XX	= ../m68xx

# Non-chip specific object files
OFILES_BASE=\
	callstac.o\
	command.o\
	cpu.o\
	fileio.o

# Chip specific object files
OFILES_M68XX=\
	alu.o\
	memory.o\
	io.o\
	reg.o\
	opfunc.o

OFILES_M6800=\
	instr.o\
	ireg.o\
	optab.o\
	sci.o

OFILES	= $(OFILES_BASE) $(OFILES_M68XX) $(OFILES_M6800)

CFILES_BASE	= $(OFILES_BASE:%.o=$(BASE)/%.c)
CFILES_M68XX	= $(OFILES_M68XX:%.o=$(M68XX)/%.c)
CFILES_M6800	= $(OFILES_M6800:%.o=%.c)
CFILES		= $(CFILES_BASE) $(CFILES_M68XX) $(CFILES_M6800)


default: all
all:     $(OFILES)
clean:
	-$(RM) *.o
realclean: clean
	-$(RM) .depend *~
# This line confuses Sun make
depend .depend:
	$(COMPILE.c) -MM $(CFILES) > .depend
include .depend

$(OFILES_BASE): %.o: $(BASE)/%.c
	$(COMPILE.c) $< $(OUTPUT_OPTION)
$(OFILES_M68XX): %.o: $(M68XX)/%.c
	$(COMPILE.c) $< $(OUTPUT_OPTION)
$(OFILES_M6800): %.o: %.c
	$(COMPILE.c) $< $(OUTPUT_OPTION)

