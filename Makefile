.PHONY: all build build-release install uninstall clean run-gui run-server help

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

# Install the application
install: build-release
	@echo "📦 Installing Astra Gesture Control..."
	@./install.sh

# Uninstall the application
uninstall:
	@if [ -f "$$HOME/.local/share/astra-gesture-control/uninstall.sh" ]; then \
		$$HOME/.local/share/astra-gesture-control/uninstall.sh; \
	else \
		echo "❌ Astra Gesture Control is not installed"; \
	fi

# Clean build artifacts
clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean

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

# Help
help:
	@echo "Astra Gesture Control - Makefile Commands"
	@echo ""
	@echo "Available targets:"
	@echo "  make build          - Build in debug mode"
	@echo "  make build-release  - Build in release mode"
	@echo "  make install        - Build and install the application"
	@echo "  make uninstall      - Uninstall the application"
	@echo "  make clean          - Remove build artifacts"
	@echo "  make run-gui        - Run the GUI application"
	@echo "  make run-server     - Run the server only"
	@echo "  make check          - Check code for errors"
	@echo "  make test           - Run tests"
	@echo "  make fmt            - Format code"
	@echo "  make help           - Show this help message"
