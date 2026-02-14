//
//  SettingsView.swift
//  ScreenshotPro
//
//  Modern macOS Settings — clean grouped form design
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        TabView {
            GeneralSettingsTab()
                .tabItem { Label("General", systemImage: "gearshape") }
            
            CaptureSettingsTab()
                .tabItem { Label("Capture", systemImage: "camera") }
            
            HotkeySettingsTab()
                .tabItem { Label("Shortcuts", systemImage: "keyboard") }
            
            AnnotationSettingsTab()
                .tabItem { Label("Annotation", systemImage: "pencil.tip") }
            
            StorageSettingsTab()
                .tabItem { Label("Storage", systemImage: "externaldrive") }
            
            AboutTab()
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 520, height: 420)
    }
}

// MARK: - General Settings

struct GeneralSettingsTab: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at Login", isOn: $settings.launchAtLogin)
                Toggle("Show in Menu Bar", isOn: $settings.showInMenuBar)
                Toggle("Hide from Dock", isOn: $settings.hideFromDock)
            }
            
            Section("Feedback") {
                Toggle("Play Capture Sound", isOn: $settings.playCaptureSound)
            }
            
            Section {
                Button("Reset All Settings", role: .destructive) {
                    settings.resetToDefaults()
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Capture Settings

struct CaptureSettingsTab: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var showingFolderPicker = false
    
    var body: some View {
        Form {
            Section("Behavior") {
                Picker("After Capture", selection: $settings.afterCaptureAction) {
                    ForEach(AfterCaptureAction.allCases) { action in
                        Text(action.rawValue).tag(action)
                    }
                }
                Toggle("Copy to Clipboard", isOn: $settings.copyToClipboard)
            }
            
            Section("Output") {
                HStack {
                    Text("Save Location")
                    Spacer()
                    Text(settings.saveFolder.lastPathComponent)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Button("Choose…") { showingFolderPicker = true }
                        .controlSize(.small)
                }
                
                Picker("Image Format", selection: $settings.imageFormat) {
                    ForEach(ImageFormat.allCases) { f in Text(f.rawValue).tag(f) }
                }
                
                if settings.imageFormat == .jpeg {
                    HStack {
                        Text("Quality")
                        Slider(value: $settings.jpegQuality, in: 0.1...1.0)
                        Text("\(Int(settings.jpegQuality * 100))%")
                            .font(.caption).monospacedDigit()
                            .frame(width: 36, alignment: .trailing)
                    }
                }
            }
            
            Section("Capture Options") {
                Toggle("Include Window Shadow", isOn: $settings.includeWindowShadow)
                Toggle("Capture Mouse Cursor", isOn: $settings.captureMouseCursor)
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .fileImporter(isPresented: $showingFolderPicker, allowedContentTypes: [.folder], allowsMultipleSelection: false) { result in
            if case .success(let urls) = result, let url = urls.first {
                settings.saveFolder = url
            }
        }
    }
}

// MARK: - Hotkey Settings

struct HotkeySettingsTab: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("Capture Shortcuts") {
                HotkeyRow(label: "Region Capture", config: $settings.regionHotkey)
                HotkeyRow(label: "Window Capture", config: $settings.windowHotkey)
                HotkeyRow(label: "Fullscreen Capture", config: $settings.fullscreenHotkey)
                HotkeyRow(label: "Menu Bar Capture", config: $settings.menuHotkey)
            }
            
            Section {
                Button("Restore Defaults") {
                    settings.regionHotkey = HotkeyConfig(keyCode: 21, modifiers: [.command, .shift])
                    settings.windowHotkey = HotkeyConfig(keyCode: 23, modifiers: [.command, .shift])
                    settings.fullscreenHotkey = HotkeyConfig(keyCode: 20, modifiers: [.command, .shift])
                    settings.menuHotkey = HotkeyConfig(keyCode: 22, modifiers: [.command, .shift])
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

struct HotkeyRow: View {
    let label: String
    @Binding var config: HotkeyConfig
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            HotkeyRecorderView(config: $config)
        }
    }
}

// MARK: - Annotation Settings

struct AnnotationSettingsTab: View {
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        Form {
            Section("Defaults") {
                ColorPicker("Default Color", selection: $settings.defaultAnnotationColor)
                
                Picker("Stroke Width", selection: $settings.defaultStrokeWidth) {
                    ForEach(AnnotationEngine.strokeWidthPresets, id: \.self) { w in
                        Text("\(Int(w))px").tag(w)
                    }
                }
                
                Picker("Font Size", selection: $settings.defaultFontSize) {
                    ForEach(AnnotationEngine.fontSizePresets, id: \.self) { s in
                        Text("\(Int(s))pt").tag(s)
                    }
                }
            }
            
            Section("Default Beautify") {
                Toggle("Shadow", isOn: $settings.defaultBeautifySettings.shadowEnabled)
                
                HStack {
                    Text("Corner Radius")
                    Slider(value: Binding(
                        get: { Double(settings.defaultBeautifySettings.cornerRadius) },
                        set: { settings.defaultBeautifySettings.cornerRadius = CGFloat($0) }
                    ), in: 0...30)
                    Text("\(Int(settings.defaultBeautifySettings.cornerRadius))px")
                        .font(.caption).monospacedDigit()
                        .frame(width: 32, alignment: .trailing)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}

// MARK: - Storage Settings

struct StorageSettingsTab: View {
    @EnvironmentObject var settings: SettingsManager
    @StateObject private var historyManager = HistoryManager.shared
    @State private var showingClearConfirmation = false
    
    var body: some View {
        Form {
            Section("History") {
                Picker("Max Items", selection: $settings.maxHistoryItems) {
                    Text("50").tag(50); Text("100").tag(100)
                    Text("200").tag(200); Text("500").tag(500)
                    Text("1000").tag(1000)
                }
                
                Picker("Keep For", selection: $settings.historyRetentionDays) {
                    Text("7 days").tag(7); Text("30 days").tag(30)
                    Text("90 days").tag(90); Text("1 year").tag(365)
                    Text("Forever").tag(0)
                }
            }
            
            Section("Storage") {
                LabeledContent("Used", value: historyManager.formattedStorageSize())
                LabeledContent("Screenshots", value: "\(historyManager.screenshots.count)")
                
                Button("Clear All History", role: .destructive) {
                    showingClearConfirmation = true
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .confirmationDialog("Clear All History?", isPresented: $showingClearConfirmation, titleVisibility: .visible) {
            Button("Clear All", role: .destructive) { historyManager.clearAll() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete all screenshots. This cannot be undone.")
        }
    }
}

// MARK: - About Tab

struct AboutTab: View {
    var body: some View {
        VStack(spacing: SPSpacing.xl) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(LinearGradient.brand.opacity(0.15))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "viewfinder")
                    .font(.system(size: 34, weight: .medium))
                    .foregroundStyle(LinearGradient.brand)
            }
            
            VStack(spacing: SPSpacing.xs) {
                Text("ScreenshotPro")
                    .font(.system(size: 22, weight: .bold, design: .rounded))
                
                Text("Version 1.0.0 (1)")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Text("Beautiful screenshots for macOS")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
            
            Divider().frame(width: 180)
            
            VStack(spacing: SPSpacing.sm) {
                Link("Website", destination: URL(string: "https://screenshotpro.app")!)
                Link("Support", destination: URL(string: "https://screenshotpro.app/support")!)
                Link("Privacy Policy", destination: URL(string: "https://screenshotpro.app/privacy")!)
            }
            .font(.system(size: 13))
            
            Spacer()
            
            Text("© 2024 ScreenshotPro. All rights reserved.")
                .font(.system(size: 10))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsManager.shared)
}
