//
//  MenuBarView.swift
//  ScreenshotPro
//
//  Polished menu bar popover — clean, modern, minimal
//

import SwiftUI

struct MenuBarView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: SettingsManager
    
    @State private var selectedDelay: DelayOption = .none
    
    var body: some View {
        VStack(spacing: 0) {
            header
            
            Divider().padding(.horizontal, SPSpacing.md)
            
            captureModes
            
            Divider().padding(.horizontal, SPSpacing.md)
            
            delayOptions
            
            Divider().padding(.horizontal, SPSpacing.md)
            
            quickActions
            
            Divider().padding(.horizontal, SPSpacing.md)
            
            footer
        }
        .frame(width: 300)
        .background(.regularMaterial)
    }
    
    // MARK: - Header
    
    private var header: some View {
        HStack(spacing: SPSpacing.sm) {
            ZStack {
                Circle()
                    .fill(LinearGradient.brand)
                    .frame(width: 28, height: 28)
                
                Image(systemName: "viewfinder")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Text("ScreenshotPro")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
            
            Spacer()
            
            Text("PRO")
                .font(.system(size: 9, weight: .bold))
                .tracking(1)
                .foregroundColor(.brand)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                    Capsule().fill(Color.brand.opacity(0.12))
                )
        }
        .padding(.horizontal, SPSpacing.lg)
        .padding(.vertical, SPSpacing.md)
    }
    
    // MARK: - Capture Modes
    
    private var captureModes: some View {
        VStack(spacing: SPSpacing.xxs) {
            ForEach(CaptureMode.allCases) { mode in
                CaptureModeRow(mode: mode) {
                    startCapture(mode: mode)
                }
            }
        }
        .padding(.horizontal, SPSpacing.sm)
        .padding(.vertical, SPSpacing.sm)
    }
    
    // MARK: - Delay Options
    
    private var delayOptions: some View {
        HStack(spacing: SPSpacing.sm) {
            Image(systemName: "timer")
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
            
            Text("Delay")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
            
            Spacer()
            
            HStack(spacing: SPSpacing.xxs) {
                ForEach(DelayOption.allCases) { delay in
                    DelayChip(delay: delay, isSelected: selectedDelay == delay) {
                        withAnimation(.easeOut(duration: 0.15)) {
                            selectedDelay = delay
                        }
                    }
                }
            }
        }
        .padding(.horizontal, SPSpacing.lg)
        .padding(.vertical, SPSpacing.md)
    }
    
    // MARK: - Quick Actions
    
    private var quickActions: some View {
        VStack(spacing: SPSpacing.xxs) {
            QuickActionRow(icon: "clock.arrow.circlepath", title: "History", shortcut: "⌘H") {
                openHistory()
            }
            QuickActionRow(icon: "doc.on.clipboard", title: "Paste from Clipboard", shortcut: "⌘V") {
                pasteFromClipboard()
            }
        }
        .padding(.horizontal, SPSpacing.sm)
        .padding(.vertical, SPSpacing.sm)
    }
    
    // MARK: - Footer
    
    private var footer: some View {
        HStack {
            Button(action: openSettings) {
                Image(systemName: "gearshape")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .contentShape(Rectangle())
            
            Spacer()
            
            Button(action: { NSApp.terminate(nil) }) {
                Text("Quit")
                    .font(.system(size: 12))
                    .foregroundStyle(.tertiary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, SPSpacing.lg)
        .padding(.vertical, SPSpacing.md)
    }
    
    // MARK: - Actions
    
    private func startCapture(mode: CaptureMode) {
        appState.startCapture(mode: mode)
        NSApp.keyWindow?.close()
        
        if selectedDelay == .none {
            NotificationCenter.default.post(name: .startCapture, object: mode)
        } else {
            Task {
                try? await Task.sleep(nanoseconds: UInt64(selectedDelay.seconds * 1_000_000_000))
                NotificationCenter.default.post(name: .startCapture, object: mode)
            }
        }
    }
    
    private func openHistory() {
        NSApp.keyWindow?.close()
        let historyWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        historyWindow.center()
        historyWindow.title = "Screenshot History"
        historyWindow.contentView = NSHostingView(
            rootView: HistoryView()
                .environmentObject(HistoryManager.shared)
                .environmentObject(appState)
        )
        historyWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func pasteFromClipboard() {
        guard let images = NSPasteboard.general.readObjects(forClasses: [NSImage.self]) as? [NSImage],
              let image = images.first else { return }
        
        NSApp.keyWindow?.close()
        let screenshot = Screenshot(image: image, captureMode: .region)
        HistoryManager.shared.add(screenshot)
        
        let editorWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        editorWindow.center()
        editorWindow.title = "Edit Screenshot"
        editorWindow.contentView = NSHostingView(
            rootView: EditorView(screenshot: screenshot)
                .environmentObject(appState)
                .environmentObject(settings)
        )
        editorWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func openSettings() {
        NSApp.keyWindow?.close()
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}

// MARK: - Capture Mode Row

struct CaptureModeRow: View {
    let mode: CaptureMode
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SPSpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: SPRadius.sm)
                        .fill(isHovering ? Color.brand.opacity(0.12) : Color.primary.opacity(0.05))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: mode.icon)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(isHovering ? .brand : .primary)
                }
                
                Text(mode.rawValue)
                    .font(.system(size: 13, weight: .medium))
                
                Spacer()
                
                Text(mode.shortcut)
                    .font(.system(size: 11, design: .rounded))
                    .foregroundStyle(.tertiary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.primary.opacity(0.04))
                    )
            }
            .padding(.horizontal, SPSpacing.sm)
            .padding(.vertical, SPSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.sm)
                    .fill(isHovering ? Color.primary.opacity(0.06) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

// MARK: - Delay Chip

struct DelayChip: View {
    let delay: DelayOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(delay.displayName)
                .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.brand : Color.primary.opacity(0.06))
                )
                .foregroundColor(isSelected ? .white : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Quick Action Row

struct QuickActionRow: View {
    let icon: String
    let title: String
    let shortcut: String
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SPSpacing.md) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .frame(width: 20)
                
                Text(title)
                    .font(.system(size: 13))
                
                Spacer()
                
                Text(shortcut)
                    .font(.system(size: 10, design: .rounded))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, SPSpacing.sm)
            .padding(.vertical, SPSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.sm)
                    .fill(isHovering ? Color.primary.opacity(0.06) : Color.clear)
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
    }
}

// MARK: - Delay Option

enum DelayOption: String, CaseIterable, Identifiable {
    case none = "Off"
    case three = "3s"
    case five = "5s"
    case ten = "10s"
    
    var id: String { rawValue }
    var displayName: String { rawValue }
    
    var seconds: TimeInterval {
        switch self {
        case .none: return 0
        case .three: return 3
        case .five: return 5
        case .ten: return 10
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let startCapture = Notification.Name("startCapture")
}

#Preview {
    MenuBarView()
        .environmentObject(AppState.shared)
        .environmentObject(SettingsManager.shared)
}
