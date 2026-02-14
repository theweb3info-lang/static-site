import Foundation
import SystemConfiguration

class ProxyManager {
    static let shared = ProxyManager()
    
    private var originalProxySettings: [String: Any]?
    private var activeNetworkService: String?
    
    private init() {}
    
    // MARK: - Public Methods
    
    func enableSystemProxy(httpPort: Int, socksPort: Int) {
        // Save current settings before modifying
        saveCurrentSettings()
        
        // Get active network services
        let services = getActiveNetworkServices()
        
        for service in services {
            setProxySettings(
                for: service,
                httpEnabled: true,
                httpPort: httpPort,
                socksEnabled: true,
                socksPort: socksPort
            )
        }
        
        print("System proxy enabled (HTTP: \(httpPort), SOCKS: \(socksPort))")
    }
    
    func disableSystemProxy() {
        let services = getActiveNetworkServices()
        
        for service in services {
            setProxySettings(
                for: service,
                httpEnabled: false,
                httpPort: 0,
                socksEnabled: false,
                socksPort: 0
            )
        }
        
        print("System proxy disabled")
    }
    
    func isSystemProxyEnabled() -> Bool {
        guard let service = getActiveNetworkServices().first else { return false }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        task.arguments = ["-getwebproxy", service]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        try? task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8) ?? ""
        
        return output.contains("Enabled: Yes")
    }
    
    // MARK: - Private Methods
    
    private func getActiveNetworkServices() -> [String] {
        var services: [String] = []
        
        // Get list of all network services
        let listTask = Process()
        listTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        listTask.arguments = ["-listallnetworkservices"]
        
        let listPipe = Pipe()
        listTask.standardOutput = listPipe
        
        try? listTask.run()
        listTask.waitUntilExit()
        
        let listData = listPipe.fileHandleForReading.readDataToEndOfFile()
        let listOutput = String(data: listData, encoding: .utf8) ?? ""
        
        let allServices = listOutput.components(separatedBy: "\n")
            .filter { !$0.isEmpty && !$0.contains("*") && !$0.contains("An asterisk") }
        
        // Check which services are active (have an IP address)
        for service in allServices {
            let infoTask = Process()
            infoTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
            infoTask.arguments = ["-getinfo", service]
            
            let infoPipe = Pipe()
            infoTask.standardOutput = infoPipe
            
            try? infoTask.run()
            infoTask.waitUntilExit()
            
            let infoData = infoPipe.fileHandleForReading.readDataToEndOfFile()
            let infoOutput = String(data: infoData, encoding: .utf8) ?? ""
            
            // Check if service has an IP address (is active)
            if infoOutput.contains("IP address:") && !infoOutput.contains("IP address: none") {
                services.append(service)
            }
        }
        
        // Fallback to common services if none detected
        if services.isEmpty {
            services = ["Wi-Fi", "Ethernet", "USB 10/100/1000 LAN"]
        }
        
        return services
    }
    
    private func setProxySettings(
        for service: String,
        httpEnabled: Bool,
        httpPort: Int,
        socksEnabled: Bool,
        socksPort: Int
    ) {
        let localhost = "127.0.0.1"
        
        // Set HTTP proxy
        let httpTask = Process()
        httpTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        if httpEnabled {
            httpTask.arguments = ["-setwebproxy", service, localhost, String(httpPort)]
        } else {
            httpTask.arguments = ["-setwebproxystate", service, "off"]
        }
        try? httpTask.run()
        httpTask.waitUntilExit()
        
        // Set HTTPS proxy
        let httpsTask = Process()
        httpsTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        if httpEnabled {
            httpsTask.arguments = ["-setsecurewebproxy", service, localhost, String(httpPort)]
        } else {
            httpsTask.arguments = ["-setsecurewebproxystate", service, "off"]
        }
        try? httpsTask.run()
        httpsTask.waitUntilExit()
        
        // Set SOCKS proxy
        let socksTask = Process()
        socksTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        if socksEnabled {
            socksTask.arguments = ["-setsocksfirewallproxy", service, localhost, String(socksPort)]
        } else {
            socksTask.arguments = ["-setsocksfirewallproxystate", service, "off"]
        }
        try? socksTask.run()
        socksTask.waitUntilExit()
        
        // Set bypass domains
        if httpEnabled || socksEnabled {
            let bypassTask = Process()
            bypassTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
            bypassTask.arguments = [
                "-setproxybypassdomains", service,
                "localhost", "127.0.0.1", "*.local", "10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"
            ]
            try? bypassTask.run()
            bypassTask.waitUntilExit()
        }
    }
    
    private func saveCurrentSettings() {
        // Save current proxy settings to restore later if needed
        guard let service = getActiveNetworkServices().first else { return }
        
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
        task.arguments = ["-getwebproxy", service]
        
        let pipe = Pipe()
        task.standardOutput = pipe
        
        try? task.run()
        task.waitUntilExit()
        
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        if let output = String(data: data, encoding: .utf8) {
            originalProxySettings = parseProxyOutput(output)
            activeNetworkService = service
        }
    }
    
    private func parseProxyOutput(_ output: String) -> [String: Any] {
        var settings: [String: Any] = [:]
        
        for line in output.components(separatedBy: "\n") {
            let parts = line.components(separatedBy: ": ")
            if parts.count == 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1].trimmingCharacters(in: .whitespaces)
                settings[key] = value
            }
        }
        
        return settings
    }
}

// MARK: - PAC File Support

extension ProxyManager {
    func enablePACProxy(pacURL: String) {
        let services = getActiveNetworkServices()
        
        for service in services {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
            task.arguments = ["-setautoproxyurl", service, pacURL]
            try? task.run()
            task.waitUntilExit()
            
            // Enable auto proxy
            let enableTask = Process()
            enableTask.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
            enableTask.arguments = ["-setautoproxystate", service, "on"]
            try? enableTask.run()
            enableTask.waitUntilExit()
        }
    }
    
    func disablePACProxy() {
        let services = getActiveNetworkServices()
        
        for service in services {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/networksetup")
            task.arguments = ["-setautoproxystate", service, "off"]
            try? task.run()
            task.waitUntilExit()
        }
    }
}
