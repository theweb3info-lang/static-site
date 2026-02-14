import Foundation
import ServiceManagement

enum LaunchAtLogin {
    
    static var isEnabled: Bool {
        get {
            if #available(macOS 13.0, *) {
                return SMAppService.mainApp.status == .enabled
            } else {
                return legacyIsEnabled
            }
        }
        set {
            if #available(macOS 13.0, *) {
                do {
                    if newValue {
                        try SMAppService.mainApp.register()
                    } else {
                        try SMAppService.mainApp.unregister()
                    }
                } catch {
                    print("Failed to set launch at login: \(error)")
                }
            } else {
                legacySetEnabled(newValue)
            }
        }
    }
    
    // MARK: - Legacy Support (macOS 12 and earlier)
    
    @available(macOS, deprecated: 13.0)
    private static var legacyIsEnabled: Bool {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return false }
        
        // Check login items using deprecated API
        let jobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd).takeRetainedValue() as? [[String: Any]]
        
        return jobDicts?.contains { dict in
            guard let label = dict["Label"] as? String else { return false }
            return label == bundleIdentifier
        } ?? false
    }
    
    @available(macOS, deprecated: 13.0)
    private static func legacySetEnabled(_ enabled: Bool) {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return }
        
        // Use launchctl to manage login items
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        
        if enabled {
            // Create a launch agent plist
            let plistPath = createLaunchAgentPlist()
            task.arguments = ["load", plistPath]
        } else {
            let plistPath = launchAgentPlistPath
            task.arguments = ["unload", plistPath]
        }
        
        try? task.run()
        task.waitUntilExit()
    }
    
    private static var launchAgentPlistPath: String {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.v2rayclient.app"
        return NSHomeDirectory() + "/Library/LaunchAgents/\(bundleIdentifier).plist"
    }
    
    private static func createLaunchAgentPlist() -> String {
        let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.v2rayclient.app"
        let executablePath = Bundle.main.executablePath ?? ""
        
        let plist: [String: Any] = [
            "Label": bundleIdentifier,
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false
        ]
        
        let plistPath = launchAgentPlistPath
        
        // Ensure LaunchAgents directory exists
        let launchAgentsDir = NSHomeDirectory() + "/Library/LaunchAgents"
        try? FileManager.default.createDirectory(atPath: launchAgentsDir, withIntermediateDirectories: true)
        
        // Write plist
        let plistData = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? plistData?.write(to: URL(fileURLWithPath: plistPath))
        
        return plistPath
    }
}

// MARK: - Alternative: Login Items using AppleScript

extension LaunchAtLogin {
    
    /// Add to login items using AppleScript (works without special permissions)
    static func addToLoginItemsViaAppleScript() {
        guard let appPath = Bundle.main.bundlePath.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) else { return }
        
        let script = """
        tell application "System Events"
            make login item at end with properties {path:"\(Bundle.main.bundlePath)", hidden:false}
        end tell
        """
        
        runAppleScript(script)
    }
    
    /// Remove from login items using AppleScript
    static func removeFromLoginItemsViaAppleScript() {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return }
        
        let script = """
        tell application "System Events"
            delete login item "\(appName)"
        end tell
        """
        
        runAppleScript(script)
    }
    
    /// Check if in login items using AppleScript
    static func isInLoginItemsViaAppleScript() -> Bool {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else { return false }
        
        let script = """
        tell application "System Events"
            get the name of every login item
        end tell
        """
        
        guard let result = runAppleScript(script) else { return false }
        return result.contains(appName)
    }
    
    @discardableResult
    private static func runAppleScript(_ script: String) -> String? {
        var error: NSDictionary?
        if let scriptObject = NSAppleScript(source: script) {
            let result = scriptObject.executeAndReturnError(&error)
            if let error = error {
                print("AppleScript error: \(error)")
                return nil
            }
            return result.stringValue
        }
        return nil
    }
}
