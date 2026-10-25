# Waydesk

Turn an Android tablet into a secondary monitor on Linux Wayland using native virtual displays and hardware-accelerated Sunshine/Moonlight streaming.

Supports **KDE Plasma (Wayland)**, **Hyprland**, and **Sway** with automatic compositor detection.

## Overview

Waydesk implements a modular pipeline tailored to modern Wayland compositors:

1. **Virtual Display Output**: Automatically detects the active compositor and spawns a headless output matching your tablet's native resolution:
   - **KDE Plasma**: Uses `krfb-virtualmonitor` (`Virtual-Waydesk`).
   - **Hyprland**: Uses `hyprctl output create headless Waydesk`.
   - **Sway**: Uses `swaymsg create_output` (`HEADLESS-X`).
2. **Hardware Capture & Encoding**: Sunshine captures the virtual output (via KWin PipeWire on KDE, or wlroots portal on Hyprland/Sway) and encodes the video stream using your GPU (NVENC, Intel QuickSync, or AMD VA-API).
3. **Client Playback**: The Moonlight Android client receives and decodes the stream with hardware acceleration, providing smooth 60–120 FPS playback with low latency.
4. **On-Demand Lifecycle**: Starts both the virtual display and the Sunshine service on demand, then shuts them down upon exit. No background processes or GPU encoders remain active when the monitor is off.

## Requirements

### Host Dependencies

- **KDE Plasma (Wayland)**: `krfb` and `sunshine`
- **Hyprland**: `hyprland` and `sunshine`
- **Sway**: `sway` and `sunshine`

#### Arch Linux / CachyOS

```bash
# For KDE Plasma:
sudo pacman -S sunshine krfb

# For Hyprland / Sway:
sudo pacman -S sunshine
```

#### Fedora

```bash
# Install krfb (if using KDE)
sudo dnf install krfb

# Install Sunshine via LizardByte repository or release RPM
sudo dnf copr enable lizardbyte/sunshine
sudo dnf install sunshine
```

#### Debian / Ubuntu

```bash
# Install krfb (if using KDE)
sudo apt install krfb

# Install Sunshine via official .deb from https://github.com/LizardByte/Sunshine/releases
```

### Client (Android)

- **Moonlight Game Streaming** (available on F-Droid and Google Play)

## Installation

```bash
git clone https://github.com/ersidev/waydesk.git
cd waydesk
./install.sh
```

The installer will:

- Install `waydesk` into `~/.local/bin/`
- Install the desktop application launcher into `~/.local/share/applications/`
- Deploy the appropriate Sunshine configuration template to `~/.config/sunshine/sunshine.conf` based on your active compositor
- Disable the Sunshine systemd service from starting automatically on boot

## Network & Firewall Setup

If UFW is enabled, allow Sunshine's streaming ports:

```bash
sudo ufw allow 47984:48010/tcp
sudo ufw allow 47998:48010/udp
sudo ufw reload
```

Alternatively, allow all traffic originating from your local subnet:

```bash
sudo ufw allow from 192.168.1.0/24
```

### Wired Connection (USB Tethering)

For environments where Wi-Fi is congested or sub-5ms latency is required:

1. Connect the tablet to the PC via USB.
2. Enable **USB Tethering** in Android network settings.
3. A local network interface will be created (typically assigning the host `192.168.42.x`).
4. Connect Moonlight directly to that IP.

## First-Time Pairing

1. Start the monitor:
   ```bash
   waydesk on
   ```
2. Open the Sunshine web management interface at `https://localhost:47990` and set admin credentials if this is the first run.
3. Open Moonlight on the tablet. Select your PC (or manually add your host IP).
4. Note the 4-digit PIN displayed on the tablet.
5. In the Sunshine web interface, navigate to the **PIN** tab, enter the code, and submit.
6. Select **Desktop** in Moonlight to start streaming.

## Display Placement

Once active, configure the second monitor's position relative to your primary display:

- **KDE Plasma**: Open **System Settings** -> **Display Configuration** and drag the `Virtual-Waydesk` monitor to your preferred position (left, right, or above).
- **Hyprland**: Add or adjust monitor placement via `hyprctl`:
  ```bash
  # Example: place 2000x1200 monitor to the right of a 1920x1080 primary screen
  hyprctl keyword monitor "Waydesk, 2000x1200@60, 1920x0, 1"
  ```
- **Sway**: Position the output using `swaymsg`:
  ```bash
  swaymsg output HEADLESS-1 pos 1920 0
  ```

## Tablet Settings & Known Quirks

### Disabling Samsung / Android "Auto Touch Protection"

Because Moonlight is categorized as a game in the app stores, Android vendor skins (especially Samsung One UI Game Booster, Xiaomi Game Turbo, and Lenovo Game Assistant) enable touch protection and dim the screen when direct touchscreen interaction is not detected.

To disable this on Samsung devices:

1. Open **Gaming Hub** (or **Game Launcher**).
2. Go to **More** -> **Game Booster Settings**.
3. Set **Auto touch protection** (or _Touch protection power saving_) to **Never**.

### Moonlight Client Settings

Under Moonlight settings (gear icon):

- **Resolution**: Set to **Native** (matches the virtual monitor 1:1).
- **Frame Rate**: Set to 60 FPS (or 120 FPS if supported by the panel).
- **Bitrate**: 20–30 Mbps for local Wi-Fi; 40+ Mbps for USB tethering.
- **Touch Mode**: Switch between **Touchscreen** (direct touch gestures) or **Trackpad** (mouse cursor follows finger) depending on your workflow.
- **Audio Routing**: Toggle **Play audio on PC** if you prefer audio to stay on your computer's speakers rather than routing to the tablet.

## Usage

### Desktop Environment

Launch **Waydesk** from KRunner (`Alt+Space`), rofi, wofi, or your application launcher. Clicking the entry acts as a toggle:

- First click: Starts Sunshine and the virtual display.
- Second click: Stops the virtual display and terminates Sunshine.

### Command Line Interface

```bash
# Toggle current state
waydesk

# Start with default resolution (2000x1200)
waydesk on

# Start with custom resolution (both syntaxes work)
waydesk on 2560x1600
waydesk 1920x1080

# Stop monitor and Sunshine
waydesk off

# Query status and detected compositor
waydesk status

# Print detected compositor
waydesk compositor
```

## Repository Structure

```text
Waydesk/
├── bin/
│   └── waydesk                    # Multi-compositor controller and toggle script
├── config/
│   ├── sunshine-kde.conf          # Template for KDE Plasma (Wayland)
│   ├── sunshine-hyprland.conf     # Template for Hyprland
│   └── sunshine-sway.conf         # Template for Sway
├── desktop/
│   └── waydesk.desktop            # XDG desktop shortcut
├── install.sh                     # Deployment script (auto-detects compositor)
├── uninstall.sh                   # Removal script
├── LICENSE                        # MIT License
└── README.md
```

## Uninstallation

To remove installed binaries, desktop files, and stop running services:

```bash
./uninstall.sh
```

Config files in `~/.config/sunshine/` and system packages are retained.

## License

This project is licensed under the [MIT License](LICENSE).
