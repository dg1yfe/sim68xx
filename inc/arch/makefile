# Makefile to automatically generate header files containing function prototypes.
# This only apply to simple header files, be careful before typing 'make clean'.
SRCDIR	= ../../src/arch
HFILES	=\
	m68xx/alu.h\
	m68xx/io.h\
	m68xx/opfunc.h\

# Program to extract function declarations from source files
# MKPROTOS= mkptypes -e


default: .include
all: .include

.include: $(HFILES)

$(HFILES): %.h: $(SRCDIR)/%.c
	filename=`echo "$@" | tr a-z A-Z | tr . _ | tr / _ ` ;\
	echo "/* Automagically generated `date` - dont edit */" > $@;\
	echo "#ifndef $$filename" >> $@;\
	echo "#define $$filename" >> $@;\
	echo "" >> $@;\
	$(MKPROTOS) $< >> $@;\
	echo "#endif /* $$filename */" >> $@
clean:
