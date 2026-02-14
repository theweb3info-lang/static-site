//
//  AppDelegate.swift
//  ScreenshotPro
//
//  Handles menu bar, global hotkeys, and app lifecycle
//

import SwiftUI
import ScreenCaptureKit
import Carbon.HIToolbox

@MainActor
class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private var overlayWindow: OverlayWindow?
    private var eventMonitor: Any?
    
    private let captureService = ScreenCaptureService.shared
    private let hotkeyManager = HotkeyManager.shared
    private let historyManager = HistoryManager.shared
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        Task { await requestScreenCapturePermission() }
        setupMenuBar()
        setupGlobalHotkeys()
        checkFirstLaunch()
        
        if SettingsManager.shared.hideFromDock {
            NSApp.setActivationPolicy(.accessory)
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        hotkeyManager.unregisterAll()
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    // MARK: - Screen Capture Permission
    
    private func requestScreenCapturePermission() async {
        do {
            _ = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
        } catch {
            DispatchQueue.main.async { self.showPermissionAlert() }
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = NSLocalizedString("permission.title", comment: "")
        alert.informativeText = NSLocalizedString("permission.message", comment: "")
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("permission.openSettings", comment: ""))
        alert.addButton(withTitle: NSLocalizedString("permission.later", comment: ""))
        
        if alert.runModal() == .alertFirstButtonReturn {
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // MARK: - Menu Bar Setup
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            // Use a clean, minimal SF Symbol
            let config = NSImage.SymbolConfiguration(pointSize: 14, weight: .medium)
            let image = NSImage(systemSymbolName: "viewfinder", accessibilityDescription: "ScreenshotPro")?
                .withSymbolConfiguration(config)
            button.image = image
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 300, height: 420)
        popover?.behavior = .transient
        popover?.animates = true
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarView()
                .environmentObject(AppState.shared)
                .environmentObject(SettingsManager.shared)
        )
        
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if self?.popover?.isShown == true {
                self?.popover?.performClose(nil)
            }
        }
    }
    
    @objc private func togglePopover() {
        guard let button = statusItem?.button, let popover = popover else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
    
    // MARK: - Global Hotkeys
    
    private func setupGlobalHotkeys() {
        hotkeyManager.register(keyCode: UInt32(kVK_ANSI_4), modifiers: UInt32(cmdKey | shiftKey), id: "region") { [weak self] in
            self?.startCapture(mode: .region)
        }
        hotkeyManager.register(keyCode: UInt32(kVK_ANSI_5), modifiers: UInt32(cmdKey | shiftKey), id: "window") { [weak self] in
            self?.startCapture(mode: .window)
        }
        hotkeyManager.register(keyCode: UInt32(kVK_ANSI_3), modifiers: UInt32(cmdKey | shiftKey), id: "fullscreen") { [weak self] in
            self?.startCapture(mode: .fullscreen)
        }
        hotkeyManager.register(keyCode: UInt32(kVK_ANSI_6), modifiers: UInt32(cmdKey | shiftKey), id: "menu") { [weak self] in
            self?.startCapture(mode: .menu)
        }
    }
    
    // MARK: - Capture Actions
    
    private func startCapture(mode: CaptureMode) {
        popover?.performClose(nil)
        
        Task { @MainActor in
            AppState.shared.startCapture(mode: mode)
            
            switch mode {
            case .region:   showOverlayForRegionCapture()
            case .window:   await captureWindow()
            case .fullscreen: await captureFullscreen()
            case .menu:     await captureMenuBar()
            }
        }
    }
    
    private func showOverlayForRegionCapture() {
        overlayWindow = OverlayWindow()
        overlayWindow?.onCapture = { [weak self] rect in
            Task { await self?.captureRegion(rect) }
        }
        overlayWindow?.onCancel = { [weak self] in
            self?.overlayWindow?.close()
            self?.overlayWindow = nil
            Task { @MainActor in AppState.shared.endCapture() }
        }
        overlayWindow?.show()
    }
    
    private func captureRegion(_ rect: CGRect) async {
        do {
            let image = try await captureService.captureRegion(rect)
            await handleCapturedImage(image)
        } catch {
            showError("Failed to capture region: \(error.localizedDescription)")
        }
        overlayWindow?.close()
        overlayWindow = nil
    }
    
    private func captureWindow() async {
        do {
            let windows = try await captureService.getAvailableWindows()
            if let frontWindow = windows.first {
                let image = try await captureService.captureWindow(frontWindow)
                await handleCapturedImage(image)
            }
        } catch {
            showError("Failed to capture window: \(error.localizedDescription)")
        }
    }
    
    private func captureFullscreen() async {
        do {
            let image = try await captureService.captureFullscreen()
            await handleCapturedImage(image)
        } catch {
            showError("Failed to capture fullscreen: \(error.localizedDescription)")
        }
    }
    
    private func captureMenuBar() async {
        do {
            let image = try await captureService.captureMenuBar()
            await handleCapturedImage(image)
        } catch {
            showError("Failed to capture menu bar: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func handleCapturedImage(_ image: NSImage) async {
        AppState.shared.endCapture()
        AppState.shared.lastCapturedImage = image
        
        let settings = SettingsManager.shared
        let screenshot = Screenshot(image: image, captureMode: AppState.shared.currentCaptureMode)
        historyManager.add(screenshot)
        
        if settings.copyToClipboard {
            copyToClipboard(image)
        }
        
        if settings.playCaptureSound {
            NSSound(named: "Grab")?.play()
        }
        
        switch settings.afterCaptureAction {
        case .showEditor:  openFloatingEditor(for: screenshot)
        case .saveToFolder: saveToFolder(image)
        case .copyOnly:    showNotification(title: "Screenshot Captured", body: "Copied to clipboard")
        }
    }
    
    private func openFloatingEditor(for screenshot: Screenshot) {
        let editorWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 680),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        editorWindow.titlebarAppearsTransparent = true
        editorWindow.titleVisibility = .hidden
        editorWindow.isMovableByWindowBackground = true
        editorWindow.center()
        editorWindow.backgroundColor = .clear
        editorWindow.hasShadow = true
        
        editorWindow.contentView = NSHostingView(
            rootView: EditorView(screenshot: screenshot)
                .environmentObject(AppState.shared)
                .environmentObject(SettingsManager.shared)
        )
        editorWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    private func copyToClipboard(_ image: NSImage) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.writeObjects([image])
    }
    
    private func saveToFolder(_ image: NSImage) {
        let settings = SettingsManager.shared
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let filename = "Screenshot_\(formatter.string(from: Date())).png"
        let url = settings.saveFolder.appendingPathComponent(filename)
        
        if let tiffData = image.tiffRepresentation,
           let bitmap = NSBitmapImageRep(data: tiffData),
           let pngData = bitmap.representation(using: .png, properties: [:]) {
            try? pngData.write(to: url)
            showNotification(title: "Screenshot Saved", body: url.lastPathComponent)
        }
    }
    
    private func showNotification(title: String, body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    private func showError(_ message: String) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = NSLocalizedString("error.title", comment: "")
            alert.informativeText = message
            alert.alertStyle = .critical
            alert.runModal()
        }
    }
    
    private func checkFirstLaunch() {
        let defaults = UserDefaults.standard
        if !defaults.bool(forKey: "hasLaunchedBefore") {
            defaults.set(true, forKey: "hasLaunchedBefore")
            showWelcomeWindow()
        }
    }
    
    private func showWelcomeWindow() {
        let welcomeWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 540, height: 520),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        welcomeWindow.titlebarAppearsTransparent = true
        welcomeWindow.titleVisibility = .hidden
        welcomeWindow.isMovableByWindowBackground = true
        welcomeWindow.center()
        welcomeWindow.backgroundColor = .clear
        welcomeWindow.contentView = NSHostingView(rootView: WelcomeView())
        welcomeWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}

// MARK: - Welcome View

struct WelcomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var animateIn = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Hero area
            ZStack {
                LinearGradient.brand
                    .opacity(0.12)
                
                VStack(spacing: SPSpacing.lg) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient.brand.opacity(0.15))
                            .frame(width: 96, height: 96)
                        
                        Image(systemName: "viewfinder")
                            .font(.system(size: 42, weight: .medium))
                            .foregroundStyle(LinearGradient.brand)
                    }
                    .scaleEffect(animateIn ? 1.0 : 0.6)
                    .opacity(animateIn ? 1.0 : 0)
                    
                    VStack(spacing: SPSpacing.sm) {
                        Text("Welcome to ScreenshotPro")
                            .font(.system(size: 26, weight: .bold, design: .rounded))
                        
                        Text("Beautiful screenshots, effortlessly")
                            .font(.system(size: 15))
                            .foregroundStyle(.secondary)
                    }
                    .opacity(animateIn ? 1.0 : 0)
                    .offset(y: animateIn ? 0 : 10)
                }
                .padding(.vertical, SPSpacing.xxxl)
            }
            .frame(height: 220)
            
            // Feature list
            VStack(spacing: SPSpacing.lg) {
                WelcomeFeatureRow(icon: "crop", color: .brand, title: "Smart Capture", description: "Region, window, or full screen — ⌘⇧3/4/5")
                WelcomeFeatureRow(icon: "pencil.tip.crop.circle", color: .orange, title: "Annotate", description: "Arrows, shapes, text, blur & numbered steps")
                WelcomeFeatureRow(icon: "sparkles", color: .purple, title: "Beautify", description: "Shadows, backgrounds, device mockups")
                WelcomeFeatureRow(icon: "clock.arrow.circlepath", color: .blue, title: "History", description: "All captures saved and searchable")
            }
            .padding(.horizontal, SPSpacing.xxxl)
            .padding(.vertical, SPSpacing.xxl)
            .opacity(animateIn ? 1.0 : 0)
            .offset(y: animateIn ? 0 : 15)
            
            Spacer()
            
            // CTA
            Button("Get Started") {
                NSApp.keyWindow?.close()
            }
            .buttonStyle(SPPrimaryButtonStyle())
            .padding(.bottom, SPSpacing.xxxl)
            .opacity(animateIn ? 1.0 : 0)
        }
        .frame(width: 540, height: 520)
        .background(Color.surfacePrimary)
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.1)) {
                animateIn = true
            }
        }
    }
}

struct WelcomeFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: SPSpacing.lg) {
            ZStack {
                RoundedRectangle(cornerRadius: SPRadius.sm)
                    .fill(color.opacity(0.12))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(description)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
    }
}
