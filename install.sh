#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"
CONF_DIR="$HOME/.config/sunshine"

echo "=== Installing Waydesk ==="

# 1. Create directories
mkdir -p "$BIN_DIR" "$APP_DIR" "$CONF_DIR"

# 2. Install executable
cp "$REPO_DIR/bin/waydesk" "$BIN_DIR/waydesk"
chmod +x "$BIN_DIR/waydesk"
echo "[+] Installed executable to $BIN_DIR/waydesk"

# 3. Install desktop entry (with absolute path to executable)
sed "s|Exec=waydesk|Exec=$BIN_DIR/waydesk|g" \
    "$REPO_DIR/desktop/waydesk.desktop" > "$APP_DIR/waydesk.desktop"
chmod +x "$APP_DIR/waydesk.desktop"
update-desktop-database "$APP_DIR" 2>/dev/null || true
echo "[+] Installed desktop entry to $APP_DIR/waydesk.desktop"

# 4. Clean up any legacy TabletMonitor artifacts
rm -f "$BIN_DIR/tablet-monitor" "$APP_DIR/tablet-monitor.desktop"

# 5. Detect compositor and deploy matching Sunshine config template
COMPOSITOR="kde"
if [ -n "$HYPRLAND_INSTANCE_SIGNATURE" ] || pgrep -x Hyprland >/dev/null 2>&1; then
    COMPOSITOR="hyprland"
elif [ -n "$SWAYSOCK" ] || pgrep -x sway >/dev/null 2>&1; then
    COMPOSITOR="sway"
fi

CONF_TEMPLATE="$REPO_DIR/config/sunshine-${COMPOSITOR}.conf"

if [ -f "$CONF_DIR/sunshine.conf" ]; then
    echo "[!] Existing sunshine.conf found. Backing up to sunshine.conf.bak"
    cp "$CONF_DIR/sunshine.conf" "$CONF_DIR/sunshine.conf.bak"
fi

if [ -f "$CONF_TEMPLATE" ]; then
    cp "$CONF_TEMPLATE" "$CONF_DIR/sunshine.conf"
    echo "[+] Installed Sunshine config template for ${COMPOSITOR^} to $CONF_DIR/sunshine.conf"
fi

# 6. Disable Sunshine autostart (only runs on-demand)
if command -v systemctl &>/dev/null; then
    systemctl --user disable app-dev.lizardbyte.app.Sunshine.service 2>/dev/null || \
    systemctl --user disable sunshine.service 2>/dev/null || true
    echo "[+] Disabled Sunshine autostart (runs only when Waydesk is toggled on)"
fi

echo ""
echo "=== Installation Complete ==="
echo "Detected compositor: ${COMPOSITOR^}"
echo "You can now launch 'Waydesk' from your application menu or run 'waydesk'."
