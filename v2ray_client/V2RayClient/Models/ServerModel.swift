import Foundation

// MARK: - Protocol Type
enum ProtocolType: String, Codable, CaseIterable {
    case vmess = "vmess"
    case vless = "vless"
}

// MARK: - Server Configuration
struct ServerConfig: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var address: String
    var port: Int
    var type: ProtocolType
    
    // Common fields
    var uuid: String
    var alterId: Int?  // VMess only
    var encryption: String?  // VMess: auto, aes-128-gcm, etc. VLESS: none
    var flow: String?  // VLESS only
    
    // Transport settings
    var network: String?  // tcp, ws, grpc, http, quic
    var security: String?  // none, tls, reality
    
    // TLS settings
    var sni: String?
    var fingerprint: String?
    var alpn: String?
    var allowInsecure: Bool?
    
    // WebSocket settings
    var wsPath: String?
    var wsHost: String?
    
    // gRPC settings
    var grpcServiceName: String?
    var grpcMode: String?
    
    // HTTP settings
    var httpPath: String?
    var httpHost: String?
    
    // Reality settings (VLESS)
    var realityPublicKey: String?
    var realityShortId: String?
    var realitySpiderX: String?
    
    // Runtime state (not persisted)
    var latency: Int?
    var isTesting: Bool = false
    var subscriptionId: UUID?
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        port: Int,
        type: ProtocolType,
        uuid: String,
        alterId: Int? = nil,
        encryption: String? = nil,
        flow: String? = nil,
        network: String? = "tcp",
        security: String? = "none",
        sni: String? = nil,
        fingerprint: String? = nil,
        alpn: String? = nil,
        allowInsecure: Bool? = nil,
        wsPath: String? = nil,
        wsHost: String? = nil,
        grpcServiceName: String? = nil,
        grpcMode: String? = nil,
        httpPath: String? = nil,
        httpHost: String? = nil,
        realityPublicKey: String? = nil,
        realityShortId: String? = nil,
        realitySpiderX: String? = nil
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.port = port
        self.type = type
        self.uuid = uuid
        self.alterId = alterId
        self.encryption = encryption
        self.flow = flow
        self.network = network
        self.security = security
        self.sni = sni
        self.fingerprint = fingerprint
        self.alpn = alpn
        self.allowInsecure = allowInsecure
        self.wsPath = wsPath
        self.wsHost = wsHost
        self.grpcServiceName = grpcServiceName
        self.grpcMode = grpcMode
        self.httpPath = httpPath
        self.httpHost = httpHost
        self.realityPublicKey = realityPublicKey
        self.realityShortId = realityShortId
        self.realitySpiderX = realitySpiderX
    }
    
    // Codable conformance - exclude runtime state
    enum CodingKeys: String, CodingKey {
        case id, name, address, port, type, uuid, alterId, encryption, flow
        case network, security, sni, fingerprint, alpn, allowInsecure
        case wsPath, wsHost, grpcServiceName, grpcMode, httpPath, httpHost
        case realityPublicKey, realityShortId, realitySpiderX, subscriptionId
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ServerConfig, rhs: ServerConfig) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Subscription
struct Subscription: Identifiable, Codable {
    let id: UUID
    var name: String
    var url: String
    var lastUpdated: Date?
    var autoUpdate: Bool
    var updateInterval: TimeInterval  // in seconds
    var serverCount: Int
    var isUpdating: Bool = false
    
    init(
        id: UUID = UUID(),
        name: String,
        url: String,
        lastUpdated: Date? = nil,
        autoUpdate: Bool = true,
        updateInterval: TimeInterval = 86400,  // 24 hours
        serverCount: Int = 0
    ) {
        self.id = id
        self.name = name
        self.url = url
        self.lastUpdated = lastUpdated
        self.autoUpdate = autoUpdate
        self.updateInterval = updateInterval
        self.serverCount = serverCount
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, url, lastUpdated, autoUpdate, updateInterval, serverCount
    }
}

// MARK: - Xray Configuration
struct XrayConfig: Codable {
    var log: LogConfig
    var inbounds: [Inbound]
    var outbounds: [Outbound]
    var routing: RoutingConfig?
    
    struct LogConfig: Codable {
        var loglevel: String
        var access: String?
        var error: String?
    }
    
    struct Inbound: Codable {
        var tag: String
        var port: Int
        var listen: String
        var `protocol`: String
        var settings: InboundSettings?
        var sniffing: SniffingConfig?
        
        struct InboundSettings: Codable {
            var auth: String?
            var udp: Bool?
        }
        
        struct SniffingConfig: Codable {
            var enabled: Bool
            var destOverride: [String]
        }
    }
    
    struct Outbound: Codable {
        var tag: String
        var `protocol`: String
        var settings: OutboundSettings?
        var streamSettings: StreamSettings?
        
        struct OutboundSettings: Codable {
            var vnext: [VNext]?
            
            struct VNext: Codable {
                var address: String
                var port: Int
                var users: [User]
                
                struct User: Codable {
                    var id: String
                    var alterId: Int?
                    var security: String?
                    var encryption: String?
                    var flow: String?
                }
            }
        }
        
        struct StreamSettings: Codable {
            var network: String
            var security: String?
            var tlsSettings: TLSSettings?
            var realitySettings: RealitySettings?
            var wsSettings: WebSocketSettings?
            var grpcSettings: GRPCSettings?
            var httpSettings: HTTPSettings?
            
            struct TLSSettings: Codable {
                var serverName: String?
                var fingerprint: String?
                var alpn: [String]?
                var allowInsecure: Bool?
            }
            
            struct RealitySettings: Codable {
                var serverName: String?
                var fingerprint: String?
                var publicKey: String?
                var shortId: String?
                var spiderX: String?
            }
            
            struct WebSocketSettings: Codable {
                var path: String?
                var headers: [String: String]?
            }
            
            struct GRPCSettings: Codable {
                var serviceName: String?
                var multiMode: Bool?
            }
            
            struct HTTPSettings: Codable {
                var path: String?
                var host: [String]?
            }
        }
    }
    
    struct RoutingConfig: Codable {
        var domainStrategy: String?
        var rules: [Rule]?
        
        struct Rule: Codable {
            var type: String
            var outboundTag: String
            var domain: [String]?
            var ip: [String]?
        }
    }
}
