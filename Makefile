.PHONY: all build build-release install install-system uninstall clean run-gui run-server help
.PHONY: check test fmt package package-deb package-rpm package-appimage package-all verify-packaging

# Default target
all: build

# Build in debug mode
build:
	@echo "🔨 Building Astra Gesture Control (debug)..."
	cargo build

# Build in release mode
build-release:
	@echo "🔨 Building Astra Gesture Control (release)..."
	cargo build --release

# Install the application (user-local)
install: build-release
	@echo "📦 Installing Astra Gesture Control (user-local)..."
	@./install.sh

# Install the application (system-wide)
install-system: build-release
	@echo "📦 Installing Astra Gesture Control (system-wide)..."
	@sudo ./install-system.sh

# Uninstall the application
uninstall:
	@if [ -f "$$HOME/.local/share/astra-gesture-control/uninstall.sh" ]; then \
		$$HOME/.local/share/astra-gesture-control/uninstall.sh; \
	else \
		echo "❌ Astra Gesture Control is not installed (user-local)"; \
		echo "   For system-wide uninstall, run: sudo astra-uninstall"; \
	fi

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean
	rm -rf build dist
	rm -f *.deb *.rpm *.AppImage *.tar.gz SHA256SUMS

# Run GUI application
run-gui:
	@echo "🚀 Running Astra GUI..."
	cargo run --bin astra-gui

# Run server only
run-server:
	@echo "🚀 Running Astra Server..."
	cargo run --bin astra-remote

# Check code
check:
	@echo "🔍 Checking code..."
	cargo check

# Run tests
test:
	@echo "🧪 Running tests..."
	cargo test

# Format code
fmt:
	@echo "✨ Formatting code..."
	cargo fmt

# Verify packaging setup
verify-packaging:
	@echo "🔍 Verifying packaging setup..."
	@./verify-packaging.sh

# Build Debian package
package-deb:
	@echo "📦 Building Debian package..."
	@./build-deb.sh

# Build RPM package
package-rpm:
	@echo "📦 Building RPM package..."
	@./build-rpm.sh

# Build AppImage
package-appimage:
	@echo "📦 Building AppImage..."
	@./build-appimage.sh

# Build all package formats
package-all:
	@echo "📦 Building all package formats..."
	@./build-all.sh

# Alias for package-all
package: package-all

# Help
help:
	@echo "Astra Gesture Control - Makefile Commands"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build              - Build in debug mode"
	@echo "  make build-release      - Build in release mode"
	@echo ""
	@echo "Run Commands:"
	@echo "  make run-gui            - Run the GUI application"
	@echo "  make run-server         - Run the server only"
	@echo ""
	@echo "Installation Commands:"
	@echo "  make install            - Build and install (user-local)"
	@echo "  make install-system     - Build and install (system-wide, requires sudo)"
	@echo "  make uninstall          - Uninstall the application"
	@echo ""
	@echo "Packaging Commands:"
	@echo "  make verify-packaging   - Verify packaging setup"
	@echo "  make package-deb        - Build Debian package (.deb)"
	@echo "  make package-rpm        - Build RPM package (.rpm)"
	@echo "  make package-appimage   - Build AppImage (portable)"
	@echo "  make package-all        - Build all package formats"
	@echo "  make package            - Alias for package-all"
	@echo ""
	@echo "Development Commands:"
	@echo "  make check              - Check code for errors"
	@echo "  make test               - Run tests"
	@echo "  make fmt                - Format code"
	@echo ""
	@echo "Utility Commands:"
	@echo "  make clean              - Remove build artifacts and packages"
	@echo "  make help               - Show this help message"
