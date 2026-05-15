#!/usr/bin/with-contenv bashio

NEXTDNS_BIN="/data/nextdns"
VERSION_FILE="/data/nextdns.version"

# Map HA arch to NextDNS release arch
case "${BUILD_ARCH}" in
    aarch64) NEXTDNS_ARCH="arm64" ;;
    amd64)   NEXTDNS_ARCH="amd64" ;;
    armhf)   NEXTDNS_ARCH="armv6" ;;
    armv7)   NEXTDNS_ARCH="armv7" ;;
    i386)    NEXTDNS_ARCH="386" ;;
    *)
        bashio::log.fatal "Unsupported architecture: ${BUILD_ARCH}"
        exit 1
        ;;
esac

# Check for the latest NextDNS release
bashio::log.info "Checking for latest NextDNS release..."
LATEST=$(curl -fsSL "https://api.github.com/repos/nextdns/nextdns/releases/latest" \
    | jq -r '.tag_name' | tr -d 'v') || true

if bashio::var.is_empty "${LATEST}"; then
    bashio::log.warning "Could not reach GitHub API — using cached binary if available."
    LATEST=""
fi

CACHED=""
if [ -f "${VERSION_FILE}" ]; then
    CACHED=$(cat "${VERSION_FILE}")
fi

# Download if no cached binary, or a newer version is available
if [ ! -x "${NEXTDNS_BIN}" ] || { [ -n "${LATEST}" ] && [ "${LATEST}" != "${CACHED}" ]; }; then
    if [ -n "${LATEST}" ]; then
        bashio::log.info "Downloading NextDNS v${LATEST} (${NEXTDNS_ARCH})..."
        curl -fsSL \
            "https://github.com/nextdns/nextdns/releases/download/v${LATEST}/nextdns_${LATEST}_linux_${NEXTDNS_ARCH}.tar.gz" \
            | tar -xz -C /data nextdns \
            && chmod +x "${NEXTDNS_BIN}" \
            && echo "${LATEST}" > "${VERSION_FILE}" \
            && bashio::log.info "NextDNS v${LATEST} ready."
    else
        bashio::log.fatal "No cached binary and GitHub is unreachable. Cannot start."
        exit 1
    fi
else
    bashio::log.info "NextDNS v${CACHED} is up to date."
fi

# Read configuration
CONFIG_ID=$(bashio::config 'config_id')
LISTEN=$(bashio::config 'listen')

if bashio::var.is_empty "${CONFIG_ID}"; then
    bashio::log.fatal "config_id is required. Get your NextDNS configuration ID from https://my.nextdns.io"
    exit 1
fi

ARGS=(
    "--config" "${CONFIG_ID}"
    "--listen" "${LISTEN}"
)

if bashio::config.true 'report_client_info'; then
    ARGS+=("--report-client-info")
fi

if bashio::config.true 'log_queries'; then
    ARGS+=("--log-queries")
fi

CACHE_SIZE=$(bashio::config 'cache_size')
if [ "${CACHE_SIZE}" -gt 0 ]; then
    ARGS+=("--cache-size" "${CACHE_SIZE}MB")
fi

MAX_TTL=$(bashio::config 'max_ttl')
if [ "${MAX_TTL}" -gt 0 ]; then
    ARGS+=("--max-ttl" "${MAX_TTL}s")
fi

if bashio::config.true 'bogus_priv'; then
    ARGS+=("--bogus-priv")
fi

if bashio::config.true 'use_hosts'; then
    ARGS+=("--use-hosts")
fi

FORWARDER=$(bashio::config 'forwarder')
if ! bashio::var.is_empty "${FORWARDER}"; then
    ARGS+=("--forwarder" "${FORWARDER}")
fi

bashio::log.info "Starting NextDNS — listening on ${LISTEN} with profile ${CONFIG_ID}"
exec "${NEXTDNS_BIN}" run "${ARGS[@]}"
