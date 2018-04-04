# Gnu makefile sim68xx documentation
# Linuxdoc programs (SGML2...)
SGML2HTML=sgml2html
SGML2TXT=sgml2txt
SGML2MAN=sgml2txt -man

.SUFFIXES: .html .sgml .txt .man

.sgml.html:
	$(SGML2HTML) $<
.sgml.txt:
	$(SGML2TXT) $<
.sgml.man:
	$(SGML2MAN) $<

default: sim68xx.man sim68xx.txt sim68xx.html usrguide.txt usrguide.html
clean: sim68xx.clean usrguide.clean

sim68xx.txt: sim68xx.man
	nroff -man $< | col -b > $@
sim68xx.html: sim68xx.man
	rman -f HTML $< > $@
sim68xx.clean:
	-rm sim68xx.man sim68xx.txt sim68xx.html

usrguide.txt: usrguide.sgml
usrguide.html: usrguide.sgml
usrguide.clean:
	-rm -f usrguide.txt usrguide*.html
