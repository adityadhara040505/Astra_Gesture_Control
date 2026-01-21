# 🌟 Astra Gesture Control

**High-performance remote control desktop application with beautiful GUI**

Control your Linux desktop remotely from your mobile device with an intuitive gesture-based interface.

![Astra Icon](assets/icon.png)

## ✨ Features

### Desktop Application
- 🎨 **Beautiful Modern GUI** - Sleek dark theme with gradient accents
- 📱 **QR Code Connection** - Instant mobile device pairing
- 🖱️ **Mouse Sensitivity Control** - Adjust responsiveness to your preference
- 📜 **Scroll Sensitivity** - Fine-tune scrolling behavior
- 📊 **Activity Log** - Monitor last 10 commands in real-time
- 🚀 **Server Management** - Start/Stop server with one click
- 🔄 **Auto-start Option** - Launch server automatically

### Server API
- ✅ Mouse control (movement, clicks)
- ✅ Scroll control (4 directions)
- ✅ Keyboard input (keys, modifiers, function keys)
- ✅ Voice commands (open apps, media control, typing)
- ✅ Async HTTP API with Axum
- ✅ CORS enabled for mobile apps
- ✅ Works on both X11 and Wayland

## 🚀 Quick Start

### Prerequisites
- Rust 1.70+ (install from [rustup.rs](https://rustup.rs))
- Linux with X11 or Wayland
- Build essentials: `sudo apt install build-essential pkg-config libx11-dev libxdo-dev libxcb1-dev`

### Installation

1. **Clone the repository:**
```bash
git clone https://github.com/yourusername/Astra_Gesture_Control.git
cd Astra_Gesture_Control
```

2. **Run the installation script:**
```bash
./install.sh
```

This will:
- Build the application in release mode
- Install binaries to `~/.local/bin`
- Create desktop entry for application menu
- Install application icon
- Create uninstall script

3. **Launch the application:**
- From application menu: Search for "Astra Gesture Control"
- From terminal: `astra-gui`

## 📱 Mobile Connection

1. Launch the Astra GUI application
2. Click "Start Server"
3. Scan the QR code with your mobile device
4. Use the mobile app to control your desktop

**Connection Details:**
- Default Port: `44828`
- Server binds to all network interfaces (`0.0.0.0`)
- IP address is automatically detected and displayed

## 🎮 Usage

### Desktop Application

**Server Controls:**
- **Start Server** - Begin accepting remote connections
- **Stop Server** - Disconnect all clients and stop server
- **Auto-start** - Automatically start server when app launches

**Settings:**
- **Mouse Sensitivity** (0.1x - 3.0x) - Adjust mouse movement speed
- **Scroll Sensitivity** (0.1x - 3.0x) - Adjust scroll speed

**Quick Actions:**
- **Copy IP** - Copy server IP to clipboard
- **Refresh QR** - Regenerate QR code
- **Reset Settings** - Restore default sensitivity values

**Activity Log:**
- View last 10 commands/events
- Real-time timestamps
- Scrollable history

### API Endpoints

#### Health Check
```bash
GET / or /ping
```

#### Mouse Movement
```bash
POST /mouse
Content-Type: application/json

{"dx": 10.5, "dy": -5.2}
```

#### Mouse Click
```bash
POST /click
Content-Type: application/json

{"type": "left"}  # left, right, or double
```

#### Scroll
```bash
POST /scroll
Content-Type: application/json

{"direction": "up", "amount": 5}  # up, down, left, right
```

#### Keyboard
```bash
POST /key
Content-Type: application/json

{"key": "enter"}
{"key": "c", "modifiers": ["ctrl"]}
{"key": "f5"}
```

#### Voice Commands
```bash
POST /voice
Content-Type: application/json

{"command": "open firefox"}
{"command": "type hello world"}
{"command": "play"}
{"command": "volume up"}
```

**Supported Voice Commands:**
- `open <app>` - Launch application
- `type <text>` - Type text
- `play` / `pause` - Media control
- `next` / `previous` - Track control
- `volume up` / `volume down` / `mute` - Volume control

## 🛠️ Development

### Build from Source

**Debug build:**
```bash
cargo build
```

**Release build:**
```bash
cargo build --release
```

**Run GUI:**
```bash
cargo run --bin astra-gui
```

**Run Server only:**
```bash
cargo run --bin astra-remote
```

### Project Structure
```
Astra_Gesture_Control/
├── src/
│   ├── main.rs          # Server implementation
│   └── gui.rs           # Desktop GUI application
├── assets/
│   └── icon.png         # Application icon
├── install.sh           # Installation script
├── astra-gesture-control.desktop  # Desktop entry
├── Cargo.toml           # Dependencies
└── README.md            # This file
```

## 🗑️ Uninstallation

Run the uninstall script:
```bash
~/.local/share/astra-gesture-control/uninstall.sh
```

Or manually:
```bash
rm -rf ~/.local/share/astra-gesture-control
rm ~/.local/bin/astra-{remote,gui}
rm ~/.local/share/applications/astra-gesture-control.desktop
rm ~/.local/share/icons/hicolor/512x512/apps/astra-gesture-control.png
```

## 🔒 Security Notes

⚠️ **Important Security Considerations:**

- The server binds to `0.0.0.0` (all network interfaces)
- No authentication is implemented by default
- Anyone on your network can control your computer
- Recommended for trusted networks only

**Security Recommendations:**
1. Use firewall rules to restrict access
2. Only run on trusted networks
3. Stop the server when not in use
4. Consider implementing authentication for production use

## 🐛 Troubleshooting

**Server won't start:**
- Check if port 44828 is already in use: `sudo netstat -tlnp | grep 44828`
- Ensure you have necessary permissions
- Check firewall settings

**GUI won't launch:**
- Verify all dependencies are installed
- Check for error messages in terminal
- Ensure graphics drivers are up to date

**QR code not displaying:**
- Check network connectivity
- Verify IP address is correct
- Try refreshing the QR code

**Input not working:**
- Ensure you have X11/Wayland permissions
- Check if enigo has necessary system access
- Verify no other input tools are interfering

## 📦 Dependencies

**Runtime:**
- `tokio` - Async runtime
- `axum` - Web framework
- `eframe/egui` - GUI framework
- `enigo` - Input simulation
- `qrcode` - QR code generation
- `local-ip-address` - Network detection

**Build:**
- Rust 1.70+
- pkg-config
- X11/Wayland development libraries

## 🤝 Contributing

Contributions are welcome! Please feel free to submit pull requests.

## 📄 License

This project is open source. See LICENSE file for details.

## 🙏 Acknowledgments

- Built with Rust 🦀
- GUI powered by egui
- Server powered by Axum
- Input control via enigo

---

**Made with ❤️ for seamless desktop control**
