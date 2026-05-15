#!/command/with-contenv bashio
# shellcheck shell=bash

NEXTDNS_BIN="/data/nextdns"
VERSION_FILE="/data/nextdns.version"

bashio::log.info "=== NextDNS Add-on starting ==="
bashio::log.info "Architecture: ${BUILD_ARCH}"

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
bashio::log.debug "NextDNS arch: ${NEXTDNS_ARCH}"

# ── Fetch latest version from GitHub ──────────────────────────────────────────
bashio::log.info "Checking GitHub for latest NextDNS release..."
LATEST=$(curl -fsSL --max-time 10 \
    "https://api.github.com/repos/nextdns/nextdns/releases/latest" \
    | jq -r '.tag_name' | tr -d 'v') || true

if bashio::var.is_empty "${LATEST}"; then
    bashio::log.warning "Could not reach GitHub API."
    LATEST=""
else
    bashio::log.info "Latest NextDNS version: v${LATEST}"
fi

CACHED=""
if [ -f "${VERSION_FILE}" ]; then
    CACHED=$(cat "${VERSION_FILE}")
    bashio::log.info "Cached NextDNS version: v${CACHED}"
fi

# ── Download if missing or outdated ───────────────────────────────────────────
if [ ! -x "${NEXTDNS_BIN}" ] || { [ -n "${LATEST}" ] && [ "${LATEST}" != "${CACHED}" ]; }; then
    if [ -n "${LATEST}" ]; then
        URL="https://github.com/nextdns/nextdns/releases/download/v${LATEST}/nextdns_${LATEST}_linux_${NEXTDNS_ARCH}.tar.gz"
        bashio::log.info "Downloading NextDNS v${LATEST} from: ${URL}"
        if curl -fsSL --max-time 60 "${URL}" | tar -xz -C /data nextdns; then
            chmod +x "${NEXTDNS_BIN}"
            echo "${LATEST}" > "${VERSION_FILE}"
            bashio::log.info "NextDNS v${LATEST} downloaded and ready."
        else
            bashio::log.fatal "Download failed! URL: ${URL}"
            exit 1
        fi
    else
        bashio::log.fatal "No cached binary and GitHub is unreachable. Cannot start."
        exit 1
    fi
else
    bashio::log.info "NextDNS v${CACHED} is current — skipping download."
fi

# ── Verify binary works ───────────────────────────────────────────────────────
NEXTDNS_VER=$("${NEXTDNS_BIN}" version 2>&1 || true)
bashio::log.info "Binary check: ${NEXTDNS_VER}"

# ── Read configuration ─────────────────────────────────────────────────────────
CONFIG_ID=$(bashio::config 'config_id')

if bashio::var.is_empty "${CONFIG_ID}"; then
    bashio::log.fatal "config_id is not set. Open the add-on Configuration tab and enter your NextDNS profile ID (e.g. 3ee52c) from my.nextdns.io → Setup tab."
    exit 1
fi
bashio::log.info "Using NextDNS profile: ${CONFIG_ID}"

# ── Discover host network interfaces ──────────────────────────────────────────
bashio::log.info "Discovering host network interfaces..."
LISTEN_HOSTS=()
for iface in $(bashio::network.interfaces); do
    for addr in $(bashio::network.ipv4_address "${iface}"); do
        ip="${addr%/*}"
        # Skip link-local (169.254.x.x)
        if [[ "${ip}" =~ ^169\.254\. ]]; then
            bashio::log.debug "Skipping link-local address: ${ip}"
            continue
        fi
        bashio::log.info "Will listen on interface ${iface}: ${ip}"
        LISTEN_HOSTS+=("${ip}")
    done
done
LISTEN_HOSTS+=("127.0.0.1")
bashio::log.info "Listen addresses: ${LISTEN_HOSTS[*]}"

# ── Build nextdns arguments ────────────────────────────────────────────────────
ARGS=(
    "--config" "${CONFIG_ID}"
    "--listen" "0.0.0.0:53"
)

bashio::config.true 'report_client_info' && ARGS+=("--report-client-info")
bashio::config.true 'log_queries'        && ARGS+=("--log-queries")
bashio::config.true 'bogus_priv'         && ARGS+=("--bogus-priv")
bashio::config.true 'use_hosts'          && ARGS+=("--use-hosts")

CACHE_SIZE=$(bashio::config 'cache_size')
[ "${CACHE_SIZE}" -gt 0 ] && ARGS+=("--cache-size" "${CACHE_SIZE}MB")

MAX_TTL=$(bashio::config 'max_ttl')
[ "${MAX_TTL}" -gt 0 ] && ARGS+=("--max-ttl" "${MAX_TTL}s")

FORWARDER=$(bashio::config 'forwarder')
bashio::var.is_empty "${FORWARDER}" || ARGS+=("--forwarder" "${FORWARDER}")

bashio::log.info "Running: ${NEXTDNS_BIN} run ${ARGS[*]}"
bashio::log.info "=== NextDNS starting — DNS is available on port 53 ==="

exec "${NEXTDNS_BIN}" run "${ARGS[@]}"
