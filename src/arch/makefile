SUBDIRS	= m68xx h6301 h6303 m6805 m6811
H6303DIRS = m68xx h6303

h6303:
	for f in $(H6303DIRS); do cd $$f; $(MAKE) $@; cd ..; done

all clean default depend realclean:
	for f in $(SUBDIRS); do cd $$f; $(MAKE) $@; cd ..; done
