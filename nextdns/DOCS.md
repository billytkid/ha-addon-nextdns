# NextDNS Add-on Documentation

## Setup

1. Sign up at [my.nextdns.io](https://my.nextdns.io) and create a configuration.
2. Copy your **Profile ID** from the Setup tab (e.g. `3ee52c`).
3. In the add-on **Configuration** tab, enter your Profile ID and optionally a device name.
4. Start the add-on.
5. Point your router's DNS to your Home Assistant IP address.

## Configuration Options

| Option | Description |
|---|---|
| `profile_id` | Your NextDNS profile ID from my.nextdns.io (e.g. `3ee52c`) |
| `device_name` | Name shown in your NextDNS dashboard (default: `home-assistant`) |
| `log_queries` | Log every DNS query in the add-on log. Off by default — useful for troubleshooting blocked sites |
| `cache` | Cache DNS responses locally (10 MB). Speeds up repeated lookups, reduces round-trips to NextDNS |

## Router Configuration

Set your router's primary DNS server to your Home Assistant IP address. The add-on listens on port 53.

## NextDNS Updates

The NextDNS client is downloaded automatically on startup and updated whenever a new version is released — no add-on update required.
