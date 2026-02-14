//
//  Settings.swift
//  ScreenshotPro
//
//  Application settings management
//

import SwiftUI
import ServiceManagement

// MARK: - Settings Manager

/// 设置管理器 - 单例模式
@MainActor
class SettingsManager: ObservableObject {
    static let shared = SettingsManager()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - General Settings
    
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: "launchAtLogin")
            updateLaunchAtLogin()
        }
    }
    
    @Published var hideFromDock: Bool {
        didSet {
            defaults.set(hideFromDock, forKey: "hideFromDock")
            updateDockVisibility()
        }
    }
    
    @Published var playCaptureSound: Bool {
        didSet {
            defaults.set(playCaptureSound, forKey: "playCaptureSound")
        }
    }
    
    @Published var showInMenuBar: Bool {
        didSet {
            defaults.set(showInMenuBar, forKey: "showInMenuBar")
        }
    }
    
    // MARK: - Capture Settings
    
    @Published var copyToClipboard: Bool {
        didSet {
            defaults.set(copyToClipboard, forKey: "copyToClipboard")
        }
    }
    
    @Published var afterCaptureAction: AfterCaptureAction {
        didSet {
            defaults.set(afterCaptureAction.rawValue, forKey: "afterCaptureAction")
        }
    }
    
    @Published var saveFolder: URL {
        didSet {
            defaults.set(saveFolder.path, forKey: "saveFolder")
        }
    }
    
    @Published var imageFormat: ImageFormat {
        didSet {
            defaults.set(imageFormat.rawValue, forKey: "imageFormat")
        }
    }
    
    @Published var jpegQuality: Double {
        didSet {
            defaults.set(jpegQuality, forKey: "jpegQuality")
        }
    }
    
    @Published var includeWindowShadow: Bool {
        didSet {
            defaults.set(includeWindowShadow, forKey: "includeWindowShadow")
        }
    }
    
    @Published var captureMouseCursor: Bool {
        didSet {
            defaults.set(captureMouseCursor, forKey: "captureMouseCursor")
        }
    }
    
    // MARK: - Hotkey Settings
    
    @Published var regionHotkey: HotkeyConfig {
        didSet {
            saveHotkey(regionHotkey, forKey: "regionHotkey")
        }
    }
    
    @Published var windowHotkey: HotkeyConfig {
        didSet {
            saveHotkey(windowHotkey, forKey: "windowHotkey")
        }
    }
    
    @Published var fullscreenHotkey: HotkeyConfig {
        didSet {
            saveHotkey(fullscreenHotkey, forKey: "fullscreenHotkey")
        }
    }
    
    @Published var menuHotkey: HotkeyConfig {
        didSet {
            saveHotkey(menuHotkey, forKey: "menuHotkey")
        }
    }
    
    // MARK: - Annotation Settings
    
    @Published var defaultAnnotationColor: Color {
        didSet {
            saveColor(defaultAnnotationColor, forKey: "defaultAnnotationColor")
        }
    }
    
    @Published var defaultStrokeWidth: CGFloat {
        didSet {
            defaults.set(defaultStrokeWidth, forKey: "defaultStrokeWidth")
        }
    }
    
    @Published var defaultFontSize: CGFloat {
        didSet {
            defaults.set(defaultFontSize, forKey: "defaultFontSize")
        }
    }
    
    // MARK: - Beautify Settings
    
    @Published var defaultBeautifySettings: BeautifySettings {
        didSet {
            if let data = try? JSONEncoder().encode(defaultBeautifySettings) {
                defaults.set(data, forKey: "defaultBeautifySettings")
            }
        }
    }
    
    // MARK: - History Settings
    
    @Published var maxHistoryItems: Int {
        didSet {
            defaults.set(maxHistoryItems, forKey: "maxHistoryItems")
        }
    }
    
    @Published var historyRetentionDays: Int {
        didSet {
            defaults.set(historyRetentionDays, forKey: "historyRetentionDays")
        }
    }
    
    // MARK: - Initialization
    
    private init() {
        // General
        self.launchAtLogin = defaults.bool(forKey: "launchAtLogin")
        self.hideFromDock = defaults.bool(forKey: "hideFromDock")
        self.playCaptureSound = defaults.object(forKey: "playCaptureSound") as? Bool ?? true
        self.showInMenuBar = defaults.object(forKey: "showInMenuBar") as? Bool ?? true
        
        // Capture
        self.copyToClipboard = defaults.object(forKey: "copyToClipboard") as? Bool ?? true
        
        if let actionString = defaults.string(forKey: "afterCaptureAction"),
           let action = AfterCaptureAction(rawValue: actionString) {
            self.afterCaptureAction = action
        } else {
            self.afterCaptureAction = .showEditor
        }
        
        if let folderPath = defaults.string(forKey: "saveFolder") {
            self.saveFolder = URL(fileURLWithPath: folderPath)
        } else {
            self.saveFolder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        }
        
        if let formatString = defaults.string(forKey: "imageFormat"),
           let format = ImageFormat(rawValue: formatString) {
            self.imageFormat = format
        } else {
            self.imageFormat = .png
        }
        
        self.jpegQuality = defaults.object(forKey: "jpegQuality") as? Double ?? 0.9
        self.includeWindowShadow = defaults.object(forKey: "includeWindowShadow") as? Bool ?? true
        self.captureMouseCursor = defaults.bool(forKey: "captureMouseCursor")
        
        // Hotkeys
        self.regionHotkey = SettingsManager.loadHotkey(forKey: "regionHotkey") ?? HotkeyConfig(keyCode: 21, modifiers: [.command, .shift])
        self.windowHotkey = SettingsManager.loadHotkey(forKey: "windowHotkey") ?? HotkeyConfig(keyCode: 23, modifiers: [.command, .shift])
        self.fullscreenHotkey = SettingsManager.loadHotkey(forKey: "fullscreenHotkey") ?? HotkeyConfig(keyCode: 20, modifiers: [.command, .shift])
        self.menuHotkey = SettingsManager.loadHotkey(forKey: "menuHotkey") ?? HotkeyConfig(keyCode: 22, modifiers: [.command, .shift])
        
        // Annotation
        self.defaultAnnotationColor = SettingsManager.loadColor(forKey: "defaultAnnotationColor") ?? .red
        self.defaultStrokeWidth = CGFloat(defaults.object(forKey: "defaultStrokeWidth") as? Double ?? 3.0)
        self.defaultFontSize = CGFloat(defaults.object(forKey: "defaultFontSize") as? Double ?? 16.0)
        
        // Beautify
        if let data = defaults.data(forKey: "defaultBeautifySettings"),
           let settings = try? JSONDecoder().decode(BeautifySettings.self, from: data) {
            self.defaultBeautifySettings = settings
        } else {
            self.defaultBeautifySettings = BeautifySettings()
        }
        
        // History
        self.maxHistoryItems = defaults.object(forKey: "maxHistoryItems") as? Int ?? 100
        self.historyRetentionDays = defaults.object(forKey: "historyRetentionDays") as? Int ?? 30
    }
    
    // MARK: - Helper Methods
    
    private func updateLaunchAtLogin() {
        if #available(macOS 13.0, *) {
            do {
                if launchAtLogin {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }
    
    private func updateDockVisibility() {
        if hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    private func saveHotkey(_ hotkey: HotkeyConfig, forKey key: String) {
        if let data = try? JSONEncoder().encode(hotkey) {
            defaults.set(data, forKey: key)
        }
    }
    
    private static func loadHotkey(forKey key: String) -> HotkeyConfig? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(HotkeyConfig.self, from: data)
    }
    
    private func saveColor(_ color: Color, forKey key: String) {
        let nsColor = NSColor(color)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: nsColor, requiringSecureCoding: false) {
            defaults.set(data, forKey: key)
        }
    }
    
    private static func loadColor(forKey key: String) -> Color? {
        guard let data = UserDefaults.standard.data(forKey: key),
              let nsColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSColor.self, from: data) else {
            return nil
        }
        return Color(nsColor)
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        launchAtLogin = false
        hideFromDock = false
        playCaptureSound = true
        showInMenuBar = true
        copyToClipboard = true
        afterCaptureAction = .showEditor
        saveFolder = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
        imageFormat = .png
        jpegQuality = 0.9
        includeWindowShadow = true
        captureMouseCursor = false
        defaultAnnotationColor = .red
        defaultStrokeWidth = 3.0
        defaultFontSize = 16.0
        defaultBeautifySettings = BeautifySettings()
        maxHistoryItems = 100
        historyRetentionDays = 30
    }
}

// MARK: - Supporting Types

enum AfterCaptureAction: String, CaseIterable, Identifiable {
    case showEditor = "Open in Editor"
    case saveToFolder = "Save to Folder"
    case copyOnly = "Copy to Clipboard Only"
    
    var id: String { rawValue }
}

enum ImageFormat: String, CaseIterable, Identifiable {
    case png = "PNG"
    case jpeg = "JPEG"
    case tiff = "TIFF"
    case heic = "HEIC"
    
    var id: String { rawValue }
    
    var fileExtension: String {
        switch self {
        case .png: return "png"
        case .jpeg: return "jpg"
        case .tiff: return "tiff"
        case .heic: return "heic"
        }
    }
}

// MARK: - Hotkey Configuration

struct HotkeyConfig: Codable, Equatable {
    var keyCode: UInt32
    var modifiers: Set<HotkeyModifier>
    
    var displayString: String {
        var parts: [String] = []
        if modifiers.contains(.control) { parts.append("⌃") }
        if modifiers.contains(.option) { parts.append("⌥") }
        if modifiers.contains(.shift) { parts.append("⇧") }
        if modifiers.contains(.command) { parts.append("⌘") }
        parts.append(keyCodeToString(keyCode))
        return parts.joined()
    }
    
    private func keyCodeToString(_ code: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            31: "O", 32: "U", 34: "I", 35: "P", 37: "L", 38: "J", 40: "K",
            45: "N", 46: "M",
            // Function keys
            122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
            98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12"
        ]
        return keyMap[code] ?? "?"
    }
}

enum HotkeyModifier: String, Codable, Hashable {
    case command
    case shift
    case option
    case control
}
