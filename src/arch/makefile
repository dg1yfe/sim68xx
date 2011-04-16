SUBDIRS	= m68xx h6301 m6805 m6811

all clean default depend realclean:
	for f in $(SUBDIRS); do cd $$f; $(MAKE) $@; cd ..; done

