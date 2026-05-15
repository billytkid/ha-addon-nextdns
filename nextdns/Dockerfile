ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ENV BUILD_ARCH=${BUILD_ARCH}

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        ca-certificates \
        curl \
        jq

COPY run.sh /etc/services.d/nextdns/run
RUN chmod a+x /etc/services.d/nextdns/run
