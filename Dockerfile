FROM ubuntu:18.04 as builder
MAINTAINER Nikos Mavrogiannopoulos <nmav@redhat.com>
RUN apt-get update -qq -y && \
    git DEBIAN_FRONTEND=noninteractive apt-get install -y \
	build-essential gettext autoconf automake libproxy-dev \
	libxml2-dev libtool vpnc-scripts pkg-config zlib1g-dev \
	libgnutls28-dev ocserv iproute2 openjdk-8-jdk python3 \
	libsofthsm2-dev libsocket-wrapper libuid-wrapper libssl-dev \
	socat ppp python3-flask libtss-dev \
	python3-openssl python3-xmltodict && \
    apt-get clean
Run git clone https://gitlab.com/openconnect/openconnect.git
RUN cd openconnect && ./autogen.sh && ./configure && make
FROM ubuntu:18.04 
RUN apt-get update && \
    apt-get install -y make netcat-traditional ocproxy dnsutils telnet unbound gettext polipo && \
    apt-get clean && \
    rm -rf /var/cache/apt/* && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder '/root/openconnect' 'openconnect'
RUN cd openconnect && make install && rm -rf openconnect
COPY run.sh /run.sh
RUN chmod 0755 /run.sh

CMD ["/run.sh"]