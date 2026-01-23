#!/bin/bash
# System-wide installation script for Astra Gesture Control
# This script installs to /usr/local for system-wide availability
# Suitable for inclusion in ISO images

set -e

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

echo "🌟 Installing Astra Gesture Control (System-wide)..."

# Build the application in release mode
echo "📦 Building application..."
cargo build --release

# Installation directories
INSTALL_DIR="/usr/local/share/astra-gesture-control"
BIN_DIR="/usr/local/bin"
DESKTOP_DIR="/usr/share/applications"
ICON_DIR="/usr/share/icons/hicolor/512x512/apps"
DOC_DIR="/usr/share/doc/astra-gesture-control"

echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"
mkdir -p "$DOC_DIR"

# Copy binaries
echo "📋 Installing binaries..."
cp target/release/astra-remote "$INSTALL_DIR/"
cp target/release/astra-gui "$INSTALL_DIR/"

# Create symlinks in bin directory
ln -sf "$INSTALL_DIR/astra-remote" "$BIN_DIR/astra-remote"
ln -sf "$INSTALL_DIR/astra-gui" "$BIN_DIR/astra-gui"

# Copy icon
echo "🎨 Installing icon..."
cp assets/icon.png "$ICON_DIR/astra-gesture-control.png"

# Copy documentation
echo "📚 Installing documentation..."
cp README.md "$DOC_DIR/"
[ -f "PROJECT_SUMMARY.md" ] && cp PROJECT_SUMMARY.md "$DOC_DIR/"
[ -f "INSTALLATION_SUCCESS.md" ] && cp INSTALLATION_SUCCESS.md "$DOC_DIR/"

# Create desktop entry
echo "🖥️  Creating desktop entry..."
cat > "$DESKTOP_DIR/astra-gesture-control.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Astra Gesture Control
Comment=Remote control your desktop with gestures from your mobile device
Exec=$BIN_DIR/astra-gui
Icon=astra-gesture-control
Terminal=false
Categories=Utility;Network;RemoteAccess;
Keywords=remote;control;gesture;mouse;keyboard;mobile;
StartupNotify=true
EOF

chmod 644 "$DESKTOP_DIR/astra-gesture-control.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    echo "🔄 Updating desktop database..."
    update-desktop-database "$DESKTOP_DIR" || true
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    echo "🎨 Updating icon cache..."
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi

# Create uninstall script
echo "📝 Creating uninstall script..."
cat > "$INSTALL_DIR/uninstall-system.sh" << 'UNINSTALL_EOF'
#!/bin/bash
# System-wide uninstallation script

if [ "$EUID" -ne 0 ]; then 
    echo "❌ Please run as root (use sudo)"
    exit 1
fi

echo "🗑️  Uninstalling Astra Gesture Control..."

# Stop any running instances
pkill -f astra-remote || true
pkill -f astra-gui || true

# Remove binaries
rm -f /usr/local/bin/astra-remote
rm -f /usr/local/bin/astra-gui

# Remove installation directory
rm -rf /usr/local/share/astra-gesture-control

# Remove desktop entry
rm -f /usr/share/applications/astra-gesture-control.desktop

# Remove icon
rm -f /usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png

# Remove documentation
rm -rf /usr/share/doc/astra-gesture-control

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database /usr/share/applications || true
fi

# Update icon cache
if command -v gtk-update-icon-cache &> /dev/null; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor || true
fi

echo "✅ Astra Gesture Control has been uninstalled successfully!"
UNINSTALL_EOF

chmod +x "$INSTALL_DIR/uninstall-system.sh"

# Create symlink for easy uninstallation
ln -sf "$INSTALL_DIR/uninstall-system.sh" "$BIN_DIR/astra-uninstall"

echo ""
echo "✅ System-wide installation complete!"
echo ""
echo "📱 You can now:"
echo "   • Launch from your application menu: 'Astra Gesture Control'"
echo "   • Run from terminal: astra-gui"
echo "   • Start server directly: astra-remote"
echo ""
echo "🗑️  To uninstall, run: sudo astra-uninstall"
echo "   Or: sudo $INSTALL_DIR/uninstall-system.sh"
echo ""
echo "📦 Installation locations:"
echo "   Binaries:      $BIN_DIR"
echo "   Application:   $INSTALL_DIR"
echo "   Desktop Entry: $DESKTOP_DIR"
echo "   Icon:          $ICON_DIR"
echo "   Documentation: $DOC_DIR"
echo ""
