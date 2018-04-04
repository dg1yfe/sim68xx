# Makefile Turbo C 2.0
ROOT    = ../..
INCDIR	= $(ROOT)/inc/68xx
INCDIR2	= $(ROOT)/inc
INCLUDES= -I$(INCDIR) -I$(INCDIR2)
#DEFINES =-DUSE_PROTOTYPES

CC	= tcc
CFLAGS	= -ml -v
CPPFLAGS= -I/tc/include $(INCLUDES) $(DEFINES)
AR	= tlib
LDFLAGS = $(CFLAGS) -L/tc/lib
RM	= del
MV	= move

LIBFILES= \
	m6800/opfunc.obj \
        m6801/opfunc.obj \
        h6301/opfunc.obj \
        m6805/opfunc.obj \
        m6811/opfunc.obj \
        alu.obj \
        cmd.obj
OFILES	= $(LIBFILES)
# Sweet tlib command/file list
TLIBFILES=\
	+-alu.obj\
	+-cmd.obj\
	+-m6800\op6800.obj\
	+-m6801\op6801.obj\
	+-h6301\op6301.obj\
	+-m6805\op6805.obj\
	+-m6811\op6811.obj

# Chip specific object files
# Preliminary use 6301 opcode table for 6800
OBJ6800 = m6800/memory.obj m6800/iregtab.obj m6800/instr.obj h6301/reg.obj h6301/optab.obj
#OBJ6301 = h6301/memory.obj h6301/iregtab.obj h6301/instr.obj h6301/reg.obj h6301/optab.obj
#OBJ6805 = m6805/memory.obj m6805/iregtab.obj m6805/instr.obj m6805/reg.obj m6805/optab.obj
#OBJ6811 = m6811/memory.obj m6811/iregtab.obj m6811/instr.obj m6811/reg.obj m6811/optab.obj
#OBJALL  = $(OFILES) $(OBJ6800) $(OBJ6301) $(OBJ6805) $(OBJ6811)

default: $(OFILES)
all:     default
clean:
	$(RM) *.obj
	$(RM) *.lib
	$(RM) *.exe
	cd m6800
	$(RM) *.obj
	cd ..\m6801
	$(RM) *.obj
	cd ..\h6301
	$(RM) *.obj
	cd ..\m6805
	$(RM) *.obj
	cd ..\m6811
	$(RM) *.obj
	cd ..

# Executable targets
sim6800: sim6800.exe

# sweet tcc: output file name is from first .obj file, regardless of -oxxx
sim6800.exe: 68xx.lib ../sim.lib $(OBJ6800)
#	$(CC) $(LDFLAGS) $^
#	$(MV) m6800\memory.exe .\sim6800.exe
	tlink @link6800.tcc

68xx.lib: $(LIBFILES)
	$(AR) $@ $(TLIBFILES)
# sweet tlib: doesn't understand the directory names => rename .obj files
# sweet td:   couldn't set breakpoints in C source if renamed in tlib as below
# solution: forget .lib file and link .obj files
#m6800/op6800.obj: m6800/opfunc.c
#	 $(CC) -DM6800 -I$(INCDIR)/m6800 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^
#m6801/op6801.obj: m6801/opfunc.c
#	 $(CC) -DM6801 -I$(INCDIR)/m6801 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^
#h6301/op6301.obj: h6301/opfunc.c
#	 $(CC) -DH6301 -I$(INCDIR)/h6301 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^
#m6805/op6805.obj: m6805/opfunc.c
#	 $(CC) -DM6805 -I$(INCDIR)/m6805 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^
#m6811/op6811.obj: m6811/opfunc.c
#	 $(CC) -DM6811 -I$(INCDIR)/m6811 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^

m6800/%.obj: %.c
	$(CC) -DM6800 -I$(INCDIR)/m6800 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
m6800/%.obj: m6800/%.c
	$(CC) -DM6800 -I$(INCDIR)/m6800 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
m6800/instr.obj: h6301/instr.c
	$(CC) -DM6800 -I$(INCDIR)/m6800 $(CPPFLAGS) $(CFLAGS) -c -o${@} $^

m6801/%.obj: %.c
	$(CC) -DM6801 -I$(INCDIR)/m6801 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
m6801/%.obj: m6801/%.c
	$(CC) -DM6800 -I$(INCDIR)/m6800 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<

h6301/%.obj: %.c
	$(CC) -DH6301 -I$(INCDIR)/h6301 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
h6301/%.obj: h6301/%.c
	$(CC) -DH6301 -I$(INCDIR)/h6301 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<

m6805/%.obj: %.c
	$(CC) -DM6805 -I$(INCDIR)/m6805 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
m6805/%.obj: m6805/%.c
	$(CC) -DM6805 -I$(INCDIR)/m6805 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<

m6811/%.obj: %.c
	$(CC) -DM6811 -I$(INCDIR)/m6811 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<
m6811/%.obj: m6811/%.c
	$(CC) -DM6811 -I$(INCDIR)/m6811 $(CPPFLAGS) $(CFLAGS) -c -o${@} $<

%.obj: %.c
	$(CC) $(CPPFLAGS) $(CFLAGS) -c -o${@} $<

# Automatic generation of header files
.include:
	cd $(INCDIR2); $(MAKE)
.sim:
	cd ../; $(MAKE)

