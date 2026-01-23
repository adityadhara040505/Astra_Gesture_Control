# 🚀 Astra Gesture Control - Quick Reference

## Installation Methods

### 📦 Package Installation (Recommended)

#### Debian/Ubuntu
```bash
sudo dpkg -i astra-gesture-control_1.0.0_amd64.deb
```

#### Fedora/RHEL
```bash
sudo rpm -i astra-gesture-control-1.0.0-1.rpm
```

#### AppImage (Any Linux)
```bash
chmod +x Astra_Gesture_Control-1.0.0-x86_64.AppImage
./Astra_Gesture_Control-1.0.0-x86_64.AppImage
```

### 🔧 From Source

#### User Installation
```bash
git clone https://github.com/adityadhara040505/Astra_Gesture_Control.git
cd Astra_Gesture_Control
./install.sh
```

#### System-Wide Installation
```bash
sudo ./install-system.sh
```

## Building Packages

### All Formats
```bash
./build-all.sh
```

### Individual Formats
```bash
./build-deb.sh        # Debian package
./build-rpm.sh        # RPM package
./build-appimage.sh   # AppImage
```

## Running the Application

### GUI Application
```bash
astra-gui
```
Or search "Astra Gesture Control" in your application menu

### Server Only
```bash
astra-remote
```

## Uninstallation

### Package Removal
```bash
# Debian/Ubuntu
sudo dpkg -r astra-gesture-control

# Fedora/RHEL
sudo rpm -e astra-gesture-control
```

### User Installation
```bash
~/.local/share/astra-gesture-control/uninstall.sh
```

### System Installation
```bash
sudo astra-uninstall
```

## API Endpoints

### Base URL
```
http://<your-ip>:44828
```

### Mouse Movement
```bash
POST /mouse
{"dx": 10, "dy": -5}
```

### Click
```bash
POST /click
{"type": "left"}  # left, right, double
```

### Scroll
```bash
POST /scroll
{"direction": "up", "amount": 5}  # up, down, left, right
```

### Keyboard
```bash
POST /key
{"key": "enter"}
{"key": "c", "modifiers": ["ctrl"]}
```

### Voice Commands
```bash
POST /voice
{"command": "open firefox"}
{"command": "type hello world"}
{"command": "play"}
{"command": "volume up"}
```

## ISO Integration

### Pre-installed Package
```bash
# Copy package to ISO
cp dist/*.deb /path/to/iso/pool/main/

# Add to package list
echo "astra-gesture-control" >> package-lists/custom.list.chroot
```

### System Installation in ISO
```bash
# In ISO build hook
cd /tmp/Astra_Gesture_Control
./install-system.sh
```

### First-Boot Installation
```bash
# Copy to ISO
cp -r Astra_Gesture_Control /path/to/iso/includes.chroot/opt/

# Enable service
cp packaging/iso-integration/firstboot-install.service \
   /path/to/iso/includes.chroot/etc/systemd/system/
systemctl enable astra-firstboot.service
```

## File Locations

### User Installation
- Binaries: `~/.local/bin/`
- Data: `~/.local/share/astra-gesture-control/`
- Desktop: `~/.local/share/applications/`
- Icons: `~/.local/share/icons/hicolor/512x512/apps/`

### System Installation
- Binaries: `/usr/local/bin/` or `/usr/bin/`
- Data: `/usr/local/share/astra-gesture-control/`
- Desktop: `/usr/share/applications/`
- Icons: `/usr/share/icons/hicolor/512x512/apps/`
- Docs: `/usr/share/doc/astra-gesture-control/`

## Troubleshooting

### Port Already in Use
```bash
sudo netstat -tlnp | grep 44828
sudo kill <PID>
```

### Desktop Entry Not Showing
```bash
update-desktop-database ~/.local/share/applications/
# or
sudo update-desktop-database /usr/share/applications/
```

### Icon Not Showing
```bash
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor/
# or
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/
```

### Build Dependencies
```bash
# Debian/Ubuntu
sudo apt install build-essential pkg-config libx11-dev libxdo-dev

# Fedora
sudo dnf install gcc pkg-config libX11-devel

# Arch
sudo pacman -S base-devel libx11
```

## Default Settings

- **Port**: 44828
- **Mouse Sensitivity**: 1.0x
- **Scroll Sensitivity**: 1.0x
- **Auto-start**: Disabled

## Security Notes

⚠️ **No authentication by default**
- Use on trusted networks only
- Stop server when not in use
- Consider firewall rules

## Support

- **Issues**: https://github.com/adityadhara040505/Astra_Gesture_Control/issues
- **Documentation**: See README.md and PACKAGING.md
- **ISO Guide**: See packaging/iso-integration/README.md

---

**Quick Start**: `./install.sh` → Search "Astra" → Click "Start Server" → Scan QR Code
