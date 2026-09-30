#!/usr/bin/env zsh

# Simple ADB helpers for fast physical-device testing.
# Focus: USB -> Wi-Fi connect, quick reconnect, readable commands.

ADB_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/adb-device"
ADB_LAST_ENDPOINT_FILE="$ADB_CACHE_DIR/last-endpoint"
ADB_DEFAULT_PORT="5555"
ADB_TIMEOUT_SECS="8"

_adb_ok() {
  if ! command -v adb >/dev/null 2>&1; then
    echo "adb not found. Install Android platform-tools."
    return 1
  fi
  return 0
}

_adb_init() {
  mkdir -p "$ADB_CACHE_DIR"
}

_adb_pick_usb_device() {
  adb devices | awk 'NR>1 && $2=="device" && $1 !~ /:/{print $1; exit}'
}

_adb_device_ip() {
  local dev="$1"
  adb -s "$dev" shell ip route 2>/dev/null | awk '/src / {for (i=1;i<=NF;i++) if ($i=="src") {print $(i+1); exit}}'
}

_adb_save_endpoint() {
  local endpoint="$1"
  print -r -- "$endpoint" > "$ADB_LAST_ENDPOINT_FILE"
}

_adb_load_endpoint() {
  [[ -f "$ADB_LAST_ENDPOINT_FILE" ]] && cat "$ADB_LAST_ENDPOINT_FILE"
}

_adb_connect_endpoint() {
  local endpoint="$1"
  local out
  if command -v timeout >/dev/null 2>&1; then
    out="$(timeout "$ADB_TIMEOUT_SECS" adb connect "$endpoint" 2>&1)" || return 1
  elif command -v gtimeout >/dev/null 2>&1; then
    out="$(gtimeout "$ADB_TIMEOUT_SECS" adb connect "$endpoint" 2>&1)" || return 1
  else
    out="$(adb connect "$endpoint" 2>&1)" || return 1
  fi

  print -r -- "$out" | grep -Eq "connected to|already connected to"
}

_adb_tls_serial() {
  adb devices | awk 'NR>1 && $1 ~ /^adb-.*_adb-tls-connect\._tcp$/ && $2=="device" {print $1; exit}'
}

_adb_wait_for_tls() {
  local i tls
  for i in {1..6}; do
    tls="$(_adb_tls_serial)"
    if [[ -n "$tls" ]]; then
      print -r -- "$tls"
      return 0
    fi
    sleep 1
  done
  return 1
}

adb-fix() {
  _adb_ok || return 1
  adb kill-server >/dev/null 2>&1
  adb start-server >/dev/null 2>&1
  echo "adb server restarted"
}

adb-status() {
  _adb_ok || return 1
  echo "== adb devices =="
  adb devices
  local last="$(_adb_load_endpoint)"
  [[ -n "$last" ]] && echo "last wireless endpoint: $last"
  local tls="$(_adb_tls_serial)"
  [[ -n "$tls" ]] && echo "wireless tls device: $tls"
}

# Use with USB connected at least once.
# Enables TCP/IP mode, detects phone IP, connects, and stores endpoint.
adb-wifi() {
  _adb_ok || return 1
  _adb_init

  local port="${1:-$ADB_DEFAULT_PORT}"
  local dev ip endpoint

  dev="$(_adb_pick_usb_device)"
  if [[ -z "$dev" ]]; then
    echo "No USB device detected. Connect cable + enable USB debugging first."
    return 1
  fi

  echo "USB device: $dev"
  echo "Enabling TCP/IP on port $port..."

  if command -v timeout >/dev/null 2>&1; then
    timeout "$ADB_TIMEOUT_SECS" adb -s "$dev" tcpip "$port" >/dev/null
  elif command -v gtimeout >/dev/null 2>&1; then
    gtimeout "$ADB_TIMEOUT_SECS" adb -s "$dev" tcpip "$port" >/dev/null
  else
    adb -s "$dev" tcpip "$port" >/dev/null
  fi
  if [[ $? -ne 0 ]]; then
    echo "Failed to enable tcpip mode on device $dev"
    return 1
  fi

  sleep 1

  ip="$(_adb_device_ip "$dev")"
  if [[ -z "$ip" ]]; then
    echo "Could not detect phone IP. Ensure phone is on Wi-Fi."
    return 1
  fi

  endpoint="$ip:$port"
  echo "Connecting to $endpoint..."
  if _adb_connect_endpoint "$endpoint"; then
    _adb_save_endpoint "$endpoint"
    echo "Connected: $endpoint"
    echo "Tip: next time run: adb-reconnect"
    return 0
  fi

  # Newer Android wireless debugging may connect via TLS/mDNS serial instead of ip:port.
  local tls
  tls="$(_adb_wait_for_tls)"
  if [[ -n "$tls" ]]; then
    _adb_save_endpoint "tls:$tls"
    echo "Connected via wireless TLS/mDNS: $tls"
    echo "Tip: next time run: adb-reconnect"
    return 0
  fi

  echo "Failed to connect to $endpoint"
  return 1
}

# Reconnect quickly using the last successful wireless endpoint.
adb-reconnect() {
  _adb_ok || return 1
  _adb_init

  local endpoint
  endpoint="$(_adb_load_endpoint)"

  if [[ -z "$endpoint" ]]; then
    echo "No saved endpoint. First run: adb-wifi (with USB connected)."
    return 1
  fi

  # If wireless TLS is already connected, we're done.
  local tls
  tls="$(_adb_tls_serial)"
  if [[ -n "$tls" ]]; then
    echo "Connected via wireless TLS/mDNS: $tls"
    return 0
  fi

  # Saved TLS marker from previous successful adb-wifi run.
  if [[ "$endpoint" == tls:* ]]; then
    echo "Saved endpoint is TLS/mDNS mode."
    echo "Open phone Wireless debugging and keep same network, then retry adb-reconnect."
    return 1
  fi

  if _adb_connect_endpoint "$endpoint"; then
    echo "Connected: $endpoint"
    return 0
  fi

  echo "Reconnect failed for $endpoint"
  echo "If phone IP changed, connect USB once and run: adb-wifi"
  return 1
}

# Manually connect to a specific endpoint (example: adb-connect 192.168.1.45:5555)
adb-connect() {
  _adb_ok || return 1
  _adb_init

  local endpoint="$1"
  if [[ -z "$endpoint" ]]; then
    echo "Usage: adb-connect <ip:port>"
    return 1
  fi

  if _adb_connect_endpoint "$endpoint"; then
    _adb_save_endpoint "$endpoint"
    echo "Connected: $endpoint"
    return 0
  fi

  echo "Failed to connect: $endpoint"
  return 1
}

adb-disconnect-all() {
  _adb_ok || return 1
  adb disconnect >/dev/null
  echo "Disconnected all wireless adb devices"
}

adb-help() {
  cat <<'HELP'
ADB quick commands:
  adb-status          Show devices + last saved wireless endpoint
  adb-fix             Restart adb server
  adb-wifi [port]     USB -> enable wireless -> auto connect and save endpoint
  adb-reconnect       Reconnect using last saved endpoint
  adb-connect ip:port Connect manually and save endpoint
  adb-disconnect-all  Disconnect all wireless devices

Typical workflow:
  1) Plug USB once and enable USB debugging
  2) Run: adb-wifi
  3) Next sessions: adb-reconnect
HELP
}
