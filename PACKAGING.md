# 📦 Astra Gesture Control - Production Packaging

This directory contains everything needed to create production-ready, installable packages for Astra Gesture Control, including ISO integration support.

## 🎯 Quick Start

### Build All Package Formats
```bash
./build-all.sh
```

This will create:
- ✅ Debian package (`.deb`)
- ✅ RPM package (`.rpm`)
- ✅ AppImage (portable)
- ✅ Tarball (`.tar.gz`)
- ✅ SHA256 checksums

All packages will be in the `dist/` directory.

## 📦 Package Formats

### 1. Debian Package (.deb)
**For:** Ubuntu, Debian, Linux Mint, Pop!_OS, Elementary OS

```bash
# Build
./build-deb.sh

# Install
sudo dpkg -i dist/astra-gesture-control_1.0.0_amd64.deb

# Remove
sudo dpkg -r astra-gesture-control
```

### 2. RPM Package (.rpm)
**For:** Fedora, RHEL, CentOS, openSUSE

```bash
# Build (requires rpmbuild)
./build-rpm.sh

# Install
sudo rpm -i dist/astra-gesture-control-1.0.0-1.rpm

# Remove
sudo rpm -e astra-gesture-control
```

### 3. AppImage (Portable)
**For:** Any Linux distribution

```bash
# Build
./build-appimage.sh

# Run (no installation needed)
chmod +x dist/Astra_Gesture_Control-1.0.0-x86_64.AppImage
./dist/Astra_Gesture_Control-1.0.0-x86_64.AppImage
```

### 4. Tarball (Manual Installation)
**For:** Any Linux distribution

```bash
# Extract
tar xzf dist/astra-gesture-control-1.0.0-linux-x86_64.tar.gz
cd astra-gesture-control-1.0.0-linux-x86_64

# Install (user-local)
./install.sh

# Or install system-wide
sudo ./install-system.sh
```

## 🏗️ Installation Methods

### User-Local Installation
Installs to `~/.local/` (no root required):
```bash
./install.sh
```

**Locations:**
- Binaries: `~/.local/bin/`
- Data: `~/.local/share/astra-gesture-control/`
- Desktop: `~/.local/share/applications/`
- Icons: `~/.local/share/icons/`

### System-Wide Installation
Installs to `/usr/local/` (requires root):
```bash
sudo ./install-system.sh
```

**Locations:**
- Binaries: `/usr/local/bin/`
- Data: `/usr/local/share/astra-gesture-control/`
- Desktop: `/usr/share/applications/`
- Icons: `/usr/share/icons/`
- Docs: `/usr/share/doc/astra-gesture-control/`

## 🔧 ISO Integration

### For Custom Linux Distributions

See detailed guide: [`packaging/iso-integration/README.md`](packaging/iso-integration/README.md)

#### Quick Integration Methods:

**1. Pre-installed Package (Recommended)**
```bash
# Build package
./build-deb.sh  # or build-rpm.sh

# Copy to ISO pool
cp dist/*.deb /path/to/iso/pool/main/

# Add to package list
echo "astra-gesture-control" >> /path/to/iso/package-lists/custom.list.chroot
```

**2. System-Wide Installation**
```bash
# In your ISO build hook script:
cd /tmp/Astra_Gesture_Control
./install-system.sh
```

**3. First-Boot Installation**
```bash
# Copy source to ISO
cp -r Astra_Gesture_Control /path/to/iso/includes.chroot/opt/

# Enable first-boot service
cp packaging/iso-integration/firstboot-install.service \
   /path/to/iso/includes.chroot/etc/systemd/system/
systemctl enable astra-firstboot.service
```

## 📋 Package Contents

All packages include:

### Binaries
- `astra-gui` - Graphical user interface
- `astra-remote` - Server component

### Desktop Integration
- Desktop entry file (`.desktop`)
- Application icon (512x512 PNG)
- AppStream metadata (for software centers)

### Documentation
- README.md
- PROJECT_SUMMARY.md
- INSTALLATION_SUCCESS.md

### Scripts
- Uninstallation script
- Configuration templates

## 🔐 Package Verification

Verify package integrity using checksums:

```bash
# Check SHA256
sha256sum -c dist/SHA256SUMS

# Verify specific package
sha256sum dist/astra-gesture-control_1.0.0_amd64.deb
```

## 🛠️ Build Requirements

### All Platforms
- Rust 1.70+ (`cargo`)
- Standard build tools (`gcc`, `make`)

### Debian Package
- `dpkg-deb`

### RPM Package
- `rpmbuild`
- `rpm-build` package

### AppImage
- `wget` (for downloading appimagetool)
- Internet connection (first build only)

## 📁 Directory Structure

```
Astra_Gesture_Control/
├── build-all.sh              # Build all package formats
├── build-deb.sh              # Build Debian package
├── build-rpm.sh              # Build RPM package
├── build-appimage.sh         # Build AppImage
├── install.sh                # User-local installation
├── install-system.sh         # System-wide installation
├── packaging/
│   ├── debian/
│   │   └── DEBIAN/
│   │       ├── control       # Package metadata
│   │       ├── postinst      # Post-install script
│   │       ├── prerm         # Pre-removal script
│   │       └── postrm        # Post-removal script
│   ├── astra-gesture-control.spec  # RPM spec file
│   └── iso-integration/
│       ├── README.md         # ISO integration guide
│       ├── astra-gesture-control.metainfo.xml
│       └── firstboot-install.service
├── build/                    # Build artifacts (gitignored)
└── dist/                     # Final packages (gitignored)
```

## 🚀 Distribution Workflow

### For End Users
1. Download package from releases
2. Install using package manager
3. Launch from application menu

### For Distribution Maintainers
1. Clone repository
2. Run `./build-all.sh`
3. Test packages in clean environment
4. Distribute via repositories or direct download

### For ISO Builders
1. Choose integration method (see ISO guide)
2. Build packages or prepare source
3. Integrate into ISO build process
4. Test ISO in VM
5. Distribute custom ISO

## 🧪 Testing Packages

### Test in Clean Environment
```bash
# Using Docker (Debian/Ubuntu)
docker run -it --rm -v $(pwd)/dist:/packages ubuntu:22.04
apt update && apt install -y /packages/*.deb
astra-gui

# Using Docker (Fedora)
docker run -it --rm -v $(pwd)/dist:/packages fedora:latest
dnf install -y /packages/*.rpm
astra-gui
```

### Test AppImage
```bash
# In any Linux environment
./dist/Astra_Gesture_Control-*.AppImage
```

## 📊 Package Sizes

Approximate sizes:
- `.deb` package: ~8-10 MB
- `.rpm` package: ~8-10 MB
- `.AppImage`: ~12-15 MB
- `.tar.gz`: ~8-10 MB

## 🔄 Updating Packages

To create a new version:

1. Update version in `Cargo.toml`
2. Update version in `packaging/debian/DEBIAN/control`
3. Update version in `packaging/astra-gesture-control.spec`
4. Update version in build scripts
5. Run `./build-all.sh`

## 🐛 Troubleshooting

### Build Failures

**Missing Rust/Cargo:**
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

**Missing dpkg-deb:**
```bash
sudo apt install dpkg-dev
```

**Missing rpmbuild:**
```bash
sudo dnf install rpm-build
```

### Installation Issues

**Permission Denied:**
- Use `sudo` for system-wide installation
- Use user-local installation (`./install.sh`) instead

**Desktop Entry Not Showing:**
```bash
# Update desktop database
update-desktop-database ~/.local/share/applications/
# or
sudo update-desktop-database /usr/share/applications/
```

**Icon Not Showing:**
```bash
# Update icon cache
gtk-update-icon-cache -f -t ~/.local/share/icons/hicolor/
# or
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor/
```

## 📞 Support

For packaging issues:
- Open an issue: https://github.com/adityadhara040505/Astra_Gesture_Control/issues
- Check existing issues for solutions
- Include: OS, package format, error messages

## 📜 License

MIT License - See LICENSE file for details

## 🙏 Credits

- Built with Rust and Cargo
- Uses egui for GUI
- Packaging tools: dpkg, rpmbuild, appimagetool

---

**Ready to distribute!** 🚀

Choose your package format and start sharing Astra Gesture Control with the world!
