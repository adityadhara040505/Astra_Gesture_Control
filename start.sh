#!/bin/bash
# Quick start script for Astra Gesture Control

echo "🌟 Astra Gesture Control - Quick Start"
echo ""

# Check if already installed
if [ -f "$HOME/.local/share/astra-gesture-control/astra-gui" ]; then
    echo "✅ Astra is already installed!"
    echo "🚀 Launching GUI..."
    "$HOME/.local/share/astra-gesture-control/astra-gui"
else
    echo "📦 Astra is not installed yet."
    echo "🔨 Would you like to install it now? (y/n)"
    read -r response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        ./install.sh
        echo ""
        echo "🚀 Launching GUI..."
        "$HOME/.local/share/astra-gesture-control/astra-gui"
    else
        echo "ℹ️  Run ./install.sh to install Astra Gesture Control"
    fi
fi
