import Foundation

class SubscriptionManager {
    static let shared = SubscriptionManager()
    
    private init() {}
    
    // MARK: - Fetch Servers from Subscription
    
    func fetchServers(from url: String) async throws -> [ServerConfig] {
        guard let subscriptionURL = URL(string: url) else {
            throw SubscriptionError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: subscriptionURL)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw SubscriptionError.fetchFailed
        }
        
        guard let content = String(data: data, encoding: .utf8) else {
            throw SubscriptionError.invalidData
        }
        
        return parseSubscriptionContent(content)
    }
    
    // MARK: - Parse Subscription Content
    
    private func parseSubscriptionContent(_ content: String) -> [ServerConfig] {
        var servers: [ServerConfig] = []
        
        // Try to decode as Base64 first
        let decodedContent: String
        if let decoded = decodeBase64(content.trimmingCharacters(in: .whitespacesAndNewlines)) {
            decodedContent = decoded
        } else {
            decodedContent = content
        }
        
        // Split by newlines and parse each line
        let lines = decodedContent.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        
        for line in lines {
            if let config = ConfigParser.parse(line) {
                servers.append(config)
            }
        }
        
        return servers
    }
    
    // MARK: - Base64 Decoding
    
    private func decodeBase64(_ string: String) -> String? {
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

// MARK: - Errors

enum SubscriptionError: LocalizedError {
    case invalidURL
    case fetchFailed
    case invalidData
    case parseError(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid subscription URL"
        case .fetchFailed:
            return "Failed to fetch subscription"
        case .invalidData:
            return "Invalid subscription data"
        case .parseError(let message):
            return "Parse error: \(message)"
        }
    }
}
