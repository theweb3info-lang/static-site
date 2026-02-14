import Foundation
import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    // MARK: - Published Properties
    @Published var servers: [ServerConfig] = []
    @Published var subscriptions: [Subscription] = []
    @Published var currentServer: ServerConfig?
    @Published var isConnected = false
    @Published var isConnecting = false
    @Published var uploadBytes: Int64 = 0
    @Published var downloadBytes: Int64 = 0
    
    // MARK: - Settings
    @AppStorage("httpPort") var httpPort: Int = 1087
    @AppStorage("socksPort") var socksPort: Int = 1080
    @AppStorage("enableSystemProxy") var enableSystemProxy: Bool = true
    @AppStorage("autoConnect") var autoConnect: Bool = false
    @AppStorage("selectedServerId") var selectedServerId: String = ""
    
    // MARK: - Private
    private var trafficMonitor: TrafficMonitor?
    private var cancellables = Set<AnyCancellable>()
    
    private let serversKey = "savedServers"
    private let subscriptionsKey = "savedSubscriptions"
    
    private init() {
        loadServers()
        loadSubscriptions()
        setupTrafficMonitor()
    }
    
    // MARK: - Server Management
    
    func loadServers() {
        if let data = UserDefaults.standard.data(forKey: serversKey),
           let decoded = try? JSONDecoder().decode([ServerConfig].self, from: data) {
            servers = decoded
        }
    }
    
    func saveServers() {
        if let encoded = try? JSONEncoder().encode(servers) {
            UserDefaults.standard.set(encoded, forKey: serversKey)
        }
    }
    
    func addServer(_ server: ServerConfig) {
        servers.append(server)
        saveServers()
    }
    
    func updateServer(_ server: ServerConfig) {
        if let index = servers.firstIndex(where: { $0.id == server.id }) {
            servers[index] = server
            saveServers()
        }
    }
    
    func deleteServer(_ server: ServerConfig) {
        servers.removeAll { $0.id == server.id }
        saveServers()
    }
    
    func duplicateServer(_ server: ServerConfig) {
        var newServer = server
        newServer = ServerConfig(
            name: "\(server.name) (Copy)",
            address: server.address,
            port: server.port,
            type: server.type,
            uuid: server.uuid,
            alterId: server.alterId,
            encryption: server.encryption,
            flow: server.flow,
            network: server.network,
            security: server.security,
            sni: server.sni,
            fingerprint: server.fingerprint,
            alpn: server.alpn,
            allowInsecure: server.allowInsecure,
            wsPath: server.wsPath,
            wsHost: server.wsHost,
            grpcServiceName: server.grpcServiceName,
            grpcMode: server.grpcMode,
            httpPath: server.httpPath,
            httpHost: server.httpHost,
            realityPublicKey: server.realityPublicKey,
            realityShortId: server.realityShortId,
            realitySpiderX: server.realitySpiderX
        )
        addServer(newServer)
    }
    
    // MARK: - Subscription Management
    
    func loadSubscriptions() {
        if let data = UserDefaults.standard.data(forKey: subscriptionsKey),
           let decoded = try? JSONDecoder().decode([Subscription].self, from: data) {
            subscriptions = decoded
        }
    }
    
    func saveSubscriptions() {
        if let encoded = try? JSONEncoder().encode(subscriptions) {
            UserDefaults.standard.set(encoded, forKey: subscriptionsKey)
        }
    }
    
    func addSubscription(_ subscription: Subscription) {
        subscriptions.append(subscription)
        saveSubscriptions()
        Task {
            await updateSubscription(subscription)
        }
    }
    
    func deleteSubscription(_ subscription: Subscription) {
        // Remove servers from this subscription
        servers.removeAll { $0.subscriptionId == subscription.id }
        subscriptions.removeAll { $0.id == subscription.id }
        saveServers()
        saveSubscriptions()
    }
    
    func updateSubscription(_ subscription: Subscription) async {
        guard let index = subscriptions.firstIndex(where: { $0.id == subscription.id }) else { return }
        
        subscriptions[index].isUpdating = true
        
        do {
            let newServers = try await SubscriptionManager.shared.fetchServers(from: subscription.url)
            
            // Remove old servers from this subscription
            servers.removeAll { $0.subscriptionId == subscription.id }
            
            // Add new servers with subscription ID
            for var server in newServers {
                server.subscriptionId = subscription.id
                servers.append(server)
            }
            
            subscriptions[index].serverCount = newServers.count
            subscriptions[index].lastUpdated = Date()
            subscriptions[index].isUpdating = false
            
            saveServers()
            saveSubscriptions()
        } catch {
            print("Failed to update subscription: \(error)")
            subscriptions[index].isUpdating = false
        }
    }
    
    func updateAllSubscriptions() async {
        for subscription in subscriptions {
            await updateSubscription(subscription)
        }
    }
    
    // MARK: - Connection Management
    
    func connect(to server: ServerConfig) async {
        guard !isConnecting else { return }
        
        isConnecting = true
        
        // Disconnect first if already connected
        if isConnected {
            await disconnect()
        }
        
        do {
            // Generate Xray config
            let config = generateXrayConfig(for: server)
            
            // Start Xray core
            try await XrayCore.shared.start(with: config)
            
            // Set system proxy if enabled
            if enableSystemProxy {
                ProxyManager.shared.enableSystemProxy(httpPort: httpPort, socksPort: socksPort)
            }
            
            currentServer = server
            isConnected = true
            selectedServerId = server.id.uuidString
            
            // Start traffic monitoring
            trafficMonitor?.start()
            
        } catch {
            print("Connection failed: \(error)")
        }
        
        isConnecting = false
    }
    
    func disconnect() async {
        await XrayCore.shared.stop()
        
        if enableSystemProxy {
            ProxyManager.shared.disableSystemProxy()
        }
        
        trafficMonitor?.stop()
        
        isConnected = false
        currentServer = nil
        uploadBytes = 0
        downloadBytes = 0
    }
    
    func reconnect() async {
        if let server = currentServer {
            await disconnect()
            await connect(to: server)
        }
    }
    
    // MARK: - Latency Testing
    
    func testLatency(for server: ServerConfig) async {
        guard let index = servers.firstIndex(where: { $0.id == server.id }) else { return }
        
        servers[index].isTesting = true
        
        let latency = await LatencyTester.shared.test(server: server)
        
        servers[index].latency = latency
        servers[index].isTesting = false
        saveServers()
    }
    
    func testAllLatency() async {
        await withTaskGroup(of: Void.self) { group in
            for server in servers {
                group.addTask {
                    await self.testLatency(for: server)
                }
            }
        }
    }
    
    func selectFastestServer() async {
        await testAllLatency()
        
        if let fastest = servers.filter({ $0.latency != nil }).min(by: { ($0.latency ?? Int.max) < ($1.latency ?? Int.max) }) {
            await connect(to: fastest)
        }
    }
    
    // MARK: - Traffic Monitoring
    
    private func setupTrafficMonitor() {
        trafficMonitor = TrafficMonitor { [weak self] upload, download in
            Task { @MainActor in
                self?.uploadBytes = upload
                self?.downloadBytes = download
            }
        }
    }
    
    // MARK: - Config Generation
    
    private func generateXrayConfig(for server: ServerConfig) -> XrayConfig {
        var config = XrayConfig(
            log: .init(loglevel: "warning"),
            inbounds: [
                .init(
                    tag: "http",
                    port: httpPort,
                    listen: "127.0.0.1",
                    protocol: "http",
                    settings: .init(auth: "noauth", udp: nil),
                    sniffing: .init(enabled: true, destOverride: ["http", "tls"])
                ),
                .init(
                    tag: "socks",
                    port: socksPort,
                    listen: "127.0.0.1",
                    protocol: "socks",
                    settings: .init(auth: "noauth", udp: true),
                    sniffing: .init(enabled: true, destOverride: ["http", "tls"])
                )
            ],
            outbounds: [],
            routing: nil
        )
        
        // Build outbound based on server type
        var outbound = XrayConfig.Outbound(
            tag: "proxy",
            protocol: server.type.rawValue,
            settings: nil,
            streamSettings: nil
        )
        
        // User settings
        var user: XrayConfig.Outbound.OutboundSettings.VNext.User
        if server.type == .vmess {
            user = .init(
                id: server.uuid,
                alterId: server.alterId ?? 0,
                security: server.encryption ?? "auto",
                encryption: nil,
                flow: nil
            )
        } else {
            user = .init(
                id: server.uuid,
                alterId: nil,
                security: nil,
                encryption: server.encryption ?? "none",
                flow: server.flow
            )
        }
        
        outbound.settings = .init(
            vnext: [.init(
                address: server.address,
                port: server.port,
                users: [user]
            )]
        )
        
        // Stream settings
        var streamSettings = XrayConfig.Outbound.StreamSettings(
            network: server.network ?? "tcp",
            security: server.security ?? "none"
        )
        
        // TLS settings
        if server.security == "tls" {
            streamSettings.tlsSettings = .init(
                serverName: server.sni ?? server.address,
                fingerprint: server.fingerprint,
                alpn: server.alpn?.components(separatedBy: ","),
                allowInsecure: server.allowInsecure
            )
        }
        
        // Reality settings
        if server.security == "reality" {
            streamSettings.realitySettings = .init(
                serverName: server.sni,
                fingerprint: server.fingerprint ?? "chrome",
                publicKey: server.realityPublicKey,
                shortId: server.realityShortId,
                spiderX: server.realitySpiderX
            )
        }
        
        // WebSocket settings
        if server.network == "ws" {
            var headers: [String: String]?
            if let host = server.wsHost {
                headers = ["Host": host]
            }
            streamSettings.wsSettings = .init(
                path: server.wsPath ?? "/",
                headers: headers
            )
        }
        
        // gRPC settings
        if server.network == "grpc" {
            streamSettings.grpcSettings = .init(
                serviceName: server.grpcServiceName,
                multiMode: server.grpcMode == "multi"
            )
        }
        
        // HTTP settings
        if server.network == "http" || server.network == "h2" {
            streamSettings.httpSettings = .init(
                path: server.httpPath ?? "/",
                host: server.httpHost?.components(separatedBy: ",")
            )
        }
        
        outbound.streamSettings = streamSettings
        config.outbounds.append(outbound)
        
        // Add direct and block outbounds
        config.outbounds.append(.init(tag: "direct", protocol: "freedom", settings: nil, streamSettings: nil))
        config.outbounds.append(.init(tag: "block", protocol: "blackhole", settings: nil, streamSettings: nil))
        
        // Routing rules
        config.routing = .init(
            domainStrategy: "AsIs",
            rules: [
                .init(type: "field", outboundTag: "direct", domain: ["geosite:private"], ip: nil),
                .init(type: "field", outboundTag: "direct", domain: nil, ip: ["geoip:private"])
            ]
        )
        
        return config
    }
}
