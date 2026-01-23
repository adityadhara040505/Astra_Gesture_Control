#!/bin/bash
# Build Debian package for Astra Gesture Control

set -e

VERSION="1.0.0"
ARCH="amd64"
PKG_NAME="astra-gesture-control_${VERSION}_${ARCH}"
BUILD_DIR="build/debian/${PKG_NAME}"

echo "🏗️  Building Debian package..."

# Clean previous builds
rm -rf build/debian
mkdir -p "$BUILD_DIR"

# Build the application
echo "📦 Building application in release mode..."
cargo build --release

# Create directory structure
echo "📁 Creating package structure..."
mkdir -p "$BUILD_DIR/usr/bin"
mkdir -p "$BUILD_DIR/usr/share/applications"
mkdir -p "$BUILD_DIR/usr/share/icons/hicolor/512x512/apps"
mkdir -p "$BUILD_DIR/usr/share/doc/astra-gesture-control"
mkdir -p "$BUILD_DIR/DEBIAN"

# Copy binaries
echo "📋 Copying binaries..."
cp target/release/astra-remote "$BUILD_DIR/usr/bin/"
cp target/release/astra-gui "$BUILD_DIR/usr/bin/"
chmod 755 "$BUILD_DIR/usr/bin/astra-remote"
chmod 755 "$BUILD_DIR/usr/bin/astra-gui"

# Copy desktop file
echo "🖥️  Copying desktop entry..."
cp astra-gesture-control.desktop "$BUILD_DIR/usr/share/applications/"
chmod 644 "$BUILD_DIR/usr/share/applications/astra-gesture-control.desktop"

# Copy icon
echo "🎨 Copying icon..."
cp assets/icon.png "$BUILD_DIR/usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png"
chmod 644 "$BUILD_DIR/usr/share/icons/hicolor/512x512/apps/astra-gesture-control.png"

# Copy documentation
echo "📚 Copying documentation..."
cp README.md "$BUILD_DIR/usr/share/doc/astra-gesture-control/"
chmod 644 "$BUILD_DIR/usr/share/doc/astra-gesture-control/README.md"

# Copy DEBIAN control files
echo "⚙️  Creating control files..."
cp -r packaging/debian/DEBIAN/* "$BUILD_DIR/DEBIAN/"
chmod 755 "$BUILD_DIR/DEBIAN/postinst"
chmod 755 "$BUILD_DIR/DEBIAN/prerm"
chmod 755 "$BUILD_DIR/DEBIAN/postrm"
chmod 644 "$BUILD_DIR/DEBIAN/control"

# Build the package
echo "🔨 Building .deb package..."
dpkg-deb --build "$BUILD_DIR"

# Move to dist directory
mkdir -p dist
mv "build/debian/${PKG_NAME}.deb" "dist/"

echo ""
echo "✅ Debian package built successfully!"
echo "📦 Package: dist/${PKG_NAME}.deb"
echo ""
echo "To install: sudo dpkg -i dist/${PKG_NAME}.deb"
echo "To remove:  sudo dpkg -r astra-gesture-control"
echo ""
