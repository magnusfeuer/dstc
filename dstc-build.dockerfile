# Dockerfile for a generic build container
# Thanks to Ravi Chandran: https://opensource.com/article/20/4/how-containerize-build-system

FROM ubuntu:22.04
LABEL maintainer="Magnus Feuer"

SHELL ["/bin/bash", "-c"]

# Create non-root user:group and generate a home directory to support SSH
ARG USERNAME
RUN adduser --disabled-password --gecos '' ${USERNAME} \
    && adduser ${USERNAME} sudo                        \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY RMC_VERSION RMC_VERSION

# Install SW build system inside docker
# For our toy example, we install build-essential which installs
# required packages for C/C++.
RUN RMC_VERSION=$(grep '^[[:digit:]]*\.[[:digit:]]*\.[[:digit:]]*$' RMC_VERSION) \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       apt-get -y --quiet --no-install-recommends install \
       build-essential \
       git \
       wget \
       ruby-rubygems \
       squashfs-tools \
    && (cd /tmp; wget https://github.com/magnusfeuer/reliable_multicast/releases/download/v${RMC_VERSION}/reliable-multicast-dev_${RMC_VERSION}-1_all.deb) \
    && (cd /tmp; wget https://github.com/magnusfeuer/reliable_multicast/releases/download/v${RMC_VERSION}/reliable-multicast_${RMC_VERSION}-1_amd64.deb) \
    && apt-get -y --quiet --no-install-recommends install /tmp/reliable-multicast_${RMC_VERSION}-1_amd64.deb \
    && apt-get -y --quiet --no-install-recommends install /tmp/reliable-multicast-dev_${RMC_VERSION}-1_all.deb \
    && apt-get -y autoremove \
    && apt-get clean autoclean \
    && rm -fr /var/lib/apt/lists/{apt,dpkg,cache,log} /tmp/* /var/tmp/* 

#
# Install the FPM package manager to create debian and other packages
#
RUN gem install fpm



# Run container as non-root user from here onwards
# so that build output files have the correct owner
USER ${USERNAME}

# set up volumes
VOLUME /scripts
VOLUME /src

# run bash script and process the input command
ENTRYPOINT [ "/bin/bash", "/scripts/build.sh"]
