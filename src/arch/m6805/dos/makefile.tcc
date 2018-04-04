ARCH	= 68xx
ROOT	= ../../..
INCROOT	= $(ROOT)/inc
INCDIR	= $(INCROOT)/$(ARCH)
INCLUDES= -I$(INCDIR)/m6805 -I$(INCDIR) -I$(INCROOT)
DEFINES	= -DUSE_PROTOTYPES
#CFLAGS	= -g -Wmissing-prototypes
CPPFLAGS= -DM6805 $(INCLUDES) $(DEFINES)
CC	= tcc
RM	= del

# Chip specific object files
OFILES=\
	memory.obj\
	iregtab.obj\
	reg.obj\
	opfunc.obj\
	optab.obj\
#	instr.obj\
#	sci.obj\
#	spi.obj\
#	timer.obj

default: all
all:     $(OFILES)
clean:
	-$(RM) *.obj

memory.obj: ../memory.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../memory.c
reg.obj: ../reg.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c ../reg.c


.c.obj:
	$(CC) $(CPPFLAGS) $(CFLAGS) -c $<

makefile.tcc: makefile turboc.cfg
	cat makefile | sed 's/\.obj/\.obj'\
		| sed 's/^RM.*/RM	= del/' \
 		| sed 's/^CC.*/CC	= tcc/' \
		| sed 's/^CFLAGS/CFLAGS	= -ml -v' > makefile.tcc
turboc.cfg:
	echo "-I/tc/include -L/tc/lib" > turboc.cfg

