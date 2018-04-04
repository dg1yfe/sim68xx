ARCH	= 68xx
ROOT	= ../../..
INCROOT	= $(ROOT)/inc
INCDIR	= $(INCROOT)/$(ARCH)
INCLUDES= -I$(INCDIR)/m6800 -I$(INCDIR) -I$(INCROOT)
DEFINES	= -DUSE_PROTOTYPES
#CC	= tcc -I/tc/include -ml
CC	= tcc 
#CFLAGS	= -g -Wmissing-prototypes
CPPFLAGS= -DM6800 $(INCLUDES) $(DEFINES)
RM	= del
O	= obj

# Chip specific object files
OFILES=\
	memory.$(O)\
	iregtab.$(O)\
	reg.$(O)\
	opfunc.$(O)\
	optab.$(O)\
	instr.$(O)


default: $(OFILES)
all:     default
clean:
	-$(RM) *.obj

memory.$(O): ../memory.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../memory.c
reg.$(O): ../reg.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../reg.c


# Preliminary use 6301 opcode table for 6800
optab.$(O): ../h6301/optab.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../h6301/optab.c
instr.$(O): ../h6301/instr.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../h6301/instr.c

.c.$(O):
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<
