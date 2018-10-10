FROM alpine:3.8

LABEL maintainer="mkosmo@gmail.com"

ENV TS_VERSION 3.4.0
ENV TS3SERVER_LICENSE accept
ENV LANG C.UTF-8
ENV GLIBC_VERSION 2.28-r0

RUN apk update
RUN apk upgrade

# Download and install glibc
RUN apk add --update curl && \
  curl -Lo /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
  curl -Lo glibc.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk" && \
  curl -Lo glibc-bin.apk "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk" && \
  apk add glibc-bin.apk glibc.apk && \
  /usr/glibc-compat/sbin/ldconfig /lib /usr/glibc-compat/lib && \
  echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf && \
  apk del curl && \
  rm -rf glibc.apk glibc-bin.apk /var/cache/apk/*

RUN apk add bash 
RUN apk add bzip2 \
            ca-certificates \
            wget
RUN apk add binutils
RUN adduser -H -D -s /bin/false --uid 1000 teamspeak3
RUN mkdir /data
RUN chown teamspeak3:teamspeak3 /data

COPY get-version.sh /get-version.sh
COPY start-teamspeak3.sh /start-teamspeak3.sh

EXPOSE 9987/udp
EXPOSE 10011/tcp
EXPOSE 30033/tcp

USER teamspeak3
VOLUME /data
WORKDIR /data
#RUN ["/bin/bash"]
ENTRYPOINT ["/start-teamspeak3.sh"]

