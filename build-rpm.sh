#!/bin/bash
# Build RPM package for Astra Gesture Control

set -e

VERSION="1.0.0"
PKG_NAME="astra-gesture-control"

echo "🏗️  Building RPM package..."

# Check if rpmbuild is installed
if ! command -v rpmbuild &> /dev/null; then
    echo "❌ rpmbuild not found. Please install: sudo dnf install rpm-build"
    exit 1
fi

# Setup RPM build environment
echo "📁 Setting up RPM build environment..."
mkdir -p ~/rpmbuild/{BUILD,RPMS,SOURCES,SPECS,SRPMS}

# Create source tarball
echo "📦 Creating source tarball..."
mkdir -p build/rpm
TEMP_DIR="build/rpm/${PKG_NAME}-${VERSION}"
mkdir -p "$TEMP_DIR"

# Copy source files
cp -r src "$TEMP_DIR/"
cp -r assets "$TEMP_DIR/"
cp Cargo.toml "$TEMP_DIR/"
cp Cargo.lock "$TEMP_DIR/"
cp astra-gesture-control.desktop "$TEMP_DIR/"
cp README.md "$TEMP_DIR/"

# Create tarball
cd build/rpm
tar czf "${PKG_NAME}-${VERSION}.tar.gz" "${PKG_NAME}-${VERSION}"
mv "${PKG_NAME}-${VERSION}.tar.gz" ~/rpmbuild/SOURCES/
cd ../..

# Copy spec file
cp packaging/astra-gesture-control.spec ~/rpmbuild/SPECS/

# Build RPM
echo "🔨 Building RPM package..."
rpmbuild -ba ~/rpmbuild/SPECS/astra-gesture-control.spec

# Copy to dist directory
mkdir -p dist
cp ~/rpmbuild/RPMS/x86_64/${PKG_NAME}-${VERSION}-*.rpm dist/ 2>/dev/null || \
cp ~/rpmbuild/RPMS/aarch64/${PKG_NAME}-${VERSION}-*.rpm dist/ 2>/dev/null || \
echo "⚠️  RPM built but architecture detection failed"

echo ""
echo "✅ RPM package built successfully!"
echo "📦 Package: dist/${PKG_NAME}-${VERSION}-*.rpm"
echo ""
echo "To install: sudo rpm -i dist/${PKG_NAME}-${VERSION}-*.rpm"
echo "To remove:  sudo rpm -e ${PKG_NAME}"
echo ""
