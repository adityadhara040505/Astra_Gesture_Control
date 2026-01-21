#!/bin/bash
# Astra Gesture Control - Installation Script

set -e

echo "🌟 Installing Astra Gesture Control..."

# Build the application in release mode
echo "📦 Building application..."
cargo build --release

# Create installation directories
INSTALL_DIR="$HOME/.local/share/astra-gesture-control"
BIN_DIR="$HOME/.local/bin"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons/hicolor/512x512/apps"

echo "📁 Creating directories..."
mkdir -p "$INSTALL_DIR"
mkdir -p "$BIN_DIR"
mkdir -p "$DESKTOP_DIR"
mkdir -p "$ICON_DIR"

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

# Create desktop entry
echo "🖥️  Creating desktop entry..."
cat > "$DESKTOP_DIR/astra-gesture-control.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=Astra Gesture Control
Comment=Remote control your desktop with gestures
Exec=$INSTALL_DIR/astra-gui
Icon=astra-gesture-control
Terminal=false
Categories=Utility;Network;RemoteAccess;
Keywords=remote;control;gesture;mouse;keyboard;
StartupNotify=true
EOF

chmod +x "$DESKTOP_DIR/astra-gesture-control.desktop"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    echo "🔄 Updating desktop database..."
    update-desktop-database "$DESKTOP_DIR"
fi

# Create uninstall script
echo "📝 Creating uninstall script..."
cat > "$INSTALL_DIR/uninstall.sh" << 'EOF'
#!/bin/bash
echo "🗑️  Uninstalling Astra Gesture Control..."

# Remove binaries
rm -f "$HOME/.local/bin/astra-remote"
rm -f "$HOME/.local/bin/astra-gui"

# Remove installation directory
rm -rf "$HOME/.local/share/astra-gesture-control"

# Remove desktop entry
rm -f "$HOME/.local/share/applications/astra-gesture-control.desktop"

# Remove icon
rm -f "$HOME/.local/share/icons/hicolor/512x512/apps/astra-gesture-control.png"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$HOME/.local/share/applications"
fi

echo "✅ Astra Gesture Control has been uninstalled successfully!"
EOF

chmod +x "$INSTALL_DIR/uninstall.sh"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📱 You can now:"
echo "   • Launch from your application menu: 'Astra Gesture Control'"
echo "   • Run from terminal: astra-gui"
echo "   • Start server directly: astra-remote"
echo ""
echo "🗑️  To uninstall, run: $INSTALL_DIR/uninstall.sh"
echo ""
