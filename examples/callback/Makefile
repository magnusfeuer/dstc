#
# Executable example code from the README.md file
#


NAME=callback

TARGET_CLIENT=${NAME}_client
TARGET_NOMACRO_CLIENT=${TARGET_CLIENT}_nomacro

CLIENT_OBJ=${NAME}_client.o
CLIENT_SOURCE=$(CLIENT_OBJ:%.o=%.c)

CLIENT_NOMACRO_OBJ=$(CLIENT_OBJ:%.o=%_nomacro.o)
CLIENT_NOMACRO_SOURCE=$(CLIENT_NOMACRO_OBJ:%.o=%.c)

#
# Server
#
TARGET_SERVER=${NAME}_server
TARGET_NOMACRO_SERVER=${TARGET_SERVER}_nomacro

SERVER_OBJ=${NAME}_server.o
SERVER_SOURCE=$(SERVER_OBJ:%.o=%.c)

SERVER_NOMACRO_OBJ=$(SERVER_OBJ:%.o=%_nomacro.o)
SERVER_NOMACRO_SOURCE=$(SERVER_NOMACRO_OBJ:%.o=%.c)

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

all: $(TARGET_SERVER) $(TARGET_CLIENT)

nomacro:  $(TARGET_NOMACRO_SERVER) $(TARGET_NOMACRO_CLIENT)

$(TARGET_SERVER): $(SERVER_OBJ)
	$(CC) $(CFLAGS) $(SERVER_OBJ) ${LIBRARY_PATHS} -ldstc -lrmc -o $@ $(LDFLAGS)


$(TARGET_CLIENT): $(CLIENT_OBJ)
	$(CC) $(CFLAGS) $(CLIENT_OBJ) ${LIBRARY_PATHS} -ldstc -lrmc -o $@ $(LDFLAGS)


clean:
	rm -f $(TARGET_CLIENT) $(CLIENT_OBJ) $(TARGET_SERVER) $(SERVER_OBJ)  *~ \
	$(TARGET_NOMACRO_CLIENT) $(TARGET_NOMACRO_SERVER) \
	$(CLIENT_NOMACRO_SOURCE) $(SERVER_NOMACRO_SOURCE) \
	$(CLIENT_NOMACRO_OBJ) $(SERVER_NOMACRO_OBJ)

install:
	install -d ${INSTALL_DIR}
	install -m 0644 ${CLIENT_SOURCE} ${INSTALL_DIR}
	install -m 0644 ${SERVER_SOURCE} ${INSTALL_DIR}
	install -m 0644 Makefile ${INSTALL_DIR}

uninstall:
	rm -f ${INSTALL_DIR}/${CLIENT_SOURCE}
	rm -f ${INSTALL_DIR}/${SERVER_SOURCE}
	rm -f ${INSTALL_DIR}/Makefile
	-rmdir ${INSTALL_DIR}

#
# Expand the dstc.h client and server macros that exports and import funcitons.
# Use these if you are debugging your code and need to see what is going on
# between your code and the dstc network traffic.
#
$(TARGET_NOMACRO_CLIENT) : $(CLIENT_NOMACRO_OBJ) $(DSTCLIB)
	$(CC) $(CFLAGS) $(LIBRARY_PATHS) $^ -ldstc -lrmc -o $@ $(LDFLAGS)

$(TARGET_NOMACRO_SERVER): $(SERVER_NOMACRO_OBJ) $(DSTCLIB)
	$(CC) $(CFLAGS) $(LIBRARY_PATHS) $^ -ldstc -lrmc -o $@ $(LDFLAGS)


$(CLIENT_NOMACRO_SOURCE): ${CLIENT_SOURCE}
	$(CC) ${INCLUDE_PATHS} -E ${CLIENT_SOURCE} | clang-format | grep -v '^# [0-9]' > ${CLIENT_NOMACRO_SOURCE}

$(SERVER_NOMACRO_SOURCE): ${SERVER_SOURCE}
	$(CC) ${INCLUDE_PATHS} -E ${SERVER_SOURCE} | clang-format | grep -v '^# [0-9]' > ${SERVER_NOMACRO_SOURCE}
