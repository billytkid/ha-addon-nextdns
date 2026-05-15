#!/usr/bin/with-contenv bashio

bashio::log.info "Starting NextDNS add-on..."

# Required config
CONFIG_ID=$(bashio::config 'config_id')
LISTEN=$(bashio::config 'listen')

if bashio::var.is_empty "${CONFIG_ID}"; then
    bashio::log.fatal "config_id is required. Get your NextDNS configuration ID from https://my.nextdns.io"
    exit 1
fi

# Build argument list
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

bashio::log.info "Listening on ${LISTEN} with NextDNS config ${CONFIG_ID}"

exec /usr/local/bin/nextdns run "${ARGS[@]}"
