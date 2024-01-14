
.PHONY: all clean install uninstall
export RMC_LIBDIR
export DSTC_LIBDIR
export RMC_INCDIR
export DSTC_INCDIR
export USE_POLL

all: $(EXAMPLES)
	@for dir in $(EXAMPLES); \
	do \
		$(MAKE) -C $$dir; \
	done

clean: $(EXAMPLES)
	@for dir in $(EXAMPLES); \
	do \
	    $(MAKE) -C $$dir clean; \
	done


install: $(EXAMPLES)
	@for dir in $(EXAMPLES); \
	do \
		INSTALL_DIR=${INSTALL_DIR}/$$dir $(MAKE)  -C $$dir install; \
	done \


uninstall: $(EXAMPLES)
	@for dir in $(EXAMPLES); \
	do \
		INSTALL_DIR=${INSTALL_DIR}/$$dir $(MAKE)  -C $$dir uninstall; \
	done

