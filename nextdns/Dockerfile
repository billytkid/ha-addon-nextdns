ARG BUILD_FROM
FROM $BUILD_FROM

ARG BUILD_ARCH
ARG NEXTDNS_VERSION

SHELL ["/bin/ash", "-o", "pipefail", "-c"]

RUN apk add --no-cache \
        ca-certificates \
        curl \
    && case "${BUILD_ARCH}" in \
        aarch64) NEXTDNS_ARCH="arm64" ;; \
        amd64)   NEXTDNS_ARCH="amd64" ;; \
        armhf)   NEXTDNS_ARCH="arm" ;; \
        armv7)   NEXTDNS_ARCH="arm" ;; \
        i386)    NEXTDNS_ARCH="386" ;; \
        *) echo "Unsupported architecture: ${BUILD_ARCH}" && exit 1 ;; \
    esac \
    && curl -fsSL \
        "https://github.com/nextdns/nextdns/releases/download/v${NEXTDNS_VERSION}/nextdns_${NEXTDNS_VERSION}_linux_${NEXTDNS_ARCH}.tar.gz" \
        | tar -xz -C /usr/local/bin nextdns \
    && chmod +x /usr/local/bin/nextdns \
    && nextdns version

COPY run.sh /run.sh
RUN chmod a+x /run.sh

CMD ["/run.sh"]
