#
# DSTC top-level makefile.
# Builds code and examples
#
#
# To make life easier, consider using the Reliable Multicast build
# docker container: github.com/magnusfeuer/reliable-multicast-build
# This container can also build dstc and its debian packages.
#

.PHONY: all clean distclean install uninstall examples install_examples

INST_HDR=dstc.h
HDR=${INST_HDR} dstc_internal.h


export RMC_INCDIR ?= /usr/local/include
export RMC_LIBDIR ?= /usr/local/lib

export INSTALL_DIR ?= /usr/local

#
# Source
#
SRC=dstc.c poll.c epoll.c
OBJ=${patsubst %.c, %.o, ${SRC}}

#
# Extract the version to use when building .so files
# and debian packages.
#
# Note: Make sure that any git tags or releases match this
# file.
#
VERSION != grep '^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*$$' VERSION
VERSION_MAJOR ?= $(word 1, $(subst ., ,$(VERSION)))

# Required Reliable Multicast (RMC) version in order
# to build DSTC and DSTC-linking apps.
#
# Will be baked into the dstc debian package as a dependency.
#
RMC_VERSION != grep '^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*$$' RMC_VERSION
REQUIRED_RMC_VERSION ?= >= ${RMC_VERSION}

LIB_TARGET=libdstc.a
LIB_SO_BASE_NAME=libdstc.so
LIB_SO_TARGET=${LIB_SO_BASE_NAME}.${VERSION}
LIB_SO_SONAME_TARGET=${LIB_SO_BASE_NAME}.${VERSION_MAJOR}
ARCHITECTURE=amd64

#
# Debian names for the regular and -dev package.
#
PACKAGE_BASE_NAME=dstc
DEBIAN_PACKAGE_BASE_NAME=${PACKAGE_BASE_NAME}_${VERSION}-1_${ARCHITECTURE}
DEBIAN_PACKAGE_NAME=${DEBIAN_PACKAGE_BASE_NAME}.deb

PACKAGE_DEV_BASE_NAME=dstc-dev
DEBIAN_PACKAGE_DEV_BASE_NAME=${PACKAGE_DEV_BASE_NAME}_${VERSION}-1_all
DEBIAN_PACKAGE_DEV_NAME=${DEBIAN_PACKAGE_DEV_BASE_NAME}.deb

DEBIAN_INSTALL_DIR ?= /usr/local

TARBALL_BASE_NAME=${PACKAGE_BASE_NAME}-${VERSION}
TARBALL_NAME=${TARBALL_BASE_NAME}.tar.gz

#
# List of directories under 'examples' to build when make runs.
#
# This list is also used to collect all example source files to be
# included in the dstc debian source package
#
export EXAMPLES= thread_stress \
	print_name_and_age \
	dynamic_data \
	string_data \
	print_struct \
	callback \
	callback_dyndata \
	no_argument \
	stress \
	loopback \
	chat \
	many_arguments \
#	cpp - Makefile needs udpating

ifeq (${POLL}, 1)
USE_POLL=-DUSE_POLL=1
export USE_POLL
endif

CFLAGS ?=-fPIC -O2 -I${RMC_INCDIR} -Wall -pthread -D_GNU_SOURCE ${USE_POLL} #-DDSTC_PTHREAD_DEBUG

#
# Build the entire project.
#
all:  ${LIB_TARGET} ${LIB_SO_TARGET}

#
#	Rebuild the static target library.
#
${LIB_TARGET}: ${OBJ}
	ar r ${LIB_TARGET} ${OBJ}

#
#	Rebuild the shared object target library.
#
${LIB_SO_TARGET}:  ${OBJ}
	${CC} -shared ${CFLAGS} ${OBJ} -L${RMC_LIBDIR} -o ${LIB_SO_TARGET}


${OBJ}: ${SRC} ${HDR}
	${CC} -c ${CFLAGS} ${patsubst %.o,%.c, $@} -o $@



#
#	Remove all the generated files in this project.  Note that this does NOT
#	remove the generated files in the submodules.  Use "make distclean" to
#	clean up the submodules.
#
clean:
	rm -f  ${OBJ} *~ ${LIB_TARGET} ${LIB_SO_TARGET} \
		${DEBIAN_PACKAGE_NAME} ${DEBIAN_PACKAGE_DEV_NAME}
	make -C examples clean


#
#	Install the generated files.
#
install: ${LIB_SO_TARGET} ${LIB_TARGET} uninstall
	install -d ${INSTALL_DIR}/lib
	install -d ${INSTALL_DIR}/include
	install -m 0644 ${INST_HDR}  ${INSTALL_DIR}/include
	install -m 0644 ${LIB_TARGET}  ${INSTALL_DIR}/lib
	install -m 0644 ${LIB_SO_TARGET}  ${INSTALL_DIR}/lib
	(cd ${INSTALL_DIR}/lib && ln -s ${LIB_SO_TARGET} ${LIB_SO_SONAME_TARGET})
	(cd ${INSTALL_DIR}/lib && ln -s ${LIB_SO_TARGET} ${LIB_SO_BASE_NAME})
	INSTALL_DIR=${INSTALL_DIR}/share/dstc/examples make -C examples install

#
#	Uninstall the generated files.
#
uninstall:
	INSTALL_DIR=${INSTALL_DIR}/share/dstc/examples ${MAKE} -C examples uninstall;
	rm -f ${INSTALL_DIR}/lib/${LIB_TARGET};
	rm -f ${INSTALL_DIR}/include/${INST_HDR};
	rm -f ${INSTALL_DIR}/lib/${LIB_SO_TARGET};
	rm -f ${INSTALL_DIR}/lib/${LIB_SO_BASE_NAME};
	rm -f ${INSTALL_DIR}/lib/${LIB_SO_SONAME_TARGET}
	@-rmdir ${INSTALL_DIR}/lib
	@-rmdir ${INSTALL_DIR}/include
	@-rmdir ${INSTALL_DIR}/share/dstc/examples
	@-rmdir ${INSTALL_DIR}/share/dstc
	@-rmdir ${INSTALL_DIR}/share

tar: ${TARBALL_NAME}

${TARBALL_NAME}: clean
	tar  -cvzf ${@} --transform "s,^,${TARBALL_BASE_NAME}/,"  *


#
# Requires fpm https://fpm.readthedocs.io/en/v1.15.1/index.html
#
debian: INSTALL_DIR=/tmp/dstc-install
debian: clean install ${DEBIAN_PACKAGE_DEV_NAME} ${DEBIAN_PACKAGE_NAME}

#
# Create DSTC library package
#
${DEBIAN_PACKAGE_NAME}: INSTALL_DIR=/tmp/dstc-install
${DEBIAN_PACKAGE_NAME}: install
	rm -f ${DEBIAN_PACKAGE_NAME}
	echo -e "#!/usr/bin/env bash\n/usr/sbin/ldconfig" > /tmp/postinst.sh
	chmod 755 /tmp/postinst.sh
	fpm -s dir -t deb \
		-p ${@} \
		--name ${PACKAGE_BASE_NAME} \
		--prefix ${DEBIAN_INSTALL_DIR} \
		--license mplv2 \
		--version ${VERSION} \
		--architecture ${ARCHITECTURE} \
		--depends "libc6 (>= 2.31)" \
		--depends "reliable-multicast (${REQUIRED_RMC_VERSION})" \
		--description "DSTC - Distributed C library" \
		--url "https://github.com/magnusfeuer/dstc" \
		--maintainer "Magnus Feuer" \
		--after-install=/tmp/postinst.sh \
		--after-remove=/tmp/postinst.sh \
		--after-upgrade=/tmp/postinst.sh \
		${INSTALL_DIR}/lib/${LIB_TARGET}=lib/${LIB_TARGET} \
		${INSTALL_DIR}/lib/${LIB_SO_SONAME_TARGET}=lib/${LIB_SO_SONAME_TARGET} \
		${INSTALL_DIR}/lib/${LIB_SO_TARGET}=lib/${LIB_SO_TARGET} \
		${INSTALL_DIR}/lib/${LIB_SO_BASE_NAME}=lib/${LIB_SO_BASE_NAME}

#
# Create development package, including examples
#
${DEBIAN_PACKAGE_DEV_NAME}: INSTALL_DIR=/tmp/dstc-install

#
# Traverse all files in the specified examples and construct FPM file
# arguments.
#
${DEBIAN_PACKAGE_DEV_NAME}: EXAMPLE_FILES != \
	for example_dir in ${EXAMPLES}; \
	do \
		for example_file in ${INSTALL_DIR}/share/dstc/examples/$$example_dir/*; \
		do \
			echo "$$example_file=/share/dstc/examples/$$example_file"; \
		done \
	done

${DEBIAN_PACKAGE_DEV_NAME}: install examples_clean
	fpm -s dir -t deb \
		-p ${@} \
		--name ${PACKAGE_DEV_BASE_NAME} \
		--license mplv2 \
		--version ${VERSION} \
		--prefix ${DEBIAN_INSTALL_DIR} \
		--architecture all \
		--description "DSTC - Distributed C development package" \
		--url "https://github.com/magnusfeuer/dstc" \
		--maintainer "Magnus Feuer" \
		${INSTALL_DIR}/include/dstc.h=include/dstc.h \
		${EXAMPLE_FILES}

#
# Build the examples listed in EXAMPLES
#
examples: all
# Create the necessary .so files in a dedicated directory
	INSTALL_DIR=${PWD}/build make install
	DSTC_LIBDIR=${PWD}/build/lib DSTC_INCDIR=${PWD} $(MAKE) -C examples;
	rm -r ${PWD}/build

examples_clean:
	$(MAKE) -C examples clean
