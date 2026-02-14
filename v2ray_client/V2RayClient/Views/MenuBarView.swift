import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.openWindow) var openWindow
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with connection status
            HStack {
                Circle()
                    .fill(appState.isConnected ? Color.green : Color.gray)
                    .frame(width: 8, height: 8)
                
                Text(appState.isConnected ? "Connected" : "Disconnected")
                    .font(.headline)
                
                Spacer()
                
                if appState.isConnecting {
                    ProgressView()
                        .scaleEffect(0.6)
                }
            }
            .padding(12)
            .background(Color(NSColor.controlBackgroundColor))
            
            if appState.isConnected, let server = appState.currentServer {
                VStack(spacing: 4) {
                    HStack {
                        Text(server.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Spacer()
                        if let latency = server.latency {
                            Text("\(latency)ms")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    HStack {
                        Label(formatBytes(appState.uploadBytes), systemImage: "arrow.up")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Label(formatBytes(appState.downloadBytes), systemImage: "arrow.down")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            
            Divider()
            
            // Quick connect/disconnect
            Button(action: {
                Task {
                    if appState.isConnected {
                        await appState.disconnect()
                    } else if let server = appState.servers.first {
                        await appState.connect(to: server)
                    }
                }
            }) {
                Label(
                    appState.isConnected ? "Disconnect" : "Connect",
                    systemImage: appState.isConnected ? "stop.fill" : "play.fill"
                )
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.borderless)
            .padding(8)
            .disabled(appState.isConnecting || (appState.servers.isEmpty && !appState.isConnected))
            
            Divider()
            
            // Server list (limited to top 5)
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(appState.servers.prefix(5)) { server in
                        MenuServerRow(server: server)
                    }
                    
                    if appState.servers.count > 5 {
                        Text("+ \(appState.servers.count - 5) more...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                }
            }
            .frame(maxHeight: 200)
            
            Divider()
            
            // Actions
            VStack(spacing: 0) {
                Button(action: {
                    Task { await appState.testAllLatency() }
                }) {
                    Label("Test All Latency", systemImage: "speedometer")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(8)
                
                Button(action: {
                    Task { await appState.selectFastestServer() }
                }) {
                    Label("Select Fastest", systemImage: "bolt.fill")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(8)
                .disabled(appState.servers.isEmpty)
            }
            
            Divider()
            
            // Footer actions
            VStack(spacing: 0) {
                Button(action: {
                    openWindow(id: "main")
                }) {
                    Label("Open Main Window", systemImage: "macwindow")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(8)
                
                Button(action: {
                    // Open Settings window
                    if #available(macOS 14.0, *) {
                        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                    } else {
                        NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                    }
                }) {
                    Label("Settings...", systemImage: "gear")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(8)
                .keyboardShortcut(",", modifiers: .command)
                
                Divider()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Label("Quit V2Ray Client", systemImage: "power")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.borderless)
                .padding(8)
            }
        }
        .frame(width: 280)
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Menu Server Row

struct MenuServerRow: View {
    let server: ServerConfig
    @EnvironmentObject var appState: AppState
    
    var isCurrentServer: Bool {
        appState.currentServer?.id == server.id && appState.isConnected
    }
    
    var body: some View {
        Button(action: {
            Task { await appState.connect(to: server) }
        }) {
            HStack {
                Image(systemName: server.type == .vmess ? "v.circle.fill" : "l.circle.fill")
                    .foregroundColor(server.type == .vmess ? .blue : .purple)
                    .font(.caption)
                
                Text(server.name)
                    .lineLimit(1)
                
                Spacer()
                
                if isCurrentServer {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
                
                if let latency = server.latency {
                    Text("\(latency)ms")
                        .font(.caption2)
                        .foregroundColor(latencyColor(latency))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(isCurrentServer ? Color.accentColor.opacity(0.1) : Color.clear)
    }
    
    func latencyColor(_ latency: Int) -> Color {
        switch latency {
        case 0..<100: return .green
        case 100..<300: return .orange
        default: return .red
        }
    }
}

#Preview {
    MenuBarView()
        .environmentObject(AppState.shared)
}
