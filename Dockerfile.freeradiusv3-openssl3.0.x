#
#	Author: Jorge Pereira <jpereira@freeradius.org>
#   Desc: Freeradius Development Box
#
FROM ubuntu:21.04

LABEL maintainer "Jorge Pereira <jpereira@freeradius.org>"

ARG osname=hirsute
ARG DEBIAN_FRONTEND=noninteractive
ARG fr_repo
ARG fr_branch
ARG APT_OPTS="-y --option=Dpkg::options::=--force-unsafe-io --no-install-recommends"

#
#   Disable apt-get over ipv6
#
RUN echo 'Acquire::ForceIPv4 "true";' | tee /etc/apt/apt.conf.d/99force-ipv4

#
#  Install add-apt-repository
#
RUN sed 's/archive.ubuntu.com/br.archive.ubuntu.com/g' -i /etc/apt/sources.list
RUN apt-get update && \
    apt-get install -y software-properties-common aptitude apt-utils && \
    apt-get clean && \
    rm -r /var/lib/apt/lists/*

#
#   Update
#
RUN apt-get update

#
# 	Fix locale
#
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales apt-utils

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

ENV LANG en_US.UTF-8 

#
#   Utilities
#
RUN apt-get install -y dialog telnet netcat iproute2 ldap-utils

#
#   Development utilities
#
RUN apt-get install -y cmake devscripts equivs git git-lfs quilt build-essential moreutils \
			google-perftools libgoogle-perftools-dev \
			libcollectdclient-dev \
			libosmo-sccp-dev \
			libunbound-dev \
			libidn11-dev libidn11-dev firebird-dev xutils-dev \
			libosmo-abis-dev libosmo-fl2k-dev libosmo-mgcp-client-dev libosmo-netif-dev \
			libosmo-ranap-dev libosmo-sccp-dev libosmo-sigtran-dev libosmocore-dev libosmosdr-dev

#
#
#   eapol_test dependencies
#
RUN apt-get install -y libnl-3-dev libnl-genl-3-dev

#
#	Usual commands.
#
RUN apt-get install -y screen vim wget ssl-cert gdb manpages-dev strace valgrind sysdig \
                        psmisc htop openssh-server tcpdump net-tools sysvbanner \
                        iputils-ping sudo lsof extrace sshpass

#
#	Add ubuntu user
#
RUN groupadd ubuntu && \
	useradd -rm -d /home/ubuntu -s /bin/bash -g ubuntu -p "$(openssl passwd -1 ubuntu)" ubuntu

#
#  Grab & Install OpenSSL 3.0x in /opt/openssl
#
ENV OPENSSL_VERSION=3.0.2

WORKDIR /opt/src
RUN wget https://www.openssl.org/source/openssl-${OPENSSL_VERSION}.tar.gz
RUN tar xzf openssl-${OPENSSL_VERSION}.tar.gz
WORKDIR openssl-${OPENSSL_VERSION}
RUN ./Configure --prefix=/opt/openssl --openssldir=.
RUN make -j `nproc` && make install
RUN echo /opt/openssl/lib64 | sudo tee /etc/ld.so.conf.d/openssl3.conf >/dev/null && ldconfig
RUN PATH="/opt/openssl/bin:$PATH"
RUN export PATH

#
#
#  Shallow clone the FreeRADIUS source
#
WORKDIR /opt/src
RUN git       clone    ${fr_repo}
WORKDIR /opt/src/freeradius-server

#
#  Install build dependencies for all branches from v3 onwards
#

WORKDIR /opt/src/freeradius-server
RUN git checkout ${fr_branch}
RUN debian/rules debian/control
RUN echo 'y' | mk-build-deps -irt'apt-get -yV' debian/control
RUN ./configure \
		--with-openssl-lib-dir=/opt/openssl/lib64 \
		--with-openssl-include-dir=/opt/openssl/include \
		--config-cache \
		--disable-developer \
		--disable-openssl-version-check \
		--prefix=/usr \
		--exec-prefix=/usr \
		--mandir=/usr/share/man \
		--sysconfdir=/etc \
		--libdir=/usr/lib \
		--datadir=/usr/share \
		--localstatedir=/var \
		--with-raddbdir=/etc/raddb \
		--with-logdir=/var/log/radius \
		--enable-reproducible-builds

RUN make -j4 && make install

# eapol_test
WORKDIR /opt/src/freeradius-server
RUN ./scripts/ci/eapol_test-build.sh
RUN cp -f ./scripts/ci/eapol_test/eapol_test /usr/local/bin
COPY config/eap-ttls-mschapv2.conf /root/eap-ttls-mschapv2.conf

# Configs
COPY config/authorize /etc/raddb/mods-config/files/authorize
COPY config/eap /etc/raddb/mods-available/eap
COPY config/default /etc/raddb/sites-available/default
RUN sed 's/@@SET_SECLEVEL@@/0/g' -i /etc/raddb/mods-available/eap

#
#   Default HOME
#
COPY config/dot.bash_history /root/.bash_history
WORKDIR /root

#
#   Usual ports auth/accounting/coa/ssh
#
EXPOSE 1812/udp 1812/tcp 1813/udp 1813/tcp 3799/udp 22/tcp

CMD ["/usr/sbin/radiusd", "-XXXxxx", "-l", "/var/log/radiusd.log"]
