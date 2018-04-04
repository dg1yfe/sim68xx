# Gnu makefile sim68xx documentation
# For linuxdoc
#SGML2HTML=sgml2html
#SGML2TXT=sgml2txt
#SGML2MAN=sgml2txt -man
# For sdc typeset
OUTPUT_OPTION=-o $@
SDCFLAGS  = -V 2
#SGML2HTML= sdc $(SDCFLAGS) -O html -R HTML2 -R linuxdoc #linuxdoc No success
SGML2HTML = sdc $(SDCFLAGS) -O html -R HTML2 
SGML2PS   = sdc $(SDCFLAGS) -O ps -i epsfig
SGML2TEX  = sdc $(SDCFLAGS) -O latex
SGML2TXT  = sdc $(SDCFLAGS) -O ascii

TEX2DVI    = latex
DVI2PS     = dvips

.SUFFIXES: .html .sgml .txt .man .ps .dvi .tex .txt

.sgml.html:
	$(SGML2HTML) $< $(OUTPUT_OPTION)
.sgml.txt:
	$(SGML2TXT) $< $(OUTPUT_OPTION)
.sgml.man:
	$(SGML2MAN) $<
.sgml.ps:
	$(SGML2PS) $< $(OUTPUT_OPTION)

# TeX rules
.sgml.tex:
	$(SGML2TEX) $< $(OUTPUT_OPTION) && perl -i -pe 's/titlepage/titlepag/g' $@
.tex.dvi:
	$(TEX2DVI) $<
#.dvi.ps:
#	$(DVI2PS) -o $@ $<

default: usrguide.html
usrguide.ps: usrguide.sgml

clean: sim68xx.clean usrguide.clean
	-rm -f ts* lout.li *.toc *.log *.aux

#sim68xx.man: sim68xx.sgml
#	sgml2txt -man $<
#sim68xx.txt: sim68xx.man
#	nroff -man $< > $@
sim68xx.clean:
	-rm -f sim68xx.man sim68xx.txt

usrguide.clean:
	-rm -f usrguide.html usrguide.txt usrguide.dvi usrguide.ps
