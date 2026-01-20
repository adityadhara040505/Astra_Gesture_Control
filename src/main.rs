use axum::{
    extract::Json,
    http::{StatusCode, Method},
    response::IntoResponse,
    routing::{get, post},
    Router,
};
use serde::{Deserialize, Serialize};
use std::net::SocketAddr;
use std::process::Command;
use tower_http::cors::{CorsLayer, Any};
use tracing::info;

#[derive(Debug, Deserialize)]
struct MouseMove {
    dx: f32,
    dy: f32,
}

#[derive(Debug, Deserialize)]
struct ScrollRequest {
    direction: String,
    amount: Option<i32>,
}

#[derive(Debug, Deserialize)]
struct ClickRequest {
    #[serde(rename = "type")]
    click_type: String,
}

#[derive(Debug, Deserialize)]
struct KeyRequest {
    key: String,
    modifiers: Option<Vec<String>>,
}

#[derive(Debug, Serialize)]
struct ApiResponse {
    status: String,
    message: Option<String>,
}

#[derive(Debug, Deserialize)]
struct VoiceRequest {
    command: String,
}

async fn handle_voice(Json(payload): Json<VoiceRequest>) -> impl IntoResponse {
    info!("🗣️  /voice endpoint hit. Payload: {:?}", payload);
    match execute_voice_command(&payload.command) {
        Ok(msg) => {
            info!("🗣️  Voice command executed successfully: {}", msg);
            (
                StatusCode::OK,
                Json(ApiResponse {
                    status: "success".to_string(),
                    message: Some(msg),
                })
            )
        },
        Err(e) => {
            info!("🗣️  Voice command failed: {}", e);
            (
                StatusCode::BAD_REQUEST,
                Json(ApiResponse {
                    status: "error".to_string(),
                    message: Some(e),
                })
            )
        },
    }
}

fn execute_voice_command(cmd: &str) -> Result<String, String> {
    let cmd = cmd.trim().to_lowercase();
    info!("🗣️  Parsing voice command: {}", cmd);
    // Simple command parsing, extend as needed
    if cmd.starts_with("open ") {
        let app = cmd[5..].trim();
        info!("🗣️  Trying to open app: {}", app);
        // Try to open app using xdg-open or known commands
        let status = Command::new("sh")
            .arg("-c")
            .arg(format!("xdg-open {}", app))
            .status();
        match status {
            Ok(status) if status.success() => {
                info!("🗣️  Opened app: {}", app);
                Ok(format!("Opened {}", app))
            },
            Ok(status) => {
                let msg = format!("Failed to open {} (exit code: {:?})", app, status.code());
                info!("🗣️  {}", msg);
                Err(msg)
            },
            Err(e) => {
                let msg = format!("Failed to run open command: {}", e);
                info!("🗣️  {}", msg);
                Err(msg)
            }
        }
    } else if cmd.starts_with("type ") {
        let text = cmd[5..].trim();
        info!("🗣️  Typing text: {}", text);
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_sequence(text);
        Ok(format!("Typed: {}", text))
    } else if cmd == "play" || cmd == "pause" {
        info!("🗣️  Sending play/pause (space)");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::Space);
        Ok("Toggled play/pause".to_string())
    } else if cmd == "next" {
        info!("🗣️  Sending next track (F9)");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::F9);
        Ok("Next track".to_string())
    } else if cmd == "previous" || cmd == "prev" {
        info!("🗣️  Sending previous track (F7)");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::F7);
        Ok("Previous track".to_string())
    } else if cmd == "volume up" {
        info!("🗣️  Sending volume up");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeUp);
        Ok("Volume up".to_string())
    } else if cmd == "volume down" {
        info!("🗣️  Sending volume down");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeDown);
        Ok("Volume down".to_string())
    } else if cmd == "mute" {
        info!("🗣️  Sending mute");
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeMute);
        Ok("Muted".to_string())
    } else {
        let msg = format!("Unknown voice command: {}", cmd);
        info!("🗣️  {}", msg);
        Err(msg)
    }
}

#[tokio::main]
async fn main() {
    // Initialize tracing
    tracing_subscriber::fmt::init();

    // Build CORS layer
    let cors = CorsLayer::new()
        .allow_origin(Any)
        .allow_methods([Method::GET, Method::POST, Method::OPTIONS])
        .allow_headers(Any);

    // Build our application with routes
    let app = Router::new()
        .route("/", get(health_check))
        .route("/ping", get(health_check))
        .route("/mouse", post(handle_mouse))
        .route("/click", post(handle_click))
        .route("/scroll", post(handle_scroll))
        .route("/key", post(handle_key))
        .route("/voice", post(handle_voice))
        .layer(cors);
#[derive(Debug, Deserialize)]
struct VoiceRequest {
    command: String,
}

async fn handle_voice(Json(payload): Json<VoiceRequest>) -> impl IntoResponse {
    info!("🗣️  Voice command: {}", payload.command);
    match execute_voice_command(&payload.command) {
        Ok(msg) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                message: Some(msg),
            }),
        ),
        Err(e) => (
            StatusCode::BAD_REQUEST,
            Json(ApiResponse {
                status: "error".to_string(),
                message: Some(e),
            }),
        ),
    }
}

fn execute_voice_command(cmd: &str) -> Result<String, String> {
    let cmd = cmd.trim().to_lowercase();
    // Simple command parsing, extend as needed
    if cmd.starts_with("open ") {
        let app = cmd[5..].trim();
        // Try to open app using xdg-open or known commands
        let status = Command::new("sh")
            .arg("-c")
            .arg(format!("xdg-open {}", app))
            .status();
        if let Ok(status) = status {
            if status.success() {
                return Ok(format!("Opened {}", app));
            } else {
                return Err(format!("Failed to open {}", app));
            }
        } else {
            return Err("Failed to run open command".to_string());
        }
    } else if cmd.starts_with("type ") {
        let text = cmd[5..].trim();
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_sequence(text);
        return Ok(format!("Typed: {}", text));
    } else if cmd == "play" || cmd == "pause" {
        // Example: send media key (space for play/pause in many apps)
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::Space);
        return Ok("Toggled play/pause".to_string());
    } else if cmd == "next" {
        // Example: send media next (F9 for some players)
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::F9);
        return Ok("Next track".to_string());
    } else if cmd == "previous" || cmd == "prev" {
        // Example: send media previous (F7 for some players)
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::F7);
        return Ok("Previous track".to_string());
    } else if cmd == "volume up" {
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeUp);
        return Ok("Volume up".to_string());
    } else if cmd == "volume down" {
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeDown);
        return Ok("Volume down".to_string());
    } else if cmd == "mute" {
        let mut enigo = ENIGO.lock().unwrap();
        enigo.key_click(enigo::Key::VolumeMute);
        return Ok("Muted".to_string());
    }
    Err("Unknown voice command".to_string())
}

    // Bind to all interfaces on port 44828
    let addr = SocketAddr::from(([0, 0, 0, 0], 44828));
    info!("🚀 Astra Remote Control Server starting on {}", addr);
    info!("Waiting for mobile client connection...");

    // Start server
    let listener = tokio::net::TcpListener::bind(addr).await.unwrap();
    axum::serve(listener, app).await.unwrap();
}

async fn health_check() -> impl IntoResponse {
    Json(ApiResponse {
        status: "ok".to_string(),
        message: Some("Astra Gesture Control Server - Rust Edition".to_string()),
    })
}

async fn handle_mouse(Json(payload): Json<MouseMove>) -> impl IntoResponse {
    info!("🖱️  Mouse move: dx={}, dy={}", payload.dx, payload.dy);
    
    match move_mouse(payload.dx as i32, payload.dy as i32) {
        Ok(_) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                message: Some("Mouse moved".to_string()),
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                message: Some(e),
            }),
        ),
    }
}

async fn handle_click(Json(payload): Json<ClickRequest>) -> impl IntoResponse {
    info!("🖱️  Click: type={}", payload.click_type);
    
    match execute_click(&payload.click_type) {
        Ok(_) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                message: Some(format!("{} performed", payload.click_type)),
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                message: Some(e),
            }),
        ),
    }
}

async fn handle_scroll(Json(payload): Json<ScrollRequest>) -> impl IntoResponse {
    info!("📜 Scroll: direction={}, amount={:?}", payload.direction, payload.amount);
    
    match execute_scroll(&payload.direction, payload.amount.unwrap_or(1)) {
        Ok(_) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                message: Some("Scrolled".to_string()),
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                message: Some(e),
            }),
        ),
    }
}

async fn handle_key(Json(payload): Json<KeyRequest>) -> impl IntoResponse {
    info!("⌨️  Key: key={}, modifiers={:?}", payload.key, payload.modifiers);
    
    match execute_key(&payload.key, payload.modifiers) {
        Ok(_) => (
            StatusCode::OK,
            Json(ApiResponse {
                status: "success".to_string(),
                message: Some(format!("Key '{}' pressed", payload.key)),
            }),
        ),
        Err(e) => (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(ApiResponse {
                status: "error".to_string(),
                message: Some(e),
            }),
        ),
    }
}

// Input control functions using ydotool (Wayland compatible)
use enigo::*;
use std::sync::Mutex;

lazy_static::lazy_static! {
    static ref ENIGO: Mutex<Enigo> = Mutex::new(Enigo::new());
}

fn move_mouse(dx: i32, dy: i32) -> Result<(), String> {
    // Move mouse relative to current position
    let mut enigo = ENIGO.lock().unwrap();
    enigo.mouse_move_relative(dx, dy);
    Ok(())
}

fn execute_click(click_type: &str) -> Result<(), String> {
    let mut enigo = ENIGO.lock().unwrap();
    match click_type {
        "left" | "left_click" => enigo.mouse_click(MouseButton::Left),
        "right" | "right_click" => enigo.mouse_click(MouseButton::Right),
        "double" | "double_click" => {
            enigo.mouse_click(MouseButton::Left);
            std::thread::sleep(std::time::Duration::from_millis(50));
            enigo.mouse_click(MouseButton::Left);
        }
        _ => return Err(format!("Unknown click type: {}", click_type)),
    }
    Ok(())
}

fn execute_scroll(direction: &str, amount: i32) -> Result<(), String> {
    let mut enigo = ENIGO.lock().unwrap();
    let scroll_amount = amount * 10; // scale for visibility
    match direction {
        "up" => enigo.mouse_scroll_y(scroll_amount),
        "down" => enigo.mouse_scroll_y(-scroll_amount),
        "left" => enigo.mouse_scroll_x(-scroll_amount),
        "right" => enigo.mouse_scroll_x(scroll_amount),
        _ => return Err(format!("Unknown scroll direction: {}", direction)),
    }
    Ok(())
}

fn execute_key(key_name: &str, modifiers: Option<Vec<String>>) -> Result<(), String> {
    let mut enigo = ENIGO.lock().unwrap();
    // Press modifiers
    if let Some(mods) = &modifiers {
        for modifier in mods {
            if let Some(key) = str_to_enigo_key(modifier) {
                enigo.key_down(key);
            }
        }
    }
    // Press main key
    if let Some(key) = str_to_enigo_key(key_name) {
        enigo.key_click(key);
    } else {
        enigo.key_sequence(key_name);
    }
    // Release modifiers
    if let Some(mods) = &modifiers {
        for modifier in mods {
            if let Some(key) = str_to_enigo_key(modifier) {
                enigo.key_up(key);
            }
        }
    }
    Ok(())
}

fn str_to_enigo_key(s: &str) -> Option<enigo::Key> {
    use enigo::Key;
    match s.to_lowercase().as_str() {
        "ctrl" | "control" => Some(Key::Control),
        "alt" => Some(Key::Alt),
        "shift" => Some(Key::Shift),
        "win" | "super" | "meta" => Some(Key::Meta),
        "enter" | "return" => Some(Key::Return),
        "escape" | "esc" => Some(Key::Escape),
        "backspace" | "back" => Some(Key::Backspace),
        "delete" | "del" => Some(Key::Delete),
        "tab" => Some(Key::Tab),
        "space" => Some(Key::Space),
        "capslock" => Some(Key::CapsLock),
        "up" => Some(Key::UpArrow),
        "down" => Some(Key::DownArrow),
        "left" => Some(Key::LeftArrow),
        "right" => Some(Key::RightArrow),
        "pageup" | "page_up" => Some(Key::PageUp),
        "pagedown" | "page_down" => Some(Key::PageDown),
        // Function keys
        "f1" => Some(Key::F1), "f2" => Some(Key::F2), "f3" => Some(Key::F3), "f4" => Some(Key::F4),
        "f5" => Some(Key::F5), "f6" => Some(Key::F6), "f7" => Some(Key::F7), "f8" => Some(Key::F8),
        "f9" => Some(Key::F9), "f10" => Some(Key::F10), "f11" => Some(Key::F11), "f12" => Some(Key::F12),
        // Letters
        "a" => Some(Key::Layout('a')), "b" => Some(Key::Layout('b')), "c" => Some(Key::Layout('c')),
        "d" => Some(Key::Layout('d')), "e" => Some(Key::Layout('e')), "f" => Some(Key::Layout('f')),
        "g" => Some(Key::Layout('g')), "h" => Some(Key::Layout('h')), "i" => Some(Key::Layout('i')),
        "j" => Some(Key::Layout('j')), "k" => Some(Key::Layout('k')), "l" => Some(Key::Layout('l')),
        "m" => Some(Key::Layout('m')), "n" => Some(Key::Layout('n')), "o" => Some(Key::Layout('o')),
        "p" => Some(Key::Layout('p')), "q" => Some(Key::Layout('q')), "r" => Some(Key::Layout('r')),
        "s" => Some(Key::Layout('s')), "t" => Some(Key::Layout('t')), "u" => Some(Key::Layout('u')),
        "v" => Some(Key::Layout('v')), "w" => Some(Key::Layout('w')), "x" => Some(Key::Layout('x')),
        "y" => Some(Key::Layout('y')), "z" => Some(Key::Layout('z')),
        // Numbers
        "0" => Some(Key::Layout('0')), "1" => Some(Key::Layout('1')), "2" => Some(Key::Layout('2')),
        "3" => Some(Key::Layout('3')), "4" => Some(Key::Layout('4')), "5" => Some(Key::Layout('5')),
        "6" => Some(Key::Layout('6')), "7" => Some(Key::Layout('7')), "8" => Some(Key::Layout('8')),
        "9" => Some(Key::Layout('9')),
        _ => None,
    }
}

fn key_to_code(s: &str) -> Option<String> {
    let code = match s.to_lowercase().as_str() {
        // Modifiers (scan codes)
        "ctrl" | "control" => "29",
        "alt" => "56",
        "shift" => "42",
        "win" | "super" | "meta" => "125",
        
        // Special keys
        "enter" | "return" => "28",
        "escape" | "esc" => "1",
        "backspace" | "back" => "14",
        "space" => "57",
        "tab" => "15",
        "delete" | "del" => "111",
        "home" => "102",
        "end" => "107",
        "pageup" | "page_up" => "104",
        "pagedown" | "page_down" => "109",
        
        // Arrow keys
        "up" | "uparrow" => "103",
        "down" | "downarrow" => "108",
        "left" | "leftarrow" => "105",
        "right" | "rightarrow" => "106",
        
        // Function keys
        "f1" => "59",
        "f2" => "60",
        "f3" => "61",
        "f4" => "62",
        "f5" => "63",
        "f6" => "64",
        "f7" => "65",
        "f8" => "66",
        "f9" => "67",
        "f10" => "68",
        "f11" => "87",
        "f12" => "88",
        
        // Letters (a-z)
        "a" => "30", "b" => "48", "c" => "46", "d" => "32", "e" => "18",
        "f" => "33", "g" => "34", "h" => "35", "i" => "23", "j" => "36",
        "k" => "37", "l" => "38", "m" => "50", "n" => "49", "o" => "24",
        "p" => "25", "q" => "16", "r" => "19", "s" => "31", "t" => "20",
        "u" => "22", "v" => "47", "w" => "17", "x" => "45", "y" => "21",
        "z" => "44",
        
        _ => return None,
    };
    
    Some(code.to_string())
}
