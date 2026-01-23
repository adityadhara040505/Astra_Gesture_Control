#!/bin/bash
# Verify packaging setup for Astra Gesture Control

set -e

echo "🔍 Verifying Astra Gesture Control packaging setup..."
echo ""

# Check for required files
echo "📋 Checking required files..."
REQUIRED_FILES=(
    "build-all.sh"
    "build-deb.sh"
    "build-rpm.sh"
    "build-appimage.sh"
    "install.sh"
    "install-system.sh"
    "packaging/debian/DEBIAN/control"
    "packaging/debian/DEBIAN/postinst"
    "packaging/debian/DEBIAN/prerm"
    "packaging/debian/DEBIAN/postrm"
    "packaging/astra-gesture-control.spec"
    "packaging/iso-integration/README.md"
    "packaging/iso-integration/astra-gesture-control.metainfo.xml"
    "packaging/iso-integration/firstboot-install.service"
    "PACKAGING.md"
    "QUICK_REFERENCE.md"
)

MISSING_FILES=0
for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file (MISSING)"
        MISSING_FILES=$((MISSING_FILES + 1))
    fi
done

echo ""

# Check for executable permissions
echo "🔐 Checking executable permissions..."
EXECUTABLE_FILES=(
    "build-all.sh"
    "build-deb.sh"
    "build-rpm.sh"
    "build-appimage.sh"
    "install.sh"
    "install-system.sh"
)

PERMISSION_ISSUES=0
for file in "${EXECUTABLE_FILES[@]}"; do
    if [ -x "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ⚠️  $file (not executable)"
        PERMISSION_ISSUES=$((PERMISSION_ISSUES + 1))
    fi
done

echo ""

# Check for Rust/Cargo
echo "🦀 Checking build environment..."
if command -v cargo &> /dev/null; then
    CARGO_VERSION=$(cargo --version)
    echo "  ✅ Cargo: $CARGO_VERSION"
else
    echo "  ❌ Cargo not found (install from https://rustup.rs)"
fi

if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo "  ✅ Rust: $RUST_VERSION"
else
    echo "  ❌ Rust not found"
fi

echo ""

# Check for packaging tools
echo "📦 Checking packaging tools..."

if command -v dpkg-deb &> /dev/null; then
    echo "  ✅ dpkg-deb (Debian packaging)"
else
    echo "  ⚠️  dpkg-deb not found (needed for .deb packages)"
fi

if command -v rpmbuild &> /dev/null; then
    echo "  ✅ rpmbuild (RPM packaging)"
else
    echo "  ⚠️  rpmbuild not found (needed for .rpm packages)"
fi

if command -v wget &> /dev/null; then
    echo "  ✅ wget (AppImage tool download)"
else
    echo "  ⚠️  wget not found (needed for AppImage)"
fi

echo ""

# Check project structure
echo "📁 Checking project structure..."
REQUIRED_DIRS=(
    "src"
    "assets"
    "packaging"
    "packaging/debian"
    "packaging/debian/DEBIAN"
    "packaging/iso-integration"
)

DIR_ISSUES=0
for dir in "${REQUIRED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "  ✅ $dir/"
    else
        echo "  ❌ $dir/ (MISSING)"
        DIR_ISSUES=$((DIR_ISSUES + 1))
    fi
done

echo ""

# Summary
echo "═══════════════════════════════════════════════════════════"
echo "📊 Verification Summary"
echo "═══════════════════════════════════════════════════════════"

TOTAL_ISSUES=$((MISSING_FILES + DIR_ISSUES))

if [ $TOTAL_ISSUES -eq 0 ]; then
    echo "✅ All required files and directories present!"
else
    echo "⚠️  Found $TOTAL_ISSUES issue(s)"
fi

if [ $PERMISSION_ISSUES -gt 0 ]; then
    echo "⚠️  Found $PERMISSION_ISSUES permission issue(s)"
    echo "   Run: chmod +x *.sh to fix"
fi

echo ""

if command -v cargo &> /dev/null && command -v dpkg-deb &> /dev/null; then
    echo "🚀 Ready to build Debian packages!"
    echo "   Run: ./build-deb.sh"
fi

if command -v cargo &> /dev/null && command -v rpmbuild &> /dev/null; then
    echo "🚀 Ready to build RPM packages!"
    echo "   Run: ./build-rpm.sh"
fi

if command -v cargo &> /dev/null && command -v wget &> /dev/null; then
    echo "🚀 Ready to build AppImage!"
    echo "   Run: ./build-appimage.sh"
fi

if command -v cargo &> /dev/null; then
    echo "🚀 Ready to build all packages!"
    echo "   Run: ./build-all.sh"
fi

echo ""
echo "📚 Documentation:"
echo "   • PACKAGING.md - Detailed packaging guide"
echo "   • QUICK_REFERENCE.md - Quick command reference"
echo "   • packaging/iso-integration/README.md - ISO integration guide"
echo ""
