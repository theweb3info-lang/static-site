import Foundation

actor XrayCore {
    static let shared = XrayCore()
    
    private var process: Process?
    private var isRunning = false
    private var xrayPath: String?
    private var configPath: String?
    
    private init() {}
    
    // MARK: - Initialization
    
    func initialize() {
        // Look for xray binary in common locations
        let possiblePaths = [
            Bundle.main.bundlePath + "/Contents/Resources/xray",
            Bundle.main.bundlePath + "/Contents/MacOS/xray",
            "/usr/local/bin/xray",
            "/opt/homebrew/bin/xray",
            NSHomeDirectory() + "/.local/bin/xray",
            NSHomeDirectory() + "/Library/Application Support/V2RayClient/xray"
        ]
        
        for path in possiblePaths {
            if FileManager.default.isExecutableFile(atPath: path) {
                xrayPath = path
                print("Found xray at: \(path)")
                break
            }
        }
        
        if xrayPath == nil {
            print("Warning: xray binary not found. Please install xray-core.")
        }
        
        // Setup config directory
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("V2RayClient")
        
        try? FileManager.default.createDirectory(at: supportDir, withIntermediateDirectories: true)
        configPath = supportDir.appendingPathComponent("config.json").path
    }
    
    // MARK: - Core Management
    
    func start(with config: XrayConfig) async throws {
        guard let xrayPath = xrayPath else {
            throw XrayCoreError.binaryNotFound
        }
        
        guard let configPath = configPath else {
            throw XrayCoreError.configError("Config path not set")
        }
        
        // Stop existing process
        await stop()
        
        // Write config file
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let configData = try encoder.encode(config)
        try configData.write(to: URL(fileURLWithPath: configPath))
        
        // Start xray process
        let process = Process()
        process.executableURL = URL(fileURLWithPath: xrayPath)
        process.arguments = ["run", "-c", configPath]
        
        // Setup pipes for output
        let outputPipe = Pipe()
        let errorPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = errorPipe
        
        // Handle output
        outputPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                print("[Xray] \(output)")
            }
        }
        
        errorPipe.fileHandleForReading.readabilityHandler = { handle in
            let data = handle.availableData
            if let output = String(data: data, encoding: .utf8), !output.isEmpty {
                print("[Xray Error] \(output)")
            }
        }
        
        // Set termination handler
        process.terminationHandler = { [weak self] process in
            Task {
                await self?.handleTermination(exitCode: process.terminationStatus)
            }
        }
        
        try process.run()
        
        self.process = process
        self.isRunning = true
        
        // Wait a bit to check if process started successfully
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        if !process.isRunning {
            throw XrayCoreError.startFailed("Process terminated immediately")
        }
        
        print("Xray started successfully (PID: \(process.processIdentifier))")
    }
    
    func stop() async {
        guard let process = process, isRunning else { return }
        
        process.terminate()
        
        // Wait for termination
        process.waitUntilExit()
        
        self.process = nil
        self.isRunning = false
        
        // Clean up config file
        if let configPath = configPath {
            try? FileManager.default.removeItem(atPath: configPath)
        }
        
        print("Xray stopped")
    }
    
    func restart(with config: XrayConfig) async throws {
        await stop()
        try await start(with: config)
    }
    
    private func handleTermination(exitCode: Int32) {
        isRunning = false
        if exitCode != 0 {
            print("Xray terminated with exit code: \(exitCode)")
        }
    }
    
    // MARK: - Status
    
    func getStatus() -> XrayCoreStatus {
        return XrayCoreStatus(
            isRunning: isRunning,
            pid: process?.processIdentifier,
            binaryPath: xrayPath
        )
    }
    
    func isXrayInstalled() -> Bool {
        return xrayPath != nil
    }
    
    // MARK: - API (for stats, etc.)
    
    func getStats() async throws -> XrayStats? {
        // TODO: Implement stats API call to xray
        return nil
    }
}

// MARK: - Types

struct XrayCoreStatus {
    let isRunning: Bool
    let pid: Int32?
    let binaryPath: String?
}

struct XrayStats {
    let uplink: Int64
    let downlink: Int64
}

enum XrayCoreError: LocalizedError {
    case binaryNotFound
    case configError(String)
    case startFailed(String)
    case alreadyRunning
    
    var errorDescription: String? {
        switch self {
        case .binaryNotFound:
            return "Xray binary not found. Please install xray-core."
        case .configError(let message):
            return "Configuration error: \(message)"
        case .startFailed(let message):
            return "Failed to start Xray: \(message)"
        case .alreadyRunning:
            return "Xray is already running"
        }
    }
}

// MARK: - Installation Helper

extension XrayCore {
    static func installXray() async throws {
        // Create install directory
        let installDir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("V2RayClient")
        
        try FileManager.default.createDirectory(at: installDir, withIntermediateDirectories: true)
        
        // Determine architecture
        #if arch(arm64)
        let arch = "arm64"
        #else
        let arch = "64"
        #endif
        
        let downloadURL = "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-macos-\(arch).zip"
        
        print("Downloading Xray from: \(downloadURL)")
        
        // Download
        let (zipURL, _) = try await URLSession.shared.download(from: URL(string: downloadURL)!)
        
        // Unzip
        let unzipDir = installDir.appendingPathComponent("xray-temp")
        try? FileManager.default.removeItem(at: unzipDir)
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = ["-o", zipURL.path, "-d", unzipDir.path]
        try process.run()
        process.waitUntilExit()
        
        // Move xray binary
        let xraySource = unzipDir.appendingPathComponent("xray")
        let xrayDest = installDir.appendingPathComponent("xray")
        
        try? FileManager.default.removeItem(at: xrayDest)
        try FileManager.default.moveItem(at: xraySource, to: xrayDest)
        
        // Make executable
        try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: xrayDest.path)
        
        // Cleanup
        try? FileManager.default.removeItem(at: unzipDir)
        try? FileManager.default.removeItem(at: zipURL)
        
        print("Xray installed successfully at: \(xrayDest.path)")
    }
}
