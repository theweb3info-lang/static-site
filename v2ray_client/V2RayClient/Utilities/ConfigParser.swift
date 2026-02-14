import Foundation

class ConfigParser {
    
    // MARK: - Parse Share Link
    
    static func parse(_ link: String) -> ServerConfig? {
        let trimmed = link.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmed.hasPrefix("vmess://") {
            return parseVMess(trimmed)
        } else if trimmed.hasPrefix("vless://") {
            return parseVLESS(trimmed)
        }
        
        return nil
    }
    
    // MARK: - VMess Parser
    
    private static func parseVMess(_ link: String) -> ServerConfig? {
        // vmess:// links are base64 encoded JSON
        let base64Part = String(link.dropFirst("vmess://".count))
        
        guard let decoded = decodeBase64(base64Part),
              let data = decoded.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        guard let address = json["add"] as? String,
              let portValue = json["port"],
              let uuid = json["id"] as? String else {
            return nil
        }
        
        let port: Int
        if let portInt = portValue as? Int {
            port = portInt
        } else if let portString = portValue as? String, let portInt = Int(portString) {
            port = portInt
        } else {
            return nil
        }
        
        let name = (json["ps"] as? String) ?? "\(address):\(port)"
        let alterId = (json["aid"] as? Int) ?? Int(json["aid"] as? String ?? "0") ?? 0
        let network = (json["net"] as? String) ?? "tcp"
        let security = (json["tls"] as? String) == "tls" ? "tls" : "none"
        let encryption = (json["scy"] as? String) ?? "auto"
        
        var config = ServerConfig(
            name: name,
            address: address,
            port: port,
            type: .vmess,
            uuid: uuid,
            alterId: alterId,
            encryption: encryption,
            network: network,
            security: security
        )
        
        // SNI
        if let sni = json["sni"] as? String, !sni.isEmpty {
            config.sni = sni
        } else if let host = json["host"] as? String, !host.isEmpty {
            config.sni = host
        }
        
        // WebSocket
        if network == "ws" {
            config.wsPath = (json["path"] as? String) ?? "/"
            config.wsHost = json["host"] as? String
        }
        
        // gRPC
        if network == "grpc" {
            config.grpcServiceName = json["path"] as? String
            config.grpcMode = json["type"] as? String
        }
        
        // HTTP
        if network == "http" || network == "h2" {
            config.httpPath = json["path"] as? String
            config.httpHost = json["host"] as? String
        }
        
        // Fingerprint
        if let fp = json["fp"] as? String {
            config.fingerprint = fp
        }
        
        // ALPN
        if let alpn = json["alpn"] as? String {
            config.alpn = alpn
        }
        
        return config
    }
    
    // MARK: - VLESS Parser
    
    private static func parseVLESS(_ link: String) -> ServerConfig? {
        // vless://uuid@address:port?params#name
        guard var url = URLComponents(string: link) else { return nil }
        
        // Extract UUID from user part
        guard let uuid = url.user else { return nil }
        
        // Extract address and port
        guard let host = url.host,
              let port = url.port else { return nil }
        
        // Parse fragment as name
        let name = url.fragment?.removingPercentEncoding ?? "\(host):\(port)"
        
        // Parse query parameters
        var params: [String: String] = [:]
        if let queryItems = url.queryItems {
            for item in queryItems {
                if let value = item.value {
                    params[item.name] = value
                }
            }
        }
        
        var config = ServerConfig(
            name: name,
            address: host,
            port: port,
            type: .vless,
            uuid: uuid,
            encryption: params["encryption"] ?? "none",
            flow: params["flow"],
            network: params["type"] ?? "tcp",
            security: params["security"] ?? "none"
        )
        
        // TLS settings
        config.sni = params["sni"]
        config.fingerprint = params["fp"]
        config.alpn = params["alpn"]
        
        if let allowInsecure = params["allowInsecure"] {
            config.allowInsecure = allowInsecure == "1" || allowInsecure == "true"
        }
        
        // WebSocket
        if config.network == "ws" {
            config.wsPath = params["path"]?.removingPercentEncoding
            config.wsHost = params["host"]
        }
        
        // gRPC
        if config.network == "grpc" {
            config.grpcServiceName = params["serviceName"]
            config.grpcMode = params["mode"]
        }
        
        // HTTP/H2
        if config.network == "http" || config.network == "h2" {
            config.httpPath = params["path"]?.removingPercentEncoding
            config.httpHost = params["host"]
        }
        
        // Reality
        if config.security == "reality" {
            config.realityPublicKey = params["pbk"]
            config.realityShortId = params["sid"]
            config.realitySpiderX = params["spx"]?.removingPercentEncoding
        }
        
        return config
    }
    
    // MARK: - Generate Share Link
    
    static func generateShareLink(from config: ServerConfig) -> String {
        switch config.type {
        case .vmess:
            return generateVMessLink(from: config)
        case .vless:
            return generateVLESSLink(from: config)
        }
    }
    
    private static func generateVMessLink(from config: ServerConfig) -> String {
        var json: [String: Any] = [
            "v": "2",
            "ps": config.name,
            "add": config.address,
            "port": config.port,
            "id": config.uuid,
            "aid": config.alterId ?? 0,
            "scy": config.encryption ?? "auto",
            "net": config.network ?? "tcp",
            "type": "none"
        ]
        
        if config.security == "tls" {
            json["tls"] = "tls"
            if let sni = config.sni {
                json["sni"] = sni
            }
            if let fp = config.fingerprint {
                json["fp"] = fp
            }
            if let alpn = config.alpn {
                json["alpn"] = alpn
            }
        }
        
        if config.network == "ws" {
            json["path"] = config.wsPath ?? "/"
            if let host = config.wsHost {
                json["host"] = host
            }
        }
        
        if config.network == "grpc" {
            if let serviceName = config.grpcServiceName {
                json["path"] = serviceName
            }
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: json),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return ""
        }
        
        let base64 = jsonString.data(using: .utf8)?.base64EncodedString() ?? ""
        return "vmess://\(base64)"
    }
    
    private static func generateVLESSLink(from config: ServerConfig) -> String {
        var components = URLComponents()
        components.scheme = "vless"
        components.user = config.uuid
        components.host = config.address
        components.port = config.port
        
        var queryItems: [URLQueryItem] = []
        
        // Encryption
        queryItems.append(URLQueryItem(name: "encryption", value: config.encryption ?? "none"))
        
        // Flow
        if let flow = config.flow, !flow.isEmpty {
            queryItems.append(URLQueryItem(name: "flow", value: flow))
        }
        
        // Transport
        queryItems.append(URLQueryItem(name: "type", value: config.network ?? "tcp"))
        
        // Security
        queryItems.append(URLQueryItem(name: "security", value: config.security ?? "none"))
        
        // TLS settings
        if let sni = config.sni {
            queryItems.append(URLQueryItem(name: "sni", value: sni))
        }
        if let fp = config.fingerprint {
            queryItems.append(URLQueryItem(name: "fp", value: fp))
        }
        if let alpn = config.alpn {
            queryItems.append(URLQueryItem(name: "alpn", value: alpn))
        }
        
        // WebSocket
        if config.network == "ws" {
            if let path = config.wsPath {
                queryItems.append(URLQueryItem(name: "path", value: path))
            }
            if let host = config.wsHost {
                queryItems.append(URLQueryItem(name: "host", value: host))
            }
        }
        
        // gRPC
        if config.network == "grpc" {
            if let serviceName = config.grpcServiceName {
                queryItems.append(URLQueryItem(name: "serviceName", value: serviceName))
            }
            if let mode = config.grpcMode {
                queryItems.append(URLQueryItem(name: "mode", value: mode))
            }
        }
        
        // Reality
        if config.security == "reality" {
            if let pbk = config.realityPublicKey {
                queryItems.append(URLQueryItem(name: "pbk", value: pbk))
            }
            if let sid = config.realityShortId {
                queryItems.append(URLQueryItem(name: "sid", value: sid))
            }
            if let spx = config.realitySpiderX {
                queryItems.append(URLQueryItem(name: "spx", value: spx))
            }
        }
        
        components.queryItems = queryItems
        components.fragment = config.name
        
        return components.string ?? ""
    }
    
    // MARK: - Helper
    
    private static func decodeBase64(_ string: String) -> String? {
        // Standard Base64
        if let data = Data(base64Encoded: string),
           let decoded = String(data: data, encoding: .utf8) {
            return decoded
        }
        
        // URL-safe Base64
        var base64 = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if necessary
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        
        if let data = Data(base64Encoded: base64),
           let decoded = String(data: data, encoding: .utf8) {
            return decoded
        }
        
        return nil
    }
}
