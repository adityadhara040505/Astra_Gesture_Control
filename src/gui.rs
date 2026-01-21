use eframe::egui;
use std::sync::{Arc, Mutex};
use std::process::{Command, Child};
use std::collections::VecDeque;
use qrcode::QrCode;
use image::Luma;
use local_ip_address::local_ip;

const APP_ICON: &[u8] = include_bytes!("../assets/icon.png");

#[derive(Clone, Debug)]
struct LogEntry {
    timestamp: String,
    command: String,
}

struct AstraApp {
    server_process: Arc<Mutex<Option<Child>>>,
    server_running: bool,
    mouse_sensitivity: f32,
    scroll_sensitivity: f32,
    ip_address: String,
    port: u16,
    qr_texture: Option<egui::TextureHandle>,
    command_logs: Arc<Mutex<VecDeque<LogEntry>>>,
    auto_start: bool,
}

impl Default for AstraApp {
    fn default() -> Self {
        let ip = local_ip().unwrap_or_else(|_| "127.0.0.1".parse().unwrap()).to_string();
        
        Self {
            server_process: Arc::new(Mutex::new(None)),
            server_running: false,
            mouse_sensitivity: 1.0,
            scroll_sensitivity: 1.0,
            ip_address: ip,
            port: 44828,
            qr_texture: None,
            command_logs: Arc::new(Mutex::new(VecDeque::with_capacity(10))),
            auto_start: false,
        }
    }
}

impl AstraApp {
    fn new(cc: &eframe::CreationContext<'_>) -> Self {
        // Set custom fonts and style
        let mut style = (*cc.egui_ctx.style()).clone();
        style.visuals.window_rounding = 10.0.into();
        style.visuals.window_shadow.blur = 20.0;
        style.visuals.window_shadow.spread = 5.0;
        cc.egui_ctx.set_style(style);
        
        let mut app = Self::default();
        app.generate_qr_code(&cc.egui_ctx);
        app
    }

    fn generate_qr_code(&mut self, ctx: &egui::Context) {
        let connection_url = format!("http://{}:{}", self.ip_address, self.port);
        
        if let Ok(code) = QrCode::new(connection_url.as_bytes()) {
            let qr_image = code.render::<Luma<u8>>()
                .min_dimensions(300, 300)
                .max_dimensions(300, 300)
                .build();
            
            let width = qr_image.width() as usize;
            let height = qr_image.height() as usize;
            
            let pixels: Vec<egui::Color32> = qr_image
                .pixels()
                .map(|p| {
                    let val = p.0[0];
                    egui::Color32::from_rgb(val, val, val)
                })
                .collect();
            
            let color_image = egui::ColorImage {
                size: [width, height],
                pixels,
            };
            
            self.qr_texture = Some(ctx.load_texture(
                "qr_code",
                color_image,
                egui::TextureOptions::LINEAR,
            ));
        }
    }

    fn start_server(&mut self) {
        if self.server_running {
            return;
        }

        let result = Command::new("cargo")
            .args(&["run", "--release", "--bin", "astra-remote"])
            .current_dir(env!("CARGO_MANIFEST_DIR"))
            .spawn();

        match result {
            Ok(child) => {
                *self.server_process.lock().unwrap() = Some(child);
                self.server_running = true;
                self.add_log("Server started successfully");
            }
            Err(e) => {
                self.add_log(&format!("Failed to start server: {}", e));
            }
        }
    }

    fn stop_server(&mut self) {
        if !self.server_running {
            return;
        }

        let mut process = self.server_process.lock().unwrap();
        if let Some(mut child) = process.take() {
            let _ = child.kill();
            self.server_running = false;
            self.add_log("Server stopped");
        }
    }

    fn add_log(&self, message: &str) {
        let mut logs = self.command_logs.lock().unwrap();
        let timestamp = chrono::Local::now().format("%H:%M:%S").to_string();
        
        logs.push_front(LogEntry {
            timestamp,
            command: message.to_string(),
        });
        
        if logs.len() > 10 {
            logs.pop_back();
        }
    }
}

impl eframe::App for AstraApp {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        // Custom colors
        let bg_color = egui::Color32::from_rgb(15, 15, 25);
        let panel_color = egui::Color32::from_rgb(25, 25, 40);
        let accent_color = egui::Color32::from_rgb(100, 150, 255);
        
        egui::CentralPanel::default()
            .frame(egui::Frame::none().fill(bg_color))
            .show(ctx, |ui| {
                ui.add_space(20.0);
                
                // Header with title and icon
                ui.horizontal(|ui| {
                    ui.add_space(20.0);
                    ui.heading(
                        egui::RichText::new("🌟 Astra Gesture Control")
                            .size(32.0)
                            .color(accent_color)
                    );
                });
                
                ui.add_space(20.0);
                ui.separator();
                ui.add_space(20.0);
                
                // Main content area
                ui.horizontal(|ui| {
                    ui.add_space(20.0);
                    
                    // Left panel - QR Code and Connection Info
                    ui.vertical(|ui| {
                        egui::Frame::none()
                            .fill(panel_color)
                            .rounding(10.0)
                            .inner_margin(20.0)
                            .show(ui, |ui| {
                                ui.set_min_width(400.0);
                                
                                ui.label(
                                    egui::RichText::new("📱 Connection Info")
                                        .size(20.0)
                                        .color(egui::Color32::WHITE)
                                );
                                ui.add_space(10.0);
                                
                                // IP Address display
                                ui.horizontal(|ui| {
                                    ui.label(egui::RichText::new("IP Address:").size(16.0));
                                    ui.label(
                                        egui::RichText::new(&self.ip_address)
                                            .size(18.0)
                                            .color(accent_color)
                                            .monospace()
                                    );
                                });
                                
                                ui.horizontal(|ui| {
                                    ui.label(egui::RichText::new("Port:").size(16.0));
                                    ui.label(
                                        egui::RichText::new(format!("{}", self.port))
                                            .size(18.0)
                                            .color(accent_color)
                                            .monospace()
                                    );
                                });
                                
                                ui.add_space(15.0);
                                
                                // QR Code
                                if let Some(texture) = &self.qr_texture {
                                    ui.vertical_centered(|ui| {
                                        ui.label(
                                            egui::RichText::new("Scan to Connect")
                                                .size(14.0)
                                                .color(egui::Color32::GRAY)
                                        );
                                        ui.add_space(5.0);
                                        ui.image((texture.id(), egui::vec2(300.0, 300.0)));
                                    });
                                }
                                
                                ui.add_space(15.0);
                                
                                // Server control buttons
                                ui.vertical_centered(|ui| {
                                    let start_btn = egui::Button::new(
                                        egui::RichText::new("▶ Start Server")
                                            .size(18.0)
                                            .color(egui::Color32::WHITE)
                                    )
                                    .fill(egui::Color32::from_rgb(50, 150, 50))
                                    .min_size(egui::vec2(180.0, 45.0))
                                    .rounding(8.0);
                                    
                                    let stop_btn = egui::Button::new(
                                        egui::RichText::new("⏹ Stop Server")
                                            .size(18.0)
                                            .color(egui::Color32::WHITE)
                                    )
                                    .fill(egui::Color32::from_rgb(200, 50, 50))
                                    .min_size(egui::vec2(180.0, 45.0))
                                    .rounding(8.0);
                                    
                                    if self.server_running {
                                        if ui.add(stop_btn).clicked() {
                                            self.stop_server();
                                        }
                                        ui.add_space(5.0);
                                        ui.label(
                                            egui::RichText::new("🟢 Server Running")
                                                .size(14.0)
                                                .color(egui::Color32::from_rgb(100, 255, 100))
                                        );
                                    } else {
                                        if ui.add(start_btn).clicked() {
                                            self.start_server();
                                        }
                                        ui.add_space(5.0);
                                        ui.label(
                                            egui::RichText::new("🔴 Server Stopped")
                                                .size(14.0)
                                                .color(egui::Color32::from_rgb(255, 100, 100))
                                        );
                                    }
                                });
                                
                                ui.add_space(10.0);
                                ui.checkbox(&mut self.auto_start, "Auto-start server on launch");
                            });
                    });
                    
                    ui.add_space(20.0);
                    
                    // Right panel - Controls and Logs
                    ui.vertical(|ui| {
                        // Controls section
                        egui::Frame::none()
                            .fill(panel_color)
                            .rounding(10.0)
                            .inner_margin(20.0)
                            .show(ui, |ui| {
                                ui.set_min_width(400.0);
                                
                                ui.label(
                                    egui::RichText::new("⚙️ Settings")
                                        .size(20.0)
                                        .color(egui::Color32::WHITE)
                                );
                                ui.add_space(15.0);
                                
                                // Mouse sensitivity
                                ui.horizontal(|ui| {
                                    ui.label(egui::RichText::new("🖱️ Mouse Sensitivity:").size(16.0));
                                    ui.add_space(10.0);
                                    ui.add(
                                        egui::Slider::new(&mut self.mouse_sensitivity, 0.1..=3.0)
                                            .text("")
                                            .show_value(true)
                                    );
                                });
                                
                                ui.add_space(10.0);
                                
                                // Scroll sensitivity
                                ui.horizontal(|ui| {
                                    ui.label(egui::RichText::new("📜 Scroll Sensitivity:").size(16.0));
                                    ui.add_space(10.0);
                                    ui.add(
                                        egui::Slider::new(&mut self.scroll_sensitivity, 0.1..=3.0)
                                            .text("")
                                            .show_value(true)
                                    );
                                });
                                
                                ui.add_space(15.0);
                                
                                // Quick actions
                                ui.label(
                                    egui::RichText::new("⚡ Quick Actions")
                                        .size(16.0)
                                        .color(egui::Color32::LIGHT_GRAY)
                                );
                                ui.add_space(8.0);
                                
                                ui.horizontal(|ui| {
                                    if ui.button("📋 Copy IP").clicked() {
                                        ui.output_mut(|o| o.copied_text = self.ip_address.clone());
                                        self.add_log("IP address copied to clipboard");
                                    }
                                    
                                    if ui.button("🔄 Refresh QR").clicked() {
                                        self.generate_qr_code(ctx);
                                        self.add_log("QR code refreshed");
                                    }
                                    
                                    if ui.button("📊 Reset Settings").clicked() {
                                        self.mouse_sensitivity = 1.0;
                                        self.scroll_sensitivity = 1.0;
                                        self.add_log("Settings reset to default");
                                    }
                                });
                            });
                        
                        ui.add_space(20.0);
                        
                        // Logs section
                        egui::Frame::none()
                            .fill(panel_color)
                            .rounding(10.0)
                            .inner_margin(20.0)
                            .show(ui, |ui| {
                                ui.set_min_width(400.0);
                                ui.set_min_height(250.0);
                                
                                ui.label(
                                    egui::RichText::new("📝 Activity Log (Last 10 Commands)")
                                        .size(20.0)
                                        .color(egui::Color32::WHITE)
                                );
                                ui.add_space(10.0);
                                
                                egui::ScrollArea::vertical()
                                    .max_height(200.0)
                                    .show(ui, |ui| {
                                        let logs = self.command_logs.lock().unwrap();
                                        
                                        if logs.is_empty() {
                                            ui.label(
                                                egui::RichText::new("No activity yet...")
                                                    .size(14.0)
                                                    .color(egui::Color32::DARK_GRAY)
                                                    .italics()
                                            );
                                        } else {
                                            for log in logs.iter() {
                                                ui.horizontal(|ui| {
                                                    ui.label(
                                                        egui::RichText::new(&log.timestamp)
                                                            .size(12.0)
                                                            .color(egui::Color32::GRAY)
                                                            .monospace()
                                                    );
                                                    ui.label(
                                                        egui::RichText::new(&log.command)
                                                            .size(13.0)
                                                            .color(egui::Color32::LIGHT_GRAY)
                                                    );
                                                });
                                                ui.add_space(3.0);
                                            }
                                        }
                                    });
                            });
                    });
                    
                    ui.add_space(20.0);
                });
                
                ui.add_space(20.0);
            });
    }

    fn on_exit(&mut self, _gl: Option<&eframe::glow::Context>) {
        self.stop_server();
    }
}

fn main() -> Result<(), eframe::Error> {
    let options = eframe::NativeOptions {
        viewport: egui::ViewportBuilder::default()
            .with_inner_size([900.0, 700.0])
            .with_min_inner_size([800.0, 600.0])
            .with_icon(load_icon()),
        ..Default::default()
    };
    
    eframe::run_native(
        "Astra Gesture Control",
        options,
        Box::new(|cc| Ok(Box::new(AstraApp::new(cc)))),
    )
}

fn load_icon() -> egui::IconData {
    // Try to load the icon, fallback to a simple colored square if it fails
    let (icon_rgba, icon_width, icon_height) = {
        match image::load_from_memory(APP_ICON) {
            Ok(img) => {
                let rgba = img.to_rgba8();
                let (w, h) = rgba.dimensions();
                (rgba.into_raw(), w, h)
            }
            Err(_) => {
                // Fallback: create a simple 32x32 blue icon
                let size = 32;
                let mut pixels = Vec::with_capacity(size * size * 4);
                for _ in 0..size * size {
                    pixels.extend_from_slice(&[100, 150, 255, 255]); // Blue color
                }
                (pixels, size as u32, size as u32)
            }
        }
    };

    egui::IconData {
        rgba: icon_rgba,
        width: icon_width,
        height: icon_height,
    }
}
