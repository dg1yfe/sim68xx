ARCH	= 68xx
ROOT	= ../../..
INCROOT	= $(ROOT)/inc
INCDIR	= $(INCROOT)/$(ARCH)
INCLUDES= -I$(INCDIR)/h6301 -I$(INCDIR) -I$(INCROOT)
DEFINES	= -DUSE_PROTOTYPES
CFLAGS	= -ml -v -A	= -g #-Wmissing-prototypes
CPPFLAGS= -DH6301 $(INCLUDES) $(DEFINES)
CC	= tcc
RM	= del

# Chip specific object files
OFILES=\
	cmd.obj\
	memory.obj\
	iregtab.obj\
	reg.obj\
	opfunc.obj\
	optab.obj\
	sci.obj\
	instr.obj\
	timer.obj

default: all
all:     $(OFILES)
clean:
	-$(RM) *.obj *.bak *~ sim6301

sim6301:  $(OFILES) ../lib68xx.a ../../libsim.a
	$(CC) $(LDFLAGS) -o $@ $(OFILES) ../lib68xx.a ../../libsim.a 

cmd.obj:	../cmd.c
	$(CC) -DHAS_SCI $(CPPFLAGS) $(CFLAGS) -c ../cmd.c

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
		| sed 's/^CFLAGS/CFLAGS	= -ml -v -A' > makefile.tcc
turboc.cfg:
	echo "-I/tc/include -L/tc/lib" > turboc.cfg

cleantest:
	-command /c for %f in (*.c) do dir %f
#	+for %f in (*.c) do dir %f
