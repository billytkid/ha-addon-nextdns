# Changelog

## [1.2.0] - 2026-05-15

### Fixed
- DNS queries from other devices on the network were not reaching the add-on. Root causes:
  - Missing `ports: 53/tcp+udp` declaration in add-on config (required by HA Supervisor even when `host_network: true` is set)
  - Wrong s6-overlay shebang (`/usr/bin/with-contenv` → `/command/with-contenv` for s6-overlay v3)
  - `init: false` added to prevent s6 running a redundant default init wrapper

### Added
- Verbose startup logging — the Log tab now shows architecture detection, GitHub version check, download progress, discovered network interfaces, and the exact command being run
- Auto-discovery of host network interfaces at startup (same approach used by the AdGuard Home add-on)

### Changed
- Removed the `listen` configuration option — the add-on always binds to `0.0.0.0:53` to ensure it is reachable on all network interfaces

---

## [1.1.1] - 2026-05-15

### Added
- Descriptions for every configuration option shown directly in the HA add-on Configuration tab, including what the Configuration ID is and where to find it, and how to format the Forwarder field

---

## [1.1.0] - 2026-05-15

### Fixed
- Add-on failed to start with `s6-overlay-suexec: fatal: can only run as pid 1`. The run script is now placed in `/etc/services.d/` so s6-overlay manages it correctly as PID 1

### Changed
- NextDNS binary is no longer baked into the Docker image at build time. Instead, the add-on downloads the latest NextDNS release from GitHub on first start and caches it in `/data/`. On subsequent starts it checks for updates and only re-downloads if a newer version is available — so the NextDNS client always stays up to date without needing an add-on update

---

## [1.0.1] - 2026-05-15

### Fixed
- Corrected architecture names for the NextDNS binary download (`armhf` → `armv6`, `armv7` → `armv7`)
- Updated NextDNS version from non-existent `1.45.0` to `1.47.2`
- Fixed GitHub Actions platform matrix (replaced broken nested ternary expressions with explicit `include` entries)

---

## [1.0.0] - 2026-05-15

### Added
- Initial release
- Runs the NextDNS CLI client as a Home Assistant add-on
- Supports all HA architectures: `aarch64`, `amd64`, `armhf`, `armv7`, `i386`
- Configurable via the HA add-on UI: profile ID, client reporting, query logging, DNS cache, TTL, bogus-priv, hosts file, and forwarder rules
- Binds to port 53 on the host network so any device can use it as a DNS server
- Docker images published automatically to GHCR via GitHub Actions on every release
