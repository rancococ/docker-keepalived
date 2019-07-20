# from frolvlad/alpine-glibc:alpine-3.9
FROM frolvlad/alpine-glibc:alpine-3.9

# maintainer
MAINTAINER "rancococ" <rancococ@qq.com>

# set arg info
ARG ALPINE_VERSION=v3.9
ARG KEEPALIVED_VERSION=2.0.17
ARG GOTMPL_VERSION=v1.0.1
ARG KEEPALIVED_URL=http://keepalived.org/software/keepalived-${KEEPALIVED_VERSION}.tar.gz
ARG GOTMPL_URL=https://github.com/rancococ/gotmpl/releases/download/${GOTMPL_VERSION}/gotmpl-Linux-x86_64

# copy script
COPY docker-entrypoint.sh /
COPY docker-startup.sh /
COPY docker-process.sh /
COPY keepalived.tmpl /etc/keepalived/

# install repositories and packages : curl bash openssh wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu
RUN echo -e "https://mirrors.huaweicloud.com/alpine/${ALPINE_VERSION}/main\nhttps://mirrors.huaweicloud.com/alpine/${ALPINE_VERSION}/community" > /etc/apk/repositories && \
    apk update && \
    apk --no-cache add curl bash wget net-tools gettext zip unzip tar tzdata ncurses procps ttf-dejavu && \
    apk --no-cache add ipset iptables libnfnetlink libnl3 openssl && \
    apk --no-cache add autoconf gcc ipset-dev iptables-dev libnfnetlink-dev libnl3-dev make musl-dev openssl-dev && \
    curl -o /tmp/keepalived.tar.gz -SL ${KEEPALIVED_URL} && \
    mkdir -p /tmp/keepalived-sources && \
    tar -xzf /tmp/keepalived.tar.gz --strip 1 -C /tmp/keepalived-sources && \
    cd /tmp/keepalived-sources && \
    ./configure --disable-dynamic-linking && \
    make && make install && \
    cd - && mkdir -p /etc/keepalived && \
    \rm -f /tmp/keepalived.tar.gz && \
    \rm -rf /tmp/keepalived-sources && \
    apk --no-cache del autoconf gcc ipset-dev iptables-dev libnfnetlink-dev libnl3-dev make musl-dev openssl-dev
    \rm -rf /var/cache/apk/* && \
    echo "Asia/Shanghai" > /etc/timezone && \
    \ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    wget -c -O /usr/local/bin/gotmpl --no-cookies --no-check-certificate "${GOTMPL_URL}" && \
    chmod +x /usr/local/bin/gotmpl && \
    chmod +x /docker-entrypoint.sh

# set environment
ENV LANG C.UTF-8
ENV TZ "Asia/Shanghai"
ENV TERM xterm

# stop signal
STOPSIGNAL SIGTERM

# entry point
ENTRYPOINT ["/docker-entrypoint.sh"]
