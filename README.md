# Astra Remote Control - Rust Edition

High-performance remote control server written in Rust with full Wayland/X11 support.

## Features
- ✅ Mouse control (movement, clicks)
- ✅ Scroll control
- ✅ Keyboard input (keys, modifiers, function keys)
- ✅ Async HTTP API with Axum
- ✅ CORS enabled for mobile app
- ✅ Works on both X11 and Wayland

## Build & Run

```bash
# Build release version
cargo build --release

# Run server
cargo run --release

# Or run the binary directly
./target/release/astra-remote
```

Server listens on `0.0.0.0:44828`

## API Endpoints

### `GET /` or `/ping`
Health check

### `POST /mouse`
```json
{"dx": 10.5, "dy": -5.2}
```

### `POST /click`
```json
{"type": "left"}  // left, right, or double
```

### `POST /scroll`
```json
{"direction": "up", "amount": 5}  // or "down"
```

### `POST /key`
```json
{"key": "enter"}
{"key": "c", "modifiers": ["ctrl"]}
{"key": "f5"}
```

## Supported Keys
- Special: enter, escape, backspace, space, tab, delete, home, end
- Navigation: pageup, pagedown, arrow keys
- Function: f1-f12
- Modifiers: ctrl, alt, shift, win/super
- Single characters: a-z, 0-9, etc.
