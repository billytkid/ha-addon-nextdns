#!/command/with-contenv bashio
# shellcheck shell=bash

NEXTDNS_BIN="/data/nextdns"
VERSION_FILE="/data/nextdns.version"

printf '\033c'
bashio::log.info "Starting NextDNS add-on..."

# ── Map HA arch to NextDNS release arch ───────────────────────────────────────
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

# ── Download latest NextDNS if needed ─────────────────────────────────────────
LATEST=$(curl -fsSL --max-time 10 \
    "https://api.github.com/repos/nextdns/nextdns/releases/latest" \
    | jq -r '.tag_name' | tr -d 'v') || true

CACHED=""
[ -f "${VERSION_FILE}" ] && CACHED=$(cat "${VERSION_FILE}")

if [ ! -x "${NEXTDNS_BIN}" ] || { [ -n "${LATEST}" ] && [ "${LATEST}" != "${CACHED}" ]; }; then
    if [ -n "${LATEST}" ]; then
        bashio::log.info "Downloading NextDNS v${LATEST}..."
        curl -fsSL --max-time 60 \
            "https://github.com/nextdns/nextdns/releases/download/v${LATEST}/nextdns_${LATEST}_linux_${NEXTDNS_ARCH}.tar.gz" \
            | tar -xz -C /data nextdns \
            && chmod +x "${NEXTDNS_BIN}" \
            && echo "${LATEST}" > "${VERSION_FILE}"
        bashio::log.info "NextDNS v${LATEST} ready."
    else
        bashio::log.fatal "No cached binary and cannot reach GitHub. Cannot start."
        exit 1
    fi
else
    bashio::log.info "NextDNS v${CACHED} is up to date."
fi

# ── Validate config ────────────────────────────────────────────────────────────
PROFILE_ID=$(bashio::config 'profile_id')
DEVICE_NAME=$(bashio::config 'device_name')

if bashio::var.is_empty "${PROFILE_ID}"; then
    bashio::log.fatal "profile_id is not set. Go to the Configuration tab and enter your NextDNS Profile ID from my.nextdns.io."
    exit 1
fi

bashio::log.info "Profile: ${PROFILE_ID} | Device: ${DEVICE_NAME}"

ARGS=(
    "--profile" "${PROFILE_ID}/${DEVICE_NAME}"
    "--listen" "0.0.0.0:53"
    "--report-client-info"
    "--bogus-priv"
    "--use-hosts"
)

bashio::config.true 'log_queries' && ARGS+=("--log-queries")
bashio::config.true 'cache'       && ARGS+=("--cache-size" "10MB")

exec "${NEXTDNS_BIN}" run "${ARGS[@]}"
