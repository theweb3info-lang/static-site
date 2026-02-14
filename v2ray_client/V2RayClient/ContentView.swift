import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedServer: ServerConfig?
    @State private var showAddServer = false
    @State private var showImportSheet = false
    @State private var importText = ""
    @State private var searchText = ""
    
    var filteredServers: [ServerConfig] {
        if searchText.isEmpty {
            return appState.servers
        }
        return appState.servers.filter { 
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.address.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            VStack(spacing: 0) {
                // Connection status header
                ConnectionStatusView()
                    .padding()
                
                Divider()
                
                // Server list
                List(selection: $selectedServer) {
                    Section("Servers (\(appState.servers.count))") {
                        ForEach(filteredServers) { server in
                            ServerRowView(server: server)
                                .tag(server)
                                .contextMenu {
                                    serverContextMenu(for: server)
                                }
                        }
                        .onDelete(perform: deleteServers)
                    }
                    
                    if !appState.subscriptions.isEmpty {
                        Section("Subscriptions") {
                            ForEach(appState.subscriptions) { sub in
                                SubscriptionRowView(subscription: sub)
                            }
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search servers")
                .listStyle(.sidebar)
                
                Divider()
                
                // Bottom toolbar
                HStack {
                    Button(action: { showAddServer = true }) {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.borderless)
                    .help("Add Server")
                    
                    Button(action: { showImportSheet = true }) {
                        Image(systemName: "square.and.arrow.down")
                    }
                    .buttonStyle(.borderless)
                    .help("Import from Clipboard/Link")
                    
                    Button(action: scanQRCode) {
                        Image(systemName: "qrcode.viewfinder")
                    }
                    .buttonStyle(.borderless)
                    .help("Scan QR Code")
                    
                    Spacer()
                    
                    Button(action: testAllLatency) {
                        Image(systemName: "speedometer")
                    }
                    .buttonStyle(.borderless)
                    .help("Test All Latency")
                    
                    Button(action: { 
                        Task { await appState.updateAllSubscriptions() }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                    .buttonStyle(.borderless)
                    .help("Update Subscriptions")
                }
                .padding(8)
            }
            .frame(minWidth: 280)
        } detail: {
            // Detail view
            if let server = selectedServer {
                ServerDetailView(server: server)
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "server.rack")
                        .font(.system(size: 64))
                        .foregroundColor(.secondary)
                    Text("Select a server")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Or add a new one to get started")
                        .font(.subheadline)
                        .foregroundColor(.gray.opacity(0.6))
                    
                    HStack(spacing: 12) {
                        Button("Add Server") {
                            showAddServer = true
                        }
                        Button("Import Link") {
                            showImportSheet = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showAddServer) {
            AddServerView()
        }
        .sheet(isPresented: $showImportSheet) {
            ImportView(importText: $importText)
        }
        .onAppear {
            appState.loadServers()
        }
    }
    
    @ViewBuilder
    func serverContextMenu(for server: ServerConfig) -> some View {
        Button("Connect") {
            Task { await appState.connect(to: server) }
        }
        .disabled(appState.isConnected && appState.currentServer?.id == server.id)
        
        Button("Test Latency") {
            Task { await appState.testLatency(for: server) }
        }
        
        Divider()
        
        Button("Edit") {
            selectedServer = server
            showAddServer = true
        }
        
        Button("Duplicate") {
            appState.duplicateServer(server)
        }
        
        Divider()
        
        Button("Delete", role: .destructive) {
            appState.deleteServer(server)
        }
    }
    
    func deleteServers(at offsets: IndexSet) {
        for index in offsets {
            appState.deleteServer(filteredServers[index])
        }
    }
    
    func scanQRCode() {
        QRCodeScanner.scanFromScreen { result in
            if let config = result {
                DispatchQueue.main.async {
                    importText = config
                    showImportSheet = true
                }
            }
        }
    }
    
    func testAllLatency() {
        Task {
            await appState.testAllLatency()
        }
    }
}

// MARK: - Connection Status View
struct ConnectionStatusView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Circle()
                    .fill(appState.isConnected ? Color.green : Color.red)
                    .frame(width: 10, height: 10)
                
                Text(appState.isConnected ? "Connected" : "Disconnected")
                    .font(.headline)
                
                Spacer()
                
                if appState.isConnecting {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            
            if let server = appState.currentServer, appState.isConnected {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(server.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        Text("\(server.address):\(server.port)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    if let latency = server.latency {
                        Text("\(latency)ms")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(latencyColor(latency))
                            .cornerRadius(4)
                    }
                }
            }
            
            // Traffic stats
            if appState.isConnected {
                HStack {
                    Label(formatBytes(appState.uploadBytes), systemImage: "arrow.up")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label(formatBytes(appState.downloadBytes), systemImage: "arrow.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Quick connect button
            Button(action: {
                Task {
                    if appState.isConnected {
                        await appState.disconnect()
                    } else if let server = appState.servers.first {
                        await appState.connect(to: server)
                    }
                }
            }) {
                HStack {
                    Image(systemName: appState.isConnected ? "stop.fill" : "play.fill")
                    Text(appState.isConnected ? "Disconnect" : "Quick Connect")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(appState.isConnected ? .red : .accentColor)
            .disabled(appState.isConnecting)
        }
    }
    
    func latencyColor(_ latency: Int) -> Color {
        switch latency {
        case 0..<100: return .green.opacity(0.3)
        case 100..<300: return .yellow.opacity(0.3)
        default: return .red.opacity(0.3)
        }
    }
    
    func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
}

// MARK: - Server Row View
struct ServerRowView: View {
    let server: ServerConfig
    @EnvironmentObject var appState: AppState
    
    var isCurrentServer: Bool {
        appState.currentServer?.id == server.id && appState.isConnected
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Protocol icon
            Image(systemName: server.type == .vmess ? "v.circle.fill" : "l.circle.fill")
                .foregroundColor(server.type == .vmess ? .blue : .purple)
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(server.name)
                        .fontWeight(isCurrentServer ? .semibold : .regular)
                    
                    if isCurrentServer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.caption)
                    }
                }
                
                Text("\(server.address):\(server.port)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if let latency = server.latency {
                Text("\(latency)ms")
                    .font(.caption)
                    .foregroundColor(latencyTextColor(latency))
            } else if server.isTesting {
                ProgressView()
                    .scaleEffect(0.5)
            }
        }
        .padding(.vertical, 2)
    }
    
    func latencyTextColor(_ latency: Int) -> Color {
        switch latency {
        case 0..<100: return .green
        case 100..<300: return .orange
        default: return .red
        }
    }
}

// MARK: - Subscription Row View
struct SubscriptionRowView: View {
    let subscription: Subscription
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        HStack {
            Image(systemName: "link.circle.fill")
                .foregroundColor(.orange)
            
            VStack(alignment: .leading) {
                Text(subscription.name)
                Text("\(subscription.serverCount) servers")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if subscription.isUpdating {
                ProgressView()
                    .scaleEffect(0.6)
            } else {
                Button(action: {
                    Task { await appState.updateSubscription(subscription) }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.borderless)
            }
        }
    }
}

// MARK: - Server Detail View
struct ServerDetailView: View {
    let server: ServerConfig
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                HStack {
                    VStack(alignment: .leading) {
                        Text(server.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        HStack {
                            Label(server.type.rawValue.uppercased(), systemImage: "shield.fill")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(server.type == .vmess ? Color.blue.opacity(0.2) : Color.purple.opacity(0.2))
                                .cornerRadius(4)
                            
                            if let latency = server.latency {
                                Text("\(latency)ms")
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        Task { await appState.connect(to: server) }
                    }) {
                        Text(appState.currentServer?.id == server.id && appState.isConnected ? "Connected" : "Connect")
                            .frame(width: 100)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(appState.currentServer?.id == server.id && appState.isConnected)
                }
                
                Divider()
                
                // Server details
                GroupBox("Server Details") {
                    Grid(alignment: .leading, verticalSpacing: 12) {
                        GridRow {
                            Text("Address")
                                .foregroundColor(.secondary)
                            Text(server.address)
                                .textSelection(.enabled)
                        }
                        
                        GridRow {
                            Text("Port")
                                .foregroundColor(.secondary)
                            Text("\(server.port)")
                        }
                        
                        GridRow {
                            Text("Protocol")
                                .foregroundColor(.secondary)
                            Text(server.type.rawValue.uppercased())
                        }
                        
                        if let network = server.network {
                            GridRow {
                                Text("Network")
                                    .foregroundColor(.secondary)
                                Text(network)
                            }
                        }
                        
                        if let security = server.security {
                            GridRow {
                                Text("Security")
                                    .foregroundColor(.secondary)
                                Text(security)
                            }
                        }
                    }
                    .padding()
                }
                
                // Actions
                GroupBox("Actions") {
                    HStack(spacing: 16) {
                        Button(action: {
                            Task { await appState.testLatency(for: server) }
                        }) {
                            Label("Test Latency", systemImage: "speedometer")
                        }
                        
                        Button(action: {
                            copyShareLink()
                        }) {
                            Label("Copy Link", systemImage: "doc.on.doc")
                        }
                        
                        Button(action: {
                            showQRCode()
                        }) {
                            Label("Show QR", systemImage: "qrcode")
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding(24)
        }
    }
    
    func copyShareLink() {
        let link = ConfigParser.generateShareLink(from: server)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(link, forType: .string)
    }
    
    func showQRCode() {
        // TODO: Implement QR code display
    }
}

// MARK: - Import View
struct ImportView: View {
    @Binding var importText: String
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var appState: AppState
    @State private var importError: String?
    @State private var importedCount = 0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Import Server Configuration")
                .font(.headline)
            
            Text("Paste vmess:// or vless:// links, one per line")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            TextEditor(text: $importText)
                .font(.system(.body, design: .monospaced))
                .frame(height: 200)
                .border(Color.gray.opacity(0.3))
            
            HStack {
                Button("Paste from Clipboard") {
                    if let string = NSPasteboard.general.string(forType: .string) {
                        importText = string
                    }
                }
                
                Spacer()
                
                if let error = importError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if importedCount > 0 {
                    Text("Imported \(importedCount) servers")
                        .foregroundColor(.green)
                        .font(.caption)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Button("Import") {
                    performImport()
                }
                .keyboardShortcut(.return)
                .buttonStyle(.borderedProminent)
                .disabled(importText.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 500)
    }
    
    func performImport() {
        let lines = importText.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        importedCount = 0
        importError = nil
        
        for line in lines {
            if let config = ConfigParser.parse(line) {
                appState.addServer(config)
                importedCount += 1
            }
        }
        
        if importedCount == 0 {
            importError = "No valid configurations found"
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState.shared)
}
