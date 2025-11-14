#!/usr/bin/env zsh

# ============================================================================
# Simple Android Device Manager
# ============================================================================

# Config
readonly CONFIG_DIR="$HOME/.config/adb-connect"
readonly CONFIG_FILE="$CONFIG_DIR/devices.conf"
readonly LAST_DEVICE="$CONFIG_DIR/last_device"

# Ports
readonly DEFAULT_PORTS=(5555 37000 40000)
readonly FORWARD_PORTS=(8081 3000 8000)

# Colors (use echo -e)
readonly G='\033[0;32m'
readonly Y='\033[1;33m'
readonly R='\033[0;31m'
readonly N='\033[0m'

# ============================================================================
# Initialize
# ============================================================================
_init() {
  [[ -d "$CONFIG_DIR" ]] || mkdir -p "$CONFIG_DIR"
  [[ -f "$CONFIG_FILE" ]] || touch "$CONFIG_FILE"
}

# ============================================================================
# Find working port
# ============================================================================
_find_port() {
  local ip="$1"
  for port in "${DEFAULT_PORTS[@]}"; do
    if timeout 1 adb connect "$ip:$port" 2>&1 | grep -q "connected\|already"; then
      adb disconnect "$ip:$port" &>/dev/null
      echo "$port"
      return 0
    fi
    adb disconnect "$ip:$port" &>/dev/null
  done
  return 1
}

# ============================================================================
# Save device
# ============================================================================
_save() {
  local name="$1" ip="$2" port="$3"
  grep -v "^$name|" "$CONFIG_FILE" > "$CONFIG_FILE.tmp" 2>/dev/null
  mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
  echo "$name|$ip|$port" >> "$CONFIG_FILE"
  echo "$name" > "$LAST_DEVICE"
}

# ============================================================================
# Setup ports
# ============================================================================
_setup_ports() {
  adb reverse --remove-all &>/dev/null
  local count=0
  for port in "${FORWARD_PORTS[@]}"; do
    adb reverse tcp:$port tcp:$port &>/dev/null && ((count++))
  done
  echo -e "${G}✓${N} Forwarded $count ports"
}

# ============================================================================
# Connect
# ============================================================================
mohx-phone() {
  _init

  if [[ ! -f "$LAST_DEVICE" ]]; then
    echo -e "${Y}No device saved.${N} Run: mohx-phone-pair"
    return 1
  fi

  local name=$(cat "$LAST_DEVICE")
  local info=$(grep "^$name|" "$CONFIG_FILE")
  local ip=$(echo "$info" | cut -d'|' -f2)
  local port=$(echo "$info" | cut -d'|' -f3)

  echo "Connecting to $name ($ip)..."

  local new_port=$(_find_port "$ip")
  if [[ -z "$new_port" ]]; then
    echo -e "${R}✗${N} Connection failed"
    return 1
  fi

  adb connect "$ip:$new_port" &>/dev/null
  _setup_ports

  [[ "$new_port" != "$port" ]] && _save "$name" "$ip" "$new_port"
  echo -e "${G}✅ Connected!${N}"
}

# ============================================================================
# Pair device
# ============================================================================
mohx-phone-pair() {
  _init

  echo -e "\n${G}Device Pairing${N}"
  echo "Name (e.g., phone):"
  read name
  [[ -z "$name" ]] && echo -e "${R}✗${N} Name required" && return 1

  echo "IP address:"
  read ip
  [[ ! "$ip" =~ ^[0-9.]+$ ]] && echo -e "${R}✗${N} Invalid IP" && return 1

  echo "Scanning..."
  local port=$(_find_port "$ip")

  if [[ -z "$port" ]]; then
    echo -e "${R}✗${N} Failed. Check:"
    echo "  • Wireless Debugging enabled"
    echo "  • Same WiFi network"
    return 1
  fi

  adb connect "$ip:$port" &>/dev/null
  _save "$name" "$ip" "$port"
  _setup_ports
  echo -e "${G}✅ Paired & connected!${N}"
}

# ============================================================================
# List devices
# ============================================================================
mohx-phone-list() {
  _init

  if [[ ! -s "$CONFIG_FILE" ]]; then
    echo -e "${Y}No devices saved${N}"
    return
  fi

  echo -e "\n${G}Saved Devices:${N}"
  local current=$(cat "$LAST_DEVICE" 2>/dev/null)

  while IFS='|' read -r name ip port; do
    local marker="  "
    [[ "$name" == "$current" ]] && marker="▸ "
    echo "$marker$name → $ip:$port"
  done < "$CONFIG_FILE"
  echo ""
}

# ============================================================================
# Switch device
# ============================================================================
mohx-phone-switch() {
  _init

  if [[ -z "$1" ]]; then
    echo "Usage: mohx-phone-switch <name>"
    mohx-phone-list
    return 1
  fi

  if grep -q "^$1|" "$CONFIG_FILE"; then
    echo "$1" > "$LAST_DEVICE"
    echo -e "${G}✓${N} Switched to: $1"
    mohx-phone
  else
    echo -e "${R}✗${N} Device not found"
    mohx-phone-list
    return 1
  fi
}

# ============================================================================
# Disconnect
# ============================================================================
mohx-phone-disconnect() {
  adb reverse --remove-all &>/dev/null
  adb disconnect &>/dev/null
  echo -e "${G}✓${N} Disconnected"
}

# ============================================================================
# Help
# ============================================================================
mohx-phone-help() {
  cat << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱 Android Device Manager - Quick Guide
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMANDS:
  mohx-phone              → Connect to your saved device
  mohx-phone-pair         → Add a new device
  mohx-phone-list         → Show all saved devices
  mohx-phone-switch <n>   → Change default device
  mohx-phone-disconnect   → Disconnect current device

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 FIRST TIME SETUP:

  1. Enable on your phone:
     Settings → Developer Options → Wireless Debugging (ON)

  2. Get your phone's IP:
     Settings → About → Status → IP address
     (e.g., 192.168.1.100)

  3. Run pairing:
     $ mohx-phone-pair

     Enter name: phone
     Enter IP: 192.168.1.100

     ✅ Done! Script auto-detects port and connects

  4. Daily use:
     $ mohx-phone

     That's it! Connects instantly.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 COMMON SCENARIOS:

  • Phone restarted? Port changed?
    → Just run: mohx-phone
    → Auto-finds new port

  • Multiple devices (phone + tablet)?
    → mohx-phone-pair (add each device)
    → mohx-phone-switch phone
    → mohx-phone-switch tablet

  • Check what's saved?
    → mohx-phone-list

  • React Native dev server not working?
    → Ports auto-forward: 8081, 3000, 8000
    → No manual setup needed!

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  TROUBLESHOOTING:

  Connection fails?
  ✓ Phone & computer on same WiFi
  ✓ Wireless Debugging is ON
  ✓ No VPN on phone
  ✓ Try: adb kill-server && mohx-phone

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

_init &>/dev/null
