//
//  ScreenshotProApp.swift
//  ScreenshotPro
//
//  Professional screenshot tool for macOS
//  Copyright © 2024 ScreenshotPro. All rights reserved.
//

import SwiftUI
import ScreenCaptureKit

@main
struct ScreenshotProApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared
    @StateObject private var settingsManager = SettingsManager.shared
    
    var body: some Scene {
        // 设置窗口
        Settings {
            SettingsView()
                .environmentObject(settingsManager)
                .environmentObject(appState)
        }
        
        // 历史记录窗口
        WindowGroup("Screenshot History", id: "history") {
            HistoryView()
                .environmentObject(HistoryManager.shared)
                .environmentObject(appState)
                .frame(minWidth: 800, minHeight: 600)
        }
        .windowStyle(.automatic)
        .defaultSize(width: 1000, height: 700)
        
        // 编辑器窗口
        WindowGroup("Screenshot Editor", for: UUID.self) { $screenshotId in
            if let id = screenshotId,
               let screenshot = HistoryManager.shared.getScreenshot(by: id) {
                EditorView(screenshot: screenshot)
                    .environmentObject(appState)
                    .environmentObject(settingsManager)
            }
        }
        .windowStyle(.automatic)
        .defaultSize(width: 900, height: 700)
    }
}

// MARK: - App State
/// 应用全局状态管理
@MainActor
class AppState: ObservableObject {
    static let shared = AppState()
    
    @Published var isCapturing = false
    @Published var currentCaptureMode: CaptureMode = .region
    @Published var lastCapturedImage: NSImage?
    @Published var showingEditor = false
    @Published var editorScreenshotId: UUID?
    
    private init() {}
    
    func startCapture(mode: CaptureMode) {
        currentCaptureMode = mode
        isCapturing = true
    }
    
    func endCapture() {
        isCapturing = false
    }
    
    func openEditor(for screenshotId: UUID) {
        editorScreenshotId = screenshotId
        showingEditor = true
    }
}

// MARK: - Capture Mode
enum CaptureMode: String, CaseIterable, Identifiable {
    case region = "Region"
    case window = "Window"
    case fullscreen = "Fullscreen"
    case menu = "Menu Bar"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .region: return "crop"
        case .window: return "macwindow"
        case .fullscreen: return "rectangle.dashed"
        case .menu: return "menubar.rectangle"
        }
    }
    
    var shortcut: String {
        switch self {
        case .region: return "⌘⇧4"
        case .window: return "⌘⇧5"
        case .fullscreen: return "⌘⇧3"
        case .menu: return "⌘⇧6"
        }
    }
}
