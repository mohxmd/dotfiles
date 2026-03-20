#!/usr/bin/env zsh

# ============================================================================
# Robust Android Device Manager
# ============================================================================

# Config
readonly CONFIG_DIR="$HOME/.config/adb-connect"
readonly CONFIG_FILE="$CONFIG_DIR/devices.conf"
readonly LAST_DEVICE="$CONFIG_DIR/last_device"

# Ports to try
readonly DEFAULT_PORTS=(5555 5556 5557 37000 38000 39000 36233 40000 41000)
readonly FORWARD_PORTS=(8081 3000 8000 8888 5000)

# Colors
readonly G='\033[0;32m'
readonly Y='\033[1;33m'
readonly R='\033[0;31m'
readonly B='\033[1;34m'
readonly N='\033[0m'

# ============================================================================
# Initialize
# ============================================================================
_init() {
  [[ -d "$CONFIG_DIR" ]] || mkdir -p "$CONFIG_DIR"
  [[ -f "$CONFIG_FILE" ]] || touch "$CONFIG_FILE"
}

# ============================================================================
# Check if ADB is installed
# ============================================================================
_check_adb() {
  if ! command -v adb &>/dev/null; then
    echo -e "${R}✗${N} ADB not found. Install Android SDK Platform Tools"
    return 1
  fi
  return 0
}

# ============================================================================
# Kill and restart ADB server
# ============================================================================
_restart_adb() {
  echo -e "${Y}↻${N} Restarting ADB server..."
  adb kill-server &>/dev/null
  sleep 1
  adb start-server &>/dev/null 2>&1
  sleep 1
}

# ============================================================================
# Scan network for Android devices
# ============================================================================
_scan_network() {
  local base_ip="$1"
  echo -e "${B}🔍 Scanning network...${N}"

  # Get network prefix (e.g., 192.168.1)
  local prefix=$(echo "$base_ip" | cut -d'.' -f1-3)

  # Try common device IPs first
  local common_ips=("$base_ip")
  for i in {2..20} {50..70} {100..120}; do
    common_ips+=("$prefix.$i")
  done

  local found=0
  for ip in "${common_ips[@]}"; do
    for port in "${DEFAULT_PORTS[@]}"; do
      if timeout 2 adb connect "$ip:$port" 2>&1 | grep -q "connected"; then
        echo -e "${G}✓${N} Found device at $ip:$port"
        adb disconnect "$ip:$port" &>/dev/null
        echo "$ip|$port"
        return 0
      fi
      adb disconnect "$ip:$port" &>/dev/null 2>&1
    done

    # Show progress
    ((found++))
    if [[ $((found % 5)) -eq 0 ]]; then
      echo -e "${Y}...${N} Checked $found IPs"
    fi
  done

  return 1
}

# ============================================================================
# Find working port for specific IP
# ============================================================================
_find_port() {
  local ip="$1"
  local silent="$2"

  [[ "$silent" != "silent" ]] && echo -e "${B}🔍 Testing ports on $ip...${N}"

  for port in "${DEFAULT_PORTS[@]}"; do
    [[ "$silent" != "silent" ]] && echo -n "  Port $port... "

    if timeout 3 adb connect "$ip:$port" 2>&1 | grep -q "connected\|already"; then
      [[ "$silent" != "silent" ]] && echo -e "${G}✓${N}"
      adb disconnect "$ip:$port" &>/dev/null
      echo "$port"
      return 0
    fi

    [[ "$silent" != "silent" ]] && echo -e "${R}✗${N}"
    adb disconnect "$ip:$port" &>/dev/null 2>&1
  done

  return 1
}

# ============================================================================
# Try pairing mode connection
# ============================================================================
_try_pairing_mode() {
  local ip="$1"
  echo -e "\n${Y}📱 Trying pairing mode...${N}"
  echo "If your phone shows a pairing dialog:"
  echo "  1. Note the pairing code"
  echo "  2. Note the port number (e.g., 37xxx)"
  echo ""
  read "pairing_port?Enter pairing port (or press Enter to skip): "

  if [[ -n "$pairing_port" ]]; then
    read "pairing_code?Enter pairing code: "
    if [[ -n "$pairing_code" ]]; then
      echo "Attempting to pair..."
      if adb pair "$ip:$pairing_port" "$pairing_code" 2>&1 | grep -q "Success"; then
        echo -e "${G}✓${N} Paired successfully!"
        sleep 2
        # Now try to connect on default ports
        local port=$(_find_port "$ip" "silent")
        if [[ -n "$port" ]]; then
          echo "$port"
          return 0
        fi
      else
        echo -e "${R}✗${N} Pairing failed"
      fi
    fi
  fi

  return 1
}

# ============================================================================
# Auto-detect connected USB device and get its IP
# ============================================================================
_detect_usb_device() {
  echo -e "${B}🔍 Checking for USB-connected devices...${N}"

  local devices=$(adb devices | grep -v "List" | grep "device$" | awk '{print $1}')

  if [[ -z "$devices" ]]; then
    return 1
  fi

  local device=$(echo "$devices" | head -n1)
  echo -e "${G}✓${N} Found USB device: $device"

  # Get IP address from device
  local ip=$(adb -s "$device" shell ip route 2>/dev/null | grep -oE '192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

  if [[ -n "$ip" ]]; then
    echo -e "${G}✓${N} Device IP: $ip"
    echo "$ip"
    return 0
  fi

  return 1
}

# ============================================================================
# Enable wireless debugging on USB device
# ============================================================================
_enable_wireless_usb() {
  echo -e "${B}🔌 Attempting to enable wireless debugging via USB...${N}"

  local devices=$(adb devices | grep -v "List" | grep "device$" | awk '{print $1}')

  if [[ -z "$devices" ]]; then
    echo -e "${R}✗${N} No USB device found"
    return 1
  fi

  local device=$(echo "$devices" | head -n1)

  # Try to start tcpip mode on port 5555
  echo "Enabling TCP/IP mode..."
  adb -s "$device" tcpip 5555 &>/dev/null
  sleep 2

  # Get device IP
  local ip=$(adb -s "$device" shell ip route 2>/dev/null | grep -oE '192\.168\.[0-9]+\.[0-9]+|10\.[0-9]+\.[0-9]+\.[0-9]+' | head -n1)

  if [[ -n "$ip" ]]; then
    echo -e "${G}✓${N} Wireless debugging enabled on $ip:5555"
    echo "$ip|5555"
    return 0
  fi

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
# Setup port forwarding
# ============================================================================
_setup_ports() {
  adb reverse --remove-all &>/dev/null
  local count=0
  for port in "${FORWARD_PORTS[@]}"; do
    if adb reverse tcp:$port tcp:$port &>/dev/null; then
      ((count++))
    fi
  done
  if [[ $count -gt 0 ]]; then
    echo -e "${G}✓${N} Forwarded $count ports: ${FORWARD_PORTS[*]}"
  fi
}

# ============================================================================
# Quick connect - tries saved device first, then auto-detect
# ============================================================================
mohx-phone() {
  _init
  _check_adb || return 1

  # Try saved device first
  if [[ -f "$LAST_DEVICE" ]]; then
    local name=$(cat "$LAST_DEVICE")
    local info=$(grep "^$name|" "$CONFIG_FILE")

    if [[ -n "$info" ]]; then
      local ip=$(echo "$info" | cut -d'|' -f2)
      local port=$(echo "$info" | cut -d'|' -f3)

      echo -e "${B}📱 Connecting to $name ($ip:$port)...${N}"

      # Try saved connection
      if adb connect "$ip:$port" 2>&1 | grep -q "connected\|already"; then
        _setup_ports
        echo -e "${G}✅ Connected to $name!${N}"
        return 0
      fi

      # Try to find new port
      echo -e "${Y}⚡ Port changed, searching...${N}"
      local new_port=$(_find_port "$ip")
      if [[ -n "$new_port" ]]; then
        adb connect "$ip:$new_port" &>/dev/null
        _save "$name" "$ip" "$new_port"
        _setup_ports
        echo -e "${G}✅ Connected on new port $new_port!${N}"
        return 0
      fi
    fi
  fi

  # Auto-detect mode
  echo -e "${Y}⚡ Auto-detect mode${N}"
  _restart_adb

  # Check for USB device
  local usb_result=$(_enable_wireless_usb)
  if [[ -n "$usb_result" ]]; then
    local ip=$(echo "$usb_result" | cut -d'|' -f1)
    local port=$(echo "$usb_result" | cut -d'|' -f2)

    sleep 1
    if adb connect "$ip:$port" 2>&1 | grep -q "connected"; then
      echo "Save this device? (y/n)"
      read save_choice
      if [[ "$save_choice" == "y" ]]; then
        read "device_name?Device name: "
        _save "${device_name:-usb-device}" "$ip" "$port"
      fi
      _setup_ports
      echo -e "${G}✅ Connected via USB setup!${N}"
      return 0
    fi
  fi

  echo -e "${R}✗${N} Could not connect automatically"
  echo ""
  echo "Try these steps:"
  echo "  1. Connect via USB first (if possible)"
  echo "  2. Run: mohx-phone-pair"
  echo "  3. Run: mohx-phone-help"
}

# ============================================================================
# Pair new device (improved)
# ============================================================================
mohx-phone-pair() {
  _init
  _check_adb || return 1
  _restart_adb

  echo -e "\n${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo -e "${G}  📱 Device Pairing Wizard${N}"
  echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}\n"

  # Check for USB device first
  echo -e "${B}Step 1: Checking USB connection...${N}"
  local usb_ip=$(_detect_usb_device)

  if [[ -n "$usb_ip" ]]; then
    echo "Found USB device! Use this IP? (y/n)"
    read use_usb
    if [[ "$use_usb" == "y" ]]; then
      ip="$usb_ip"

      # Try to enable wireless
      local usb_result=$(_enable_wireless_usb)
      if [[ -n "$usb_result" ]]; then
        port=$(echo "$usb_result" | cut -d'|' -f2)
      fi
    fi
  fi

  # Manual IP entry
  if [[ -z "$ip" ]]; then
    echo -e "\n${B}Step 2: Enter device IP${N}"
    echo "Find it: Settings → About → Status → IP address"
    read "ip?IP address: "

    if [[ ! "$ip" =~ ^[0-9.]+$ ]]; then
      echo -e "${R}✗${N} Invalid IP format"
      return 1
    fi
  fi

  # Device name
  read "name?Device name (e.g., phone): "
  [[ -z "$name" ]] && name="device-$(date +%s)"

  echo -e "\n${B}Step 3: Finding connection...${N}"

  # Try to find port
  if [[ -z "$port" ]]; then
    port=$(_find_port "$ip")
  fi

  # If still no port, try pairing mode
  if [[ -z "$port" ]]; then
    port=$(_try_pairing_mode "$ip")
  fi

  # Last resort: network scan
  if [[ -z "$port" ]]; then
    echo -e "${Y}Trying network scan...${N}"
    local scan_result=$(_scan_network "$ip")
    if [[ -n "$scan_result" ]]; then
      ip=$(echo "$scan_result" | cut -d'|' -f1)
      port=$(echo "$scan_result" | cut -d'|' -f2)
    fi
  fi

  if [[ -z "$port" ]]; then
    echo -e "\n${R}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo -e "${R}✗ Connection Failed${N}"
    echo -e "${R}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
    echo ""
    echo "Troubleshooting:"
    echo "  ✓ Enable: Settings → Developer Options → Wireless Debugging"
    echo "  ✓ Check same WiFi network (no guest network)"
    echo "  ✓ Disable VPN on phone"
    echo "  ✓ Try connecting USB first, then run this again"
    echo "  ✓ Check firewall settings"
    echo ""
    return 1
  fi

  # Connect
  adb connect "$ip:$port" &>/dev/null
  _save "$name" "$ip" "$port"
  _setup_ports

  echo -e "\n${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo -e "${G}✅ Success! Device paired and connected${N}"
  echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo ""
  echo "Saved as: $name ($ip:$port)"
  echo "To reconnect: mohx-phone"
  echo ""
}

# ============================================================================
# List devices
# ============================================================================
mohx-phone-list() {
  _init

  if [[ ! -s "$CONFIG_FILE" ]]; then
    echo -e "${Y}No devices saved yet${N}"
    echo "Run: mohx-phone-pair"
    return
  fi

  echo -e "\n${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}"
  echo -e "${G}  📱 Saved Devices${N}"
  echo -e "${G}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${N}\n"

  local current=$(cat "$LAST_DEVICE" 2>/dev/null)

  while IFS='|' read -r name ip port; do
    local marker="   "
    local color="$N"
    if [[ "$name" == "$current" ]]; then
      marker=" ${G}▸${N} "
      color="$G"
    fi
    echo -e "$marker${color}$name${N} → $ip:$port"
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
    echo -e "${R}✗${N} Device '$1' not found"
    mohx-phone-list
    return 1
  fi
}

# ============================================================================
# Remove device
# ============================================================================
mohx-phone-remove() {
  _init

  if [[ -z "$1" ]]; then
    echo "Usage: mohx-phone-remove <name>"
    mohx-phone-list
    return 1
  fi

  if grep -q "^$1|" "$CONFIG_FILE"; then
    grep -v "^$1|" "$CONFIG_FILE" > "$CONFIG_FILE.tmp"
    mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo -e "${G}✓${N} Removed: $1"
  else
    echo -e "${R}✗${N} Device not found"
  fi
}

# ============================================================================
# Disconnect
# ============================================================================
mohx-phone-disconnect() {
  adb reverse --remove-all &>/dev/null
  adb disconnect &>/dev/null
  echo -e "${G}✓${N} Disconnected all devices"
}

# ============================================================================
# Status check
# ============================================================================
mohx-phone-status() {
  echo -e "\n${B}📊 ADB Status${N}\n"

  echo "Connected devices:"
  adb devices -l

  echo -e "\n${B}Port forwards:${N}"
  adb reverse --list 2>/dev/null || echo "None"

  if [[ -f "$LAST_DEVICE" ]]; then
    local name=$(cat "$LAST_DEVICE")
    echo -e "\n${B}Default device:${N} $name"
  fi
  echo ""
}

# ============================================================================
# Help
# ============================================================================
mohx-phone-help() {
  cat << 'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  📱 Robust Android Device Manager
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

COMMANDS:
  mohx-phone                → Connect (auto-detect or use saved)
  mohx-phone-pair           → Add new device (with wizard)
  mohx-phone-list           → Show all saved devices
  mohx-phone-switch <name>  → Switch default device
  mohx-phone-remove <name>  → Remove saved device
  mohx-phone-status         → Show connection status
  mohx-phone-disconnect     → Disconnect all devices
  mohx-phone-help           → Show this help

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 QUICK START:

  METHOD 1 - USB First (Recommended):
    1. Connect phone via USB cable
    2. Enable USB debugging on phone
    3. Run: mohx-phone-pair
    4. Unplug USB, now wireless works!
    5. Daily use: mohx-phone

  METHOD 2 - Pure Wireless:
    1. Enable Wireless Debugging on phone
    2. Get IP: Settings → About → Status
    3. Run: mohx-phone-pair
    4. Enter IP when prompted
    5. Daily use: mohx-phone

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✨ FEATURES:

  • Auto-detects USB devices
  • Enables wireless debugging automatically
  • Scans multiple ports (5555, 37000, etc.)
  • Network scanning fallback
  • Saves devices for quick reconnect
  • Auto-forwards dev ports (8081, 3000, 8000)
  • Handles port changes automatically
  • Works with multiple devices

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📋 COMMON SCENARIOS:

  • First time setup:
    → Connect USB + mohx-phone-pair

  • Daily use:
    → mohx-phone (connects instantly)

  • Phone restarted:
    → mohx-phone (auto-finds new port)

  • Multiple devices:
    → mohx-phone-pair for each
    → mohx-phone-switch <name>

  • Check what's connected:
    → mohx-phone-status

  • Something broke:
    → adb kill-server
    → mohx-phone

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️  TROUBLESHOOTING:

  Can't connect?
    ✓ Same WiFi (not guest network)
    ✓ Wireless Debugging ON
    ✓ Try USB connection first
    ✓ Disable VPN on phone
    ✓ Check firewall settings
    ✓ Restart phone WiFi

  Still not working?
    → Run: adb kill-server
    → Then: mohx-phone-pair

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

EOF
}

# Initialize on load
_init &>/dev/null
