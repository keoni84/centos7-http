# =============================================================================
# 
# CentOS-latest - http/ssh
# 
# =============================================================================
FROM centos:latest

MAINTAINER John Headley <keoni84@gmail.com>

ENV container docker
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done) \
	&& rm -f /lib/systemd/system/multi-user.target.wants/* \
	&& rm -f /etc/systemd/system/*.wants/* \
	&& rm -f /lib/systemd/system/local-fs.target.wants/* \
	&& rm -f /lib/systemd/system/sockets.target.wants/*udev* \
	&& rm -f /lib/systemd/system/sockets.target.wants/*initctl* \
	&& rm -f /lib/systemd/system/basic.target.wants/* \
	&& rm -f /lib/systemd/system/anaconda.target.wants/*

# -----------------------------------------------------------------------------
# Import the RPM GPG keys for Centos Mirrors
# -----------------------------------------------------------------------------
RUN rpm --import http://mirror.centos.org/centos/RPM-GPG-KEY-CentOS-7

# -----------------------------------------------------------------------------
# Base Install
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install \
	vim-enhanced \
	sudo \
	ntp \
	openssh \
	openssh-server \
	openssh-clients \
	httpd \
	php \
	php-cli \
	php-common \
	php-gd \
	php-mysql \
	php-pdo \
	php-pear \
	php-process \
	php-xml \
	php-mcrypt \
	php-snmp \
	lsof \
	iproute \
	cronie \
	&& rm -rf /var/cache/yum/* \
	&& yum clean all

# -----------------------------------------------------------------------------
# Copy files into place
# -----------------------------------------------------------------------------
ADD epel-release-latest-7.noarch.rpm /tmp/

# -----------------------------------------------------------------------------
# Import epel Repository
# -----------------------------------------------------------------------------
RUN rpm -ivh /tmp/epel-release-latest-7.noarch.rpm

# -----------------------------------------------------------------------------
# Set root password
# -----------------------------------------------------------------------------
RUN echo "root:P@ssw0rd" | chpasswd

# -----------------------------------------------------------------------------
# Install sshpass
# -----------------------------------------------------------------------------
RUN rpm --rebuilddb \
	&& yum -y install sshpass \
	&& yum -y erase epel-release-latest-7.noarch.rpm \
	&& rm -rf /var/cache/yum/* \
	&& rm -rf /tmp/epel-release-latest-7.noarch.rpm \
	&& yum clean all

# -----------------------------------------------------------------------------
# Set timezone to UTC
# -----------------------------------------------------------------------------
RUN ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# -----------------------------------------------------------------------------
# Configure SSH UseDNS
# -----------------------------------------------------------------------------
RUN sed -i \
	-e 's~^#UseDNS yes~UseDNS no~g' \
	/etc/ssh/sshd_config

# -----------------------------------------------------------------------------
# Enable services
# -----------------------------------------------------------------------------
RUN systemctl enable httpd.service && systemctl disable iptables && systemctl disable ip6tables && systemctl mask iptables && systemctl mask ip6tables

# -----------------------------------------------------------------------------
# Expose port 22
# -----------------------------------------------------------------------------
EXPOSE 22
EXPOSE 80

# -----------------------------------------------------------------------------
# Expose volumes
# -----------------------------------------------------------------------------
VOLUME [ "/sys/fs/cgroup" ]

# -----------------------------------------------------------------------------
# Command to init
# -----------------------------------------------------------------------------
CMD ["/usr/sbin/init"]
