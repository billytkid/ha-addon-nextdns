# NextDNS Add-on Documentation

## Setup

1. Sign up at [my.nextdns.io](https://my.nextdns.io) and create a configuration.
2. Copy your **Configuration ID** from the Setup tab (e.g. `abc123`).
3. Install this add-on and enter your Configuration ID in the options.
4. Start the add-on.
5. Point your router's DNS to your Home Assistant IP address.

## Configuration Options

| Option | Default | Description |
|---|---|---|
| `config_id` | *(required)* | Your NextDNS configuration ID from my.nextdns.io |
| `listen` | `0.0.0.0:53` | Address and port to listen on for DNS queries |
| `report_client_info` | `true` | Send device name/model info to NextDNS dashboard |
| `log_queries` | `false` | Enable query logging in the add-on log |
| `cache_size` | `0` | DNS cache size in MB (0 = disabled) |
| `max_ttl` | `5` | Maximum TTL for cached responses in seconds |
| `bogus_priv` | `true` | Block reverse lookups for private IP ranges |
| `use_hosts` | `true` | Use the system `/etc/hosts` file |
| `forwarder` | *(empty)* | Custom forwarder rules, e.g. `mylocal.lan=192.168.1.1` |

## Router Configuration

To use NextDNS for your whole network, set your router's primary DNS server to your Home Assistant IP address. The add-on listens on port 53 by default.

For split DNS (e.g. resolve local `.lan` hostnames via your router while using NextDNS for everything else):

```
forwarder: "lan=192.168.1.1"
```

## Updating NextDNS Version

The NextDNS binary version is pinned in `build.yaml`. To update, change `NEXTDNS_VERSION` to the desired release tag from the [NextDNS releases page](https://github.com/nextdns/nextdns/releases) and rebuild.
