import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTab = "general"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
            
            ProxySettingsView()
                .tabItem {
                    Label("Proxy", systemImage: "network")
                }
                .tag("proxy")
            
            SubscriptionSettingsView()
                .tabItem {
                    Label("Subscriptions", systemImage: "link")
                }
                .tag("subscriptions")
            
            AboutView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag("about")
        }
        .padding(20)
        .frame(width: 500, height: 400)
    }
}

// MARK: - Xray Core Status View

struct XrayCoreStatusView: View {
    @State private var isInstalled = false
    @State private var isChecking = true
    
    var body: some View {
        HStack {
            if isChecking {
                ProgressView()
                    .scaleEffect(0.5)
            } else if isInstalled {
                Text("Installed")
                    .foregroundColor(.green)
            } else {
                Text("Not Found")
                    .foregroundColor(.red)
            }
        }
        .task {
            isInstalled = await XrayCore.shared.isXrayInstalled()
            isChecking = false
        }
    }
}

// MARK: - General Settings

struct GeneralSettingsView: View {
    @EnvironmentObject var appState: AppState
    @AppStorage("launchAtLogin") var launchAtLogin = false
    @AppStorage("autoConnect") var autoConnect = false
    @AppStorage("showInDock") var showInDock = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Launch at Login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { newValue in
                        LaunchAtLogin.isEnabled = newValue
                    }
                
                Toggle("Auto Connect on Launch", isOn: $autoConnect)
                
                Toggle("Show in Dock", isOn: $showInDock)
                    .help("Restart app to apply")
            }
            
            Section("Xray Core") {
                HStack {
                    Text("Status:")
                    Spacer()
                    XrayCoreStatusView()
                }
                
                Button("Install/Update Xray Core") {
                    Task {
                        try? await XrayCore.installXray()
                    }
                }
            }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Proxy Settings

struct ProxySettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var httpPort: String = ""
    @State private var socksPort: String = ""
    
    var body: some View {
        Form {
            Section("Local Proxy") {
                HStack {
                    Text("HTTP Port:")
                    TextField("1087", text: $httpPort)
                        .frame(width: 100)
                }
                
                HStack {
                    Text("SOCKS Port:")
                    TextField("1080", text: $socksPort)
                        .frame(width: 100)
                }
                
                Button("Apply") {
                    if let http = Int(httpPort) {
                        appState.httpPort = http
                    }
                    if let socks = Int(socksPort) {
                        appState.socksPort = socks
                    }
                    
                    // Reconnect if connected
                    if appState.isConnected {
                        Task { await appState.reconnect() }
                    }
                }
            }
            
            Section("System Proxy") {
                Toggle("Enable System Proxy", isOn: $appState.enableSystemProxy)
                    .help("Automatically configure system proxy when connected")
                
                Text("Bypass: localhost, 127.0.0.1, *.local, LAN")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .formStyle(.grouped)
        .onAppear {
            httpPort = String(appState.httpPort)
            socksPort = String(appState.socksPort)
        }
    }
}

// MARK: - Subscription Settings

struct SubscriptionSettingsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showAddSubscription = false
    @State private var newSubName = ""
    @State private var newSubURL = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Subscriptions")
                    .font(.headline)
                Spacer()
                Button(action: { showAddSubscription.toggle() }) {
                    Image(systemName: "plus")
                }
            }
            
            if appState.subscriptions.isEmpty {
                VStack {
                    Image(systemName: "link.badge.plus")
                        .font(.largeTitle)
                        .foregroundColor(.secondary)
                    Text("No subscriptions")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(appState.subscriptions) { sub in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(sub.name)
                                    .fontWeight(.medium)
                                Text("\(sub.serverCount) servers")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                if let lastUpdated = sub.lastUpdated {
                                    Text("Updated: \(lastUpdated, style: .relative)")
                                        .font(.caption2)
                                        .foregroundColor(.gray.opacity(0.6))
                                }
                            }
                            
                            Spacer()
                            
                            if sub.isUpdating {
                                ProgressView()
                                    .scaleEffect(0.6)
                            } else {
                                Button(action: {
                                    Task { await appState.updateSubscription(sub) }
                                }) {
                                    Image(systemName: "arrow.clockwise")
                                }
                                .buttonStyle(.borderless)
                            }
                            
                            Button(action: {
                                appState.deleteSubscription(sub)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            
            Button("Update All") {
                Task { await appState.updateAllSubscriptions() }
            }
            .disabled(appState.subscriptions.isEmpty)
        }
        .sheet(isPresented: $showAddSubscription) {
            VStack(spacing: 16) {
                Text("Add Subscription")
                    .font(.headline)
                
                TextField("Name", text: $newSubName)
                TextField("URL", text: $newSubURL)
                
                HStack {
                    Button("Cancel") {
                        showAddSubscription = false
                        newSubName = ""
                        newSubURL = ""
                    }
                    
                    Spacer()
                    
                    Button("Add") {
                        let subscription = Subscription(
                            name: newSubName,
                            url: newSubURL
                        )
                        appState.addSubscription(subscription)
                        showAddSubscription = false
                        newSubName = ""
                        newSubURL = ""
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(newSubName.isEmpty || newSubURL.isEmpty)
                }
            }
            .padding(24)
            .frame(width: 400)
        }
    }
}

// MARK: - About View

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "network.badge.shield.half.filled")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)
            
            Text("V2Ray Client")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Version 1.0.0")
                .foregroundColor(.secondary)
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Link("GitHub Repository", destination: URL(string: "https://github.com/XTLS/Xray-core")!)
                Link("Xray-core Documentation", destination: URL(string: "https://xtls.github.io/")!)
            }
            
            Spacer()
            
            Text("Built with Swift & SwiftUI")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.6))
        }
        .padding()
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState.shared)
}
