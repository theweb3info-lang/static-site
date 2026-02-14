import Foundation
import Network

class LatencyTester {
    static let shared = LatencyTester()
    
    private let timeout: TimeInterval = 5.0
    
    private init() {}
    
    // MARK: - Test Latency
    
    func test(server: ServerConfig) async -> Int? {
        // Use TCP connection test for more accurate results
        return await testTCPConnection(host: server.address, port: server.port)
    }
    
    // MARK: - TCP Connection Test
    
    private func testTCPConnection(host: String, port: Int) async -> Int? {
        return await withCheckedContinuation { continuation in
            let startTime = Date()
            
            let endpoint = NWEndpoint.hostPort(
                host: NWEndpoint.Host(host),
                port: NWEndpoint.Port(integerLiteral: UInt16(port))
            )
            
            let parameters = NWParameters.tcp
            parameters.requiredInterfaceType = .other
            
            let connection = NWConnection(to: endpoint, using: parameters)
            
            var isCompleted = false
            let completionLock = NSLock()
            
            func complete(with result: Int?) {
                completionLock.lock()
                defer { completionLock.unlock() }
                
                guard !isCompleted else { return }
                isCompleted = true
                
                connection.cancel()
                continuation.resume(returning: result)
            }
            
            connection.stateUpdateHandler = { state in
                switch state {
                case .ready:
                    let latency = Int(Date().timeIntervalSince(startTime) * 1000)
                    complete(with: latency)
                    
                case .failed, .cancelled:
                    complete(with: nil)
                    
                default:
                    break
                }
            }
            
            connection.start(queue: .global())
            
            // Timeout
            DispatchQueue.global().asyncAfter(deadline: .now() + timeout) {
                complete(with: nil)
            }
        }
    }
    
    // MARK: - Batch Testing
    
    func testAll(servers: [ServerConfig]) async -> [UUID: Int] {
        var results: [UUID: Int] = [:]
        
        await withTaskGroup(of: (UUID, Int?).self) { group in
            for server in servers {
                group.addTask {
                    let latency = await self.test(server: server)
                    return (server.id, latency)
                }
            }
            
            for await (id, latency) in group {
                if let latency = latency {
                    results[id] = latency
                }
            }
        }
        
        return results
    }
    
    // MARK: - HTTP Test (Alternative)
    
    func testHTTP(server: ServerConfig, proxyPort: Int) async -> Int? {
        let startTime = Date()
        
        let config = URLSessionConfiguration.ephemeral
        config.connectionProxyDictionary = [
            kCFNetworkProxiesHTTPEnable: true,
            kCFNetworkProxiesHTTPPort: proxyPort,
            kCFNetworkProxiesHTTPProxy: "127.0.0.1"
        ]
        config.timeoutIntervalForRequest = timeout
        
        let session = URLSession(configuration: config)
        
        do {
            let url = URL(string: "http://www.gstatic.com/generate_204")!
            let (_, response) = try await session.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode == 204 {
                return Int(Date().timeIntervalSince(startTime) * 1000)
            }
        } catch {
            // Ignore errors
        }
        
        return nil
    }
}

// MARK: - Ping Utility

extension LatencyTester {
    func ping(host: String) async -> Int? {
        return await withCheckedContinuation { continuation in
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/sbin/ping")
            task.arguments = ["-c", "1", "-t", "3", host]
            
            let pipe = Pipe()
            task.standardOutput = pipe
            
            var isCompleted = false
            
            task.terminationHandler = { _ in
                guard !isCompleted else { return }
                isCompleted = true
                
                let data = pipe.fileHandleForReading.readDataToEndOfFile()
                let output = String(data: data, encoding: .utf8) ?? ""
                
                // Parse ping output for time
                if let range = output.range(of: "time="),
                   let endRange = output.range(of: " ms", range: range.upperBound..<output.endIndex) {
                    let timeStr = String(output[range.upperBound..<endRange.lowerBound])
                    if let time = Double(timeStr) {
                        continuation.resume(returning: Int(time))
                        return
                    }
                }
                
                continuation.resume(returning: nil)
            }
            
            do {
                try task.run()
            } catch {
                if !isCompleted {
                    isCompleted = true
                    continuation.resume(returning: nil)
                }
            }
        }
    }
}
