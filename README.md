# NextDNS Home Assistant Add-on

Run the [NextDNS](https://nextdns.io) DNS client as a Home Assistant add-on for network-wide DNS filtering, security, and privacy.

[![Add to Home Assistant](https://my.home-assistant.io/badges/supervisor_add_addon_repository.svg)](https://my.home-assistant.io/redirect/supervisor_add_addon_repository/?repository_url=https%3A%2F%2Fgithub.com%2Fbillytkid%2Fha-addon-nextdns)

## Installation

1. Click the button above, or manually add this repository in Home Assistant:
   **Settings → Add-ons → Add-on Store → ⋮ → Repositories**
   ```
   https://github.com/billytkid/ha-addon-nextdns
   ```
2. Find **NextDNS** in the add-on store and click **Install**.
3. Go to the **Configuration** tab and enter your **NextDNS Profile ID** from [my.nextdns.io](https://my.nextdns.io) → Setup tab.
4. Click **Start**.

## Configuration

| Option | Description |
|---|---|
| `profile_id` | Your NextDNS profile ID (e.g. `3ee52c`) — found on the Setup tab at my.nextdns.io |
| `device_name` | Name for this device as it appears in your NextDNS dashboard (default: `home-assistant`) |

## Network-wide DNS

Point your router's primary DNS server to your Home Assistant IP address. The add-on listens on port 53.

## Supported Architectures

`aarch64` · `amd64` · `armhf` · `armv7` · `i386`
