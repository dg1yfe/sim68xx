# Makefile to generate MSDOS/Turboc makefile from unix Makefile (unfinished)

makefile.tcc: makefile turboc.cfg sim6301.rsp
	cat makefile | sed 's/\.o/\.obj'\
		| sed 's/^RM.*/RM	= del/' \
 		| sed 's/^CC.*/CC	= tcc/' \
		| sed 's/^CFLAGS/CFLAGS	= -ml -v -A' \
		| sed 's/-$\(RM\)[ ]+(.+)/-command \/c for %f in (\1) do del %f/' \
		> makefile.tcc

turboc.cfg:
	echo "-I/tc/include -L/tc/lib" > turboc.cfg
sim6301.rsp: makefile
	cchome='\tc';\
	cclib="$${cchome}\lib";\
	model=l;\
	echo "$${cclib}\c0$${model}.obj+"	> sim6301.rsp;\
	for f in $(OFILES); do\
		echo $$f | sed 's/\.o/\.obj\+/'	>> sim6301.rsp;\
	done;\
	echo LIBFILES-TODO!			>> sim6301.rsp;\
	echo sim6301				>> sim6301.rsp;\
	echo /c/x/v				>> sim6301.rsp;\
	echo '..\..\sim.lib+'			>> sim6301.rsp;\
	echo "$${cclib}\EMU.LIB+"		>> sim6301.rsp;\
	echo "$${cclib}\math$${model}.lib+"	>> sim6301.rsp;\
	echo "$${cclib}\c$${model}.lib"		>> sim6301.rsp
