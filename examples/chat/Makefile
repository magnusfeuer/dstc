#
# Executable example code from the README.md file
#


NAME=chat

TARGET=${NAME}
TARGET_NOMACRO=${TARGET}_nomacro

OBJ=${NAME}.o
SOURCE=$(OBJ:%.o=%.c)

NOMACRO_OBJ=$(OBJ:%.o=%_nomacro.o)
NOMACRO_SOURCE=$(NOMACRO_OBJ:%.o=%.c)

#
# Default paths, if nothing else is specified 
#
DSTC_INCDIR ?= /usr/local/lib
RMC_INCDIR ?= /usr/local/include
INCLUDE_PATHS ?= -I${DSTC_INCDIR} -I${RMC_INCDIR}

DSTC_LIBDIR ?= /usr/local/lib
RMC_LIBDIR ?= /usr/local/lib
LIBRARY_PATHS ?= -L${DSTC_LIBDIR} -L${RMC_LIBDIR}

INSTALL_DIR ?= /usr/local/share/dstc/examples/${NAME}

CFLAGS += ${INCLUDE_PATHS} -Wall -pthread -O2 ${USE_POLL}

.PHONY: all clean install nomacro uninstall

all: $(TARGET)

nomacro:  $(TARGET_NOMACRO) 


$(TARGET): $(OBJ)
	$(CC) $(CFLAGS) $(OBJ) ${LIBRARY_PATHS} -ldstc -lrmc -o $@ $(LDFLAGS)


clean:
	rm -f  $(OBJ) $(TARGET)   *~ \
	$(TARGET_NOMACRO) \
	$(NOMACRO_SOURCE) \
	$(NOMACRO_OBJ) 

install:
	install -d ${INSTALL_DIR}
	install -m 0644 ${SOURCE} ${INSTALL_DIR}
	install -m 0644 Makefile ${INSTALL_DIR}

uninstall:
	rm -f ${INSTALL_DIR}/${SOURCE}
	rm -f ${INSTALL_DIR}/Makefile
	-rmdir ${INSTALL_DIR}

#
# Expand the dstc.h client and server macros that exports and import funcitons.
# Use these if you are debugging your code and need to see what is going on
# between your code and the dstc network traffic.
#
$(TARGET_NOMACRO) : $(NOMACRO_OBJ) $(DSTCLIB)
	$(CC) $(CFLAGS) $(LIBRARY_PATHS) $^ -ldstc -lrmc -o $@ $(LDFLAGS)


$(NOMACRO_SOURCE): ${SOURCE}
	$(CC) ${INCLUDE_PATHS} -E ${SOURCE} | clang-format | grep -v '^# [0-9]' > ${NOMACRO_SOURCE}
