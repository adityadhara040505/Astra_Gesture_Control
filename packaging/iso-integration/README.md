# ISO Integration Guide for Astra Gesture Control

This guide explains how to integrate Astra Gesture Control into a custom Linux ISO image.

## Overview

Astra Gesture Control can be pre-installed in your custom Linux distribution ISO in several ways:

1. **Pre-installed Package** - Include the .deb or .rpm in the ISO
2. **System-wide Installation** - Install during ISO build process
3. **Post-install Script** - Install on first boot or user setup

## Method 1: Pre-installed Package (Recommended)

### For Debian/Ubuntu-based ISOs

1. Build the .deb package:
   ```bash
   ./build-deb.sh
   ```

2. Copy the package to your ISO build directory:
   ```bash
   cp dist/astra-gesture-control_*.deb /path/to/iso/pool/main/
   ```

3. Add to package list in your ISO build configuration:
   ```bash
   # In your package list file (e.g., package-lists/custom.list.chroot)
   astra-gesture-control
   ```

4. Update package indices during ISO build.

### For Fedora/RHEL-based ISOs

1. Build the .rpm package:
   ```bash
   ./build-rpm.sh
   ```

2. Copy to your ISO repository:
   ```bash
   cp dist/astra-gesture-control-*.rpm /path/to/iso/Packages/
   ```

3. Add to kickstart file or package group:
   ```
   %packages
   astra-gesture-control
   %end
   ```

4. Rebuild repository metadata:
   ```bash
   createrepo /path/to/iso/Packages/
   ```

## Method 2: System-wide Installation During ISO Build

This method installs Astra directly into the ISO filesystem.

### For Live Build (Debian/Ubuntu)

1. Copy source to chroot hooks directory:
   ```bash
   cp -r /path/to/Astra_Gesture_Control \
       /path/to/iso/config/includes.chroot/tmp/
   ```

2. Create a hook script (`config/hooks/normal/9999-install-astra.hook.chroot`):
   ```bash
   #!/bin/bash
   set -e
   
   cd /tmp/Astra_Gesture_Control
   
   # Install Rust if not present
   if ! command -v cargo &> /dev/null; then
       curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
       source $HOME/.cargo/env
   fi
   
   # Run system installation
   ./install-system.sh
   
   # Cleanup
   cd /
   rm -rf /tmp/Astra_Gesture_Control
   ```

3. Make it executable:
   ```bash
   chmod +x config/hooks/normal/9999-install-astra.hook.chroot
   ```

### For Arch-based ISOs (archiso)

1. Add to `packages.x86_64`:
   ```
   rust
   cargo
   ```

2. Create installation script in `airootfs/root/customize_airootfs.sh`:
   ```bash
   #!/bin/bash
   
   # Clone or copy Astra source
   cd /tmp
   git clone https://github.com/adityadhara040505/Astra_Gesture_Control.git
   cd Astra_Gesture_Control
   
   # Install system-wide
   ./install-system.sh
   
   # Cleanup
   cd /
   rm -rf /tmp/Astra_Gesture_Control
   ```

## Method 3: Post-Install Script

Include Astra in the ISO but install it during first boot or user setup.

### Create First-Boot Service

1. Copy the source or package to ISO:
   ```bash
   mkdir -p /path/to/iso/includes.chroot/opt/
   cp -r Astra_Gesture_Control /path/to/iso/includes.chroot/opt/
   ```

2. Create systemd service (`/etc/systemd/system/astra-firstboot.service`):
   ```ini
   [Unit]
   Description=Install Astra Gesture Control on First Boot
   After=network.target
   ConditionPathExists=!/var/lib/astra-installed
   
   [Service]
   Type=oneshot
   ExecStart=/opt/Astra_Gesture_Control/install-system.sh
   ExecStartPost=/usr/bin/touch /var/lib/astra-installed
   RemainAfterExit=yes
   
   [Install]
   WantedBy=multi-user.target
   ```

3. Enable the service in your ISO build:
   ```bash
   systemctl enable astra-firstboot.service
   ```

## Method 4: Include as Optional Software

Add Astra to a software center or welcome screen for user installation.

### For GNOME Software / KDE Discover

1. Create AppStream metadata (`astra-gesture-control.metainfo.xml`):
   ```xml
   <?xml version="1.0" encoding="UTF-8"?>
   <component type="desktop-application">
     <id>com.astra.GestureControl</id>
     <name>Astra Gesture Control</name>
     <summary>Control your desktop with mobile gestures</summary>
     <description>
       <p>
         Astra Gesture Control allows you to control your desktop computer
         using gestures from your mobile device.
       </p>
     </description>
     <launchable type="desktop-id">astra-gesture-control.desktop</launchable>
     <screenshots>
       <screenshot type="default">
         <image>https://example.com/screenshot.png</image>
       </screenshot>
     </screenshots>
     <url type="homepage">https://github.com/adityadhara040505/Astra_Gesture_Control</url>
     <provides>
       <binary>astra-gui</binary>
     </provides>
   </component>
   ```

2. Place in `/usr/share/metainfo/`

## Pre-configuration for ISO

### Auto-start on Login

To make Astra auto-start for all users:

1. Create autostart entry:
   ```bash
   mkdir -p /etc/xdg/autostart/
   cp astra-gesture-control.desktop /etc/xdg/autostart/
   ```

2. Modify the desktop file to add:
   ```ini
   X-GNOME-Autostart-enabled=true
   ```

### Default Settings

Create system-wide configuration:

```bash
mkdir -p /etc/astra-gesture-control/
cat > /etc/astra-gesture-control/config.json << EOF
{
  "mouse_sensitivity": 1.0,
  "scroll_sensitivity": 1.0,
  "auto_start_server": true,
  "port": 44828
}
EOF
```

## Testing Your ISO

1. Build your ISO with Astra integrated
2. Boot in a VM (VirtualBox, QEMU, etc.)
3. Verify installation:
   ```bash
   which astra-gui
   which astra-remote
   ls /usr/share/applications/astra-gesture-control.desktop
   ```
4. Launch from application menu
5. Test functionality

## Troubleshooting

### Package Not Found
- Ensure package is in correct directory
- Verify package indices are updated
- Check package list syntax

### Build Failures
- Ensure Rust/Cargo is available during build
- Check for missing dependencies
- Review build logs

### Service Not Starting
- Check systemd service status
- Review journal logs: `journalctl -u astra-firstboot`
- Verify file permissions

## Distribution-Specific Notes

### Ubuntu/Debian (Cubic, Live-Build)
- Use .deb package method
- Add to package lists
- Test with `lb build`

### Fedora (Lorax, Pungi)
- Use .rpm package method
- Add to kickstart
- Test with `livemedia-creator`

### Arch (archiso)
- Install from source in customize script
- Add dependencies to packages list
- Test with `mkarchiso`

### openSUSE (KIWI)
- Use .rpm package
- Add to config.xml
- Test with `kiwi-ng`

## Support

For issues with ISO integration, please open an issue at:
https://github.com/adityadhara040505/Astra_Gesture_Control/issues

Include:
- Distribution and version
- ISO build tool
- Error messages
- Build logs
