#!/usr/bin/env bash
set -e

BIN_DIR="$HOME/.local/bin"
APP_DIR="$HOME/.local/share/applications"

echo "=== Uninstalling Waydesk ==="

# 1. Stop active monitor if running
if [ -f "$BIN_DIR/waydesk" ]; then
    "$BIN_DIR/waydesk" stop 2>/dev/null || true
fi

# 2. Remove files
rm -f "$BIN_DIR/waydesk"
rm -f "$APP_DIR/waydesk.desktop"
update-desktop-database "$APP_DIR" 2>/dev/null || true

echo "[+] Removed executable and desktop entry."
echo "Note: Sunshine packages and config (~/.config/sunshine) were kept intact."
echo "=== Uninstallation Complete ==="
