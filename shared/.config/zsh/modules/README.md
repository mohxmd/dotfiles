# zsh modules

## adb-device.zsh

Commands:
- `adb-wifi [port]`: USB once -> enable wireless ADB -> connect and save endpoint
- `adb-reconnect`: reconnect to last saved endpoint quickly
- `adb-connect <ip:port>`: manual connect + save endpoint
- `adb-status`: show adb devices and saved endpoint
- `adb-fix`: restart adb server
- `adb-disconnect-all`: disconnect wireless devices

Quick flow:
1. Connect USB once, run `adb-wifi`
2. Later on same network, run `adb-reconnect`

Note: wireless ADB always connects to an endpoint (`ip:port`).

Port/IP behavior:
- Same Wi-Fi helps, but ADB still needs `ip:port`.
- Usually port is `5555` with this script, but IP can change by router/DHCP.
- If reconnect fails, run `adb-wifi` again with USB to refresh endpoint.
