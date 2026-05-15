# NextDNS Home Assistant Add-on Repository

Run the [NextDNS](https://nextdns.io) DNS client as a Home Assistant add-on. This gives you network-wide DNS filtering, security, and privacy without needing a separate device.

## Installation

1. In Home Assistant, go to **Settings → Add-ons → Add-on Store**.
2. Click the **⋮ (three-dot menu)** in the top-right and select **Repositories**.
3. Add this URL:
   ```
   https://github.com/billytkid/ha-addon-nextdns
   ```
4. Close the dialog and search for **NextDNS** in the add-on store.
5. Click **Install**.

## Configuration

You need a free NextDNS account and a configuration ID:

1. Sign up at [my.nextdns.io](https://my.nextdns.io).
2. Create a new configuration and copy the **Configuration ID** (e.g. `abc123`).
3. In the add-on configuration tab, set `config_id` to your ID.
4. Start the add-on.

## Using as Network-Wide DNS

Point your router's primary DNS server to your Home Assistant IP address. The add-on listens on port 53 by default.

See [DOCS.md](nextdns/DOCS.md) for all configuration options.

## Supported Architectures

- `aarch64` (Raspberry Pi 4, most modern HA hardware)
- `amd64` (x86 64-bit)
- `armhf` (Raspberry Pi 2/3, 32-bit)
- `armv7`
- `i386`
