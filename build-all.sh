#!/bin/bash
# Build all package formats for Astra Gesture Control

set -e

echo "🚀 Building all package formats for Astra Gesture Control..."
echo ""

# Clean previous builds
echo "🧹 Cleaning previous builds..."
rm -rf build dist
mkdir -p dist

# Build Debian package
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 Building Debian package (.deb)..."
echo "═══════════════════════════════════════════════════════════"
./build-deb.sh

# Build RPM package (if rpmbuild is available)
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 Building RPM package (.rpm)..."
echo "═══════════════════════════════════════════════════════════"
if command -v rpmbuild &> /dev/null; then
    ./build-rpm.sh
else
    echo "⚠️  Skipping RPM build (rpmbuild not installed)"
    echo "   Install with: sudo dnf install rpm-build"
fi

# Build AppImage
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 Building AppImage..."
echo "═══════════════════════════════════════════════════════════"
./build-appimage.sh

# Create tarball for manual installation
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📦 Creating tarball for manual installation..."
echo "═══════════════════════════════════════════════════════════"
VERSION="1.0.0"
TARBALL_NAME="astra-gesture-control-${VERSION}-linux-x86_64"
TARBALL_DIR="build/tarball/${TARBALL_NAME}"

mkdir -p "$TARBALL_DIR"
cargo build --release

cp target/release/astra-remote "$TARBALL_DIR/"
cp target/release/astra-gui "$TARBALL_DIR/"
cp install.sh "$TARBALL_DIR/"
cp install-system.sh "$TARBALL_DIR/"
cp astra-gesture-control.desktop "$TARBALL_DIR/"
cp -r assets "$TARBALL_DIR/"
cp README.md "$TARBALL_DIR/"

cd build/tarball
tar czf "${TARBALL_NAME}.tar.gz" "${TARBALL_NAME}"
cd ../..

mv "build/tarball/${TARBALL_NAME}.tar.gz" dist/

# Generate checksums
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "🔐 Generating checksums..."
echo "═══════════════════════════════════════════════════════════"
cd dist
sha256sum * > SHA256SUMS
cd ..

# Display summary
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ All packages built successfully!"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📦 Available packages in dist/ directory:"
echo ""
ls -lh dist/
echo ""
echo "📋 Package formats:"
echo "   • .deb      - For Debian/Ubuntu systems"
echo "   • .rpm      - For Fedora/RHEL systems"
echo "   • .AppImage - Portable, runs on any Linux"
echo "   • .tar.gz   - Manual installation archive"
echo ""
echo "🔐 Checksums: dist/SHA256SUMS"
echo ""
echo "📚 Installation instructions:"
echo "   Debian/Ubuntu: sudo dpkg -i dist/*.deb"
echo "   Fedora/RHEL:   sudo rpm -i dist/*.rpm"
echo "   AppImage:      chmod +x dist/*.AppImage && ./dist/*.AppImage"
echo "   Tarball:       tar xzf dist/*.tar.gz && cd astra-* && ./install.sh"
echo ""
