import Foundation

class TrafficMonitor {
    typealias TrafficCallback = (Int64, Int64) -> Void
    
    private var timer: Timer?
    private var callback: TrafficCallback
    private var lastUpload: Int64 = 0
    private var lastDownload: Int64 = 0
    
    init(callback: @escaping TrafficCallback) {
        self.callback = callback
    }
    
    deinit {
        stop()
    }
    
    // MARK: - Control
    
    func start() {
        stop() // Stop existing timer
        
        lastUpload = 0
        lastDownload = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateTraffic()
        }
        
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Traffic Reading
    
    private func updateTraffic() {
        // Read network statistics from system
        // This is a simplified version - for accurate stats, you'd need to query xray's API
        
        let stats = getNetworkStats()
        
        callback(stats.upload, stats.download)
    }
    
    private func getNetworkStats() -> (upload: Int64, download: Int64) {
        // Use netstat or similar to get network statistics
        // This is a placeholder - real implementation would use xray's stats API
        
        var upload: Int64 = 0
        var download: Int64 = 0
        
        // Read from /proc/net/dev equivalent on macOS
        // Using netstat for now
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/netstat")
        task.arguments = ["-ib"]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        do {
            try task.run()
            task.waitUntilExit()
            
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // Parse netstat output
                let lines = output.components(separatedBy: "\n")
                for line in lines {
                    // Look for lo0 interface (loopback) which is used by proxy
                    if line.contains("lo0") && !line.contains("Name") {
                        let parts = line.split(separator: " ").map(String.init)
                        if parts.count >= 10 {
                            // Ibytes is at index 6, Obytes at index 9 typically
                            if let inBytes = Int64(parts[6]) {
                                download = inBytes - lastDownload
                                lastDownload = inBytes
                            }
                            if let outBytes = Int64(parts[9]) {
                                upload = outBytes - lastUpload
                                lastUpload = outBytes
                            }
                        }
                        break
                    }
                }
            }
        } catch {
            // Ignore errors
        }
        
        return (upload, download)
    }
}

// MARK: - Xray Stats API

extension TrafficMonitor {
    /// Query Xray's gRPC stats API for accurate traffic data
    /// This requires enabling the stats API in Xray config
    func queryXrayStats(apiPort: Int) async -> (upload: Int64, download: Int64)? {
        // Xray stats API endpoint
        // This would need to be implemented using gRPC or the built-in stats handler
        
        // For now, return nil to use fallback method
        return nil
    }
}

// MARK: - Bandwidth Formatting

extension TrafficMonitor {
    static func formatBytes(_ bytes: Int64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        return formatter.string(fromByteCount: bytes)
    }
    
    static func formatSpeed(_ bytesPerSecond: Int64) -> String {
        let formatted = formatBytes(bytesPerSecond)
        return "\(formatted)/s"
    }
}
