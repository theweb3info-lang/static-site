import SwiftUI

@main
struct V2RayClientApp: App {
    @StateObject private var appState = AppState.shared
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        // Menu bar extra
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
        } label: {
            Image(systemName: appState.isConnected ? "network" : "network.slash")
        }
        .menuBarExtraStyle(.window)
        
        // Settings window
        Settings {
            SettingsView()
                .environmentObject(appState)
        }
        
        // Main window
        Window("V2Ray Client", id: "main") {
            ContentView()
                .environmentObject(appState)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 900, height: 600)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize xray-core path
        Task {
            await XrayCore.shared.initialize()
        }
        
        // Check for launch at login
        if LaunchAtLogin.isEnabled {
            print("App launched at login")
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup: disconnect and restore system proxy
        Task {
            await XrayCore.shared.stop()
            ProxyManager.shared.disableSystemProxy()
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false // Keep running in menu bar
    }
}
