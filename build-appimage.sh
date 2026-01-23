#!/bin/bash
# Build AppImage for Astra Gesture Control

set -e

VERSION="1.0.0"
APP_NAME="Astra_Gesture_Control"
APPDIR="build/appimage/${APP_NAME}.AppDir"

echo "🏗️  Building AppImage..."

# Clean previous builds
rm -rf build/appimage
mkdir -p "$APPDIR"

# Build the application
echo "📦 Building application in release mode..."
cargo build --release

# Create AppDir structure
echo "📁 Creating AppDir structure..."
mkdir -p "$APPDIR/usr/bin"
mkdir -p "$APPDIR/usr/share/applications"
mkdir -p "$APPDIR/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$APPDIR/usr/lib"

# Copy binaries
echo "📋 Copying binaries..."
cp target/release/astra-remote "$APPDIR/usr/bin/"
cp target/release/astra-gui "$APPDIR/usr/bin/"

# Copy desktop file
cp astra-gesture-control.desktop "$APPDIR/"
cp astra-gesture-control.desktop "$APPDIR/usr/share/applications/"

# Copy icon
cp assets/icon.png "$APPDIR/astra-gesture-control.png"
cp assets/icon.png "$APPDIR/usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png"

# Create AppRun script
cat > "$APPDIR/AppRun" << 'EOF'
#!/bin/bash
SELF=$(readlink -f "$0")
HERE=${SELF%/*}
export PATH="${HERE}/usr/bin:${PATH}"
export LD_LIBRARY_PATH="${HERE}/usr/lib:${LD_LIBRARY_PATH}"
exec "${HERE}/usr/bin/astra-gui" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# Download appimagetool if not present
if [ ! -f "build/appimagetool-x86_64.AppImage" ]; then
    echo "📥 Downloading appimagetool..."
    wget -O build/appimagetool-x86_64.AppImage \
        "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
    chmod +x build/appimagetool-x86_64.AppImage
fi

# Build AppImage
# Build AppImage
echo "🔨 Building AppImage..."
cd build/appimage

# Try to run appimagetool directly
if ! ../appimagetool-x86_64.AppImage --version &> /dev/null; then
    echo "⚠️  FUSE not found or appimagetool failed to run directly."
    echo "🔄 Extracting appimagetool to run without FUSE..."
    
    # Extract appimagetool
    (cd .. && ./appimagetool-x86_64.AppImage --appimage-extract > /dev/null)
    
    # Use extracted version
    ARCH=x86_64 ../squashfs-root/AppRun "${APP_NAME}.AppDir" "${APP_NAME}-${VERSION}-x86_64.AppImage"
else
    # Run directly
    ARCH=x86_64 ../appimagetool-x86_64.AppImage "${APP_NAME}.AppDir" "${APP_NAME}-${VERSION}-x86_64.AppImage"
fi

cd ../..

# Move to dist directory
mkdir -p dist
mv "build/appimage/${APP_NAME}-${VERSION}-x86_64.AppImage" dist/

echo ""
echo "✅ AppImage built successfully!"
echo "📦 Package: dist/${APP_NAME}-${VERSION}-x86_64.AppImage"
echo ""
echo "To run: ./dist/${APP_NAME}-${VERSION}-x86_64.AppImage"
echo "To install: Make it executable and move to /usr/local/bin or ~/bin"
echo ""
