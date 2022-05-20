FROM alpine:latest as build
LABEL maintainer "goonnowgit <goonnowgittt@gmail.com>"

ARG DNSCRYPT_PROXY_VERSION=2.1.1
ARG OS=linux
ARG ARCH=x86_64

ENV DEBIAN_FRONTEND=noninteractive
ENV MINISIG="RWTk1xXqcTODeYttYMCMLo0YJHaFEHn7a3akqHlb/7QvIQXHVPxKbjB5"

RUN apk update && apk add --no-cache curl minisign

ADD https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${OS}_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz .
ADD https://github.com/jedisct1/dnscrypt-proxy/releases/download/${DNSCRYPT_PROXY_VERSION}/dnscrypt-proxy-${OS}_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz.minisig .

RUN minisign -Vm dnscrypt-proxy-${OS}_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz -P ${MINISIG}
RUN tar xvf dnscrypt-proxy-${OS}_${ARCH}-${DNSCRYPT_PROXY_VERSION}.tar.gz
RUN mv /${OS}-${ARCH}/dnscrypt-proxy /
###
###
###
FROM alpine:latest as main

ENV RESOLVE_HOST=www.google.com

RUN apk update && apk add --no-cache ca-certificates

COPY --from=build dnscrypt-proxy .

USER nobody

HEALTHCHECK --interval=10s --timeout=10s --start-period=10s \
  CMD /dnscrypt-proxy --config /etc/dnscrypt-proxy/dnscrypt-proxy.toml -resolve "${RESOLVE_HOST}"

ENTRYPOINT ["/dnscrypt-proxy"]
CMD ["--help"]
