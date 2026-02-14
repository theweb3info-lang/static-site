import SwiftUI

struct ServerListView: View {
    @EnvironmentObject var appState: AppState
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .name
    @State private var showSubscriptions = true
    
    enum SortOrder: String, CaseIterable {
        case name = "Name"
        case latency = "Latency"
        case protocol_ = "Protocol"
    }
    
    var sortedServers: [ServerConfig] {
        let filtered = searchText.isEmpty ? appState.servers : appState.servers.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
        
        switch sortOrder {
        case .name:
            return filtered.sorted { $0.name < $1.name }
        case .latency:
            return filtered.sorted { ($0.latency ?? Int.max) < ($1.latency ?? Int.max) }
        case .protocol_:
            return filtered.sorted { $0.type.rawValue < $1.type.rawValue }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search servers...", text: $searchText)
                    .textFieldStyle(.plain)
                
                if !searchText.isEmpty {
                    Button(action: { searchText = "" }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Divider()
                    .frame(height: 16)
                
                Menu {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Button(action: { sortOrder = order }) {
                            HStack {
                                Text(order.rawValue)
                                if sortOrder == order {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                        .foregroundColor(.secondary)
                }
                .menuStyle(.borderlessButton)
                .frame(width: 30)
            }
            .padding(8)
            .background(Color(NSColor.textBackgroundColor))
            
            Divider()
            
            // Server list
            List {
                ForEach(sortedServers) { server in
                    ServerCardView(server: server)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
        }
    }
}

// MARK: - Server Card View

struct ServerCardView: View {
    let server: ServerConfig
    @EnvironmentObject var appState: AppState
    @State private var isHovered = false
    
    var isCurrentServer: Bool {
        appState.currentServer?.id == server.id && appState.isConnected
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Protocol icon
            ZStack {
                Circle()
                    .fill(protocolColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                
                Text(server.type == .vmess ? "V" : "L")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(protocolColor)
            }
            
            // Server info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(server.name)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if isCurrentServer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                HStack(spacing: 8) {
                    Text("\(server.address):\(server.port)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let network = server.network, network != "tcp" {
                        Text(network.uppercased())
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.2))
                            .cornerRadius(2)
                    }
                    
                    if server.security == "tls" || server.security == "reality" {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
            
            // Latency
            if server.isTesting {
                ProgressView()
                    .scaleEffect(0.6)
                    .frame(width: 50)
            } else if let latency = server.latency {
                Text("\(latency)ms")
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(latencyColor(latency))
                    .frame(width: 50, alignment: .trailing)
            } else {
                Text("-")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(width: 50, alignment: .trailing)
            }
            
            // Connect button (show on hover or if current)
            if isHovered || isCurrentServer {
                Button(action: {
                    Task {
                        if isCurrentServer {
                            await appState.disconnect()
                        } else {
                            await appState.connect(to: server)
                        }
                    }
                }) {
                    Image(systemName: isCurrentServer ? "stop.circle.fill" : "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(isCurrentServer ? .red : .accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentServer ? Color.accentColor.opacity(0.1) : (isHovered ? Color.gray.opacity(0.1) : Color.clear))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrentServer ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            contextMenuItems
        }
    }
    
    var protocolColor: Color {
        server.type == .vmess ? .blue : .purple
    }
    
    func latencyColor(_ latency: Int) -> Color {
        switch latency {
        case 0..<100: return .green
        case 100..<300: return .orange
        default: return .red
        }
    }
    
    @ViewBuilder
    var contextMenuItems: some View {
        Button(action: { Task { await appState.connect(to: server) } }) {
            Label("Connect", systemImage: "play.fill")
        }
        .disabled(isCurrentServer)
        
        Button(action: { Task { await appState.testLatency(for: server) } }) {
            Label("Test Latency", systemImage: "speedometer")
        }
        
        Divider()
        
        Button(action: copyLink) {
            Label("Copy Link", systemImage: "doc.on.doc")
        }
        
        Button(action: { /* show QR */ }) {
            Label("Show QR Code", systemImage: "qrcode")
        }
        
        Divider()
        
        Button(action: { appState.duplicateServer(server) }) {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }
        
        Button(role: .destructive, action: { appState.deleteServer(server) }) {
            Label("Delete", systemImage: "trash")
        }
    }
    
    func copyLink() {
        let link = ConfigParser.generateShareLink(from: server)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link, forType: .string)
    }
}

#Preview {
    ServerListView()
        .environmentObject(AppState.shared)
}
