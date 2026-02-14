//
//  ScreenCaptureService.swift
//  ScreenshotPro
//
//  Screen capture service using ScreenCaptureKit
//

import SwiftUI
import ScreenCaptureKit
import CoreImage

// MARK: - Screen Capture Service

/// 屏幕截图服务 - 使用 ScreenCaptureKit
actor ScreenCaptureService {
    static let shared = ScreenCaptureService()
    
    private var shareableContent: SCShareableContent?
    
    private init() {}
    
    // MARK: - Public Methods
    
    func refreshContent() async throws {
        shareableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
    }
    
    func getAvailableDisplays() async throws -> [SCDisplay] {
        try await refreshContent()
        return shareableContent?.displays ?? []
    }
    
    func getAvailableWindows() async throws -> [SCWindow] {
        try await refreshContent()
        return shareableContent?.windows.filter { window in
            guard let title = window.title, !title.isEmpty else { return false }
            guard window.isOnScreen else { return false }
            guard let app = window.owningApplication else { return false }
            let excludedBundleIDs = [
                "com.apple.controlcenter",
                "com.apple.notificationcenterui",
                Bundle.main.bundleIdentifier ?? ""
            ]
            return !excludedBundleIDs.contains(app.bundleIdentifier ?? "")
        } ?? []
    }
    
    // MARK: - Capture Methods
    
    func captureFullscreen(displayIndex: Int = 0) async throws -> NSImage {
        try await refreshContent()
        
        guard let displays = shareableContent?.displays, displayIndex < displays.count else {
            throw CaptureError.noDisplayAvailable
        }
        
        let display = displays[displayIndex]
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.width = display.width * 2
        config.height = display.height * 2
        config.scalesToFit = false
        config.showsCursor = await SettingsManager.shared.captureMouseCursor
        
        let image = try await captureWithFilter(filter, config: config)
        return image
    }
    
    func captureWindow(_ window: SCWindow) async throws -> NSImage {
        try await refreshContent()
        
        guard let display = shareableContent?.displays.first else {
            throw CaptureError.noDisplayAvailable
        }
        
        let filter = SCContentFilter(display: display, including: [window])
        let config = SCStreamConfiguration()
        
        let frame = window.frame
        config.width = Int(frame.width) * 2
        config.height = Int(frame.height) * 2
        config.scalesToFit = false
        config.showsCursor = await SettingsManager.shared.captureMouseCursor
        
        let image = try await captureWithFilter(filter, config: config)
        return image
    }
    
    func captureRegion(_ rect: CGRect) async throws -> NSImage {
        try await refreshContent()
        
        guard let display = shareableContent?.displays.first else {
            throw CaptureError.noDisplayAvailable
        }
        
        let filter = SCContentFilter(display: display, excludingWindows: [])
        let config = SCStreamConfiguration()
        config.width = display.width * 2
        config.height = display.height * 2
        config.scalesToFit = false
        config.showsCursor = await SettingsManager.shared.captureMouseCursor
        
        let fullImage = try await captureWithFilter(filter, config: config)
        
        let scale: CGFloat = 2.0
        let displayHeight = CGFloat(display.height)
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: (displayHeight - rect.origin.y - rect.height) * scale,
            width: rect.width * scale,
            height: rect.height * scale
        )
        
        return cropImage(fullImage, to: scaledRect)
    }
    
    func captureMenuBar() async throws -> NSImage {
        try await refreshContent()
        
        guard let display = shareableContent?.displays.first else {
            throw CaptureError.noDisplayAvailable
        }
        
        let menuBarHeight: CGFloat = 25
        let displayHeight = CGFloat(display.height)
        let displayWidth = CGFloat(display.width)
        let rect = CGRect(x: 0, y: displayHeight - menuBarHeight, width: displayWidth, height: menuBarHeight)
        
        return try await captureRegion(rect)
    }
    
    func captureDelayed(mode: CaptureMode, delay: TimeInterval) async throws -> NSImage {
        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        
        switch mode {
        case .fullscreen:
            return try await captureFullscreen()
        case .window:
            let windows = try await getAvailableWindows()
            if let first = windows.first {
                return try await captureWindow(first)
            }
            throw CaptureError.noWindowAvailable
        case .region:
            return try await captureFullscreen()
        case .menu:
            return try await captureMenuBar()
        }
    }
    
    // MARK: - Private Methods
    
    private func captureWithFilter(_ filter: SCContentFilter, config: SCStreamConfiguration) async throws -> NSImage {
        if #available(macOS 14.0, *) {
            return try await captureWithScreenshotManager(filter, config: config)
        } else {
            return try await captureWithStream(filter, config: config)
        }
    }
    
    @available(macOS 14.0, *)
    private func captureWithScreenshotManager(_ filter: SCContentFilter, config: SCStreamConfiguration) async throws -> NSImage {
        let cgImage = try await SCScreenshotManager.captureImage(contentFilter: filter, configuration: config)
        return NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
    }
    
    private func captureWithStream(_ filter: SCContentFilter, config: SCStreamConfiguration) async throws -> NSImage {
        // Fallback for macOS 13: use SCStream with a single frame capture
        let stream = SCStream(filter: filter, configuration: config, delegate: nil)
        
        return try await withCheckedThrowingContinuation { continuation in
            let handler = StreamOutputHandler(continuation: continuation)
            do {
                try stream.addStreamOutput(handler, type: .screen, sampleHandlerQueue: .main)
                stream.startCapture { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    }
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
    
    private func cropImage(_ image: NSImage, to rect: CGRect) -> NSImage {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return image
        }
        guard let croppedCGImage = cgImage.cropping(to: rect) else {
            return image
        }
        return NSImage(cgImage: croppedCGImage, size: NSSize(width: croppedCGImage.width, height: croppedCGImage.height))
    }
}

// MARK: - Stream Output Handler (macOS 13 fallback)

private class StreamOutputHandler: NSObject, SCStreamOutput {
    private var continuation: CheckedContinuation<NSImage, Error>?
    private var hasResumed = false
    
    init(continuation: CheckedContinuation<NSImage, Error>) {
        self.continuation = continuation
    }
    
    func stream(_ stream: SCStream, didOutputSampleBuffer sampleBuffer: CMSampleBuffer, of type: SCStreamOutputType) {
        guard !hasResumed, type == .screen else { return }
        hasResumed = true
        
        guard let imageBuffer = sampleBuffer.imageBuffer else {
            continuation?.resume(throwing: CaptureError.captureFailedNoImage)
            return
        }
        
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let context = CIContext()
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            continuation?.resume(throwing: CaptureError.captureFailedNoImage)
            return
        }
        
        let nsImage = NSImage(cgImage: cgImage, size: NSSize(width: cgImage.width, height: cgImage.height))
        continuation?.resume(returning: nsImage)
        
        stream.stopCapture { _ in }
    }
}

// MARK: - Capture Error

enum CaptureError: LocalizedError {
    case noDisplayAvailable
    case noWindowAvailable
    case captureFailedNoImage
    case permissionDenied
    case cancelled
    
    var errorDescription: String? {
        switch self {
        case .noDisplayAvailable: return "No display available for capture"
        case .noWindowAvailable: return "No window available for capture"
        case .captureFailedNoImage: return "Failed to capture screenshot"
        case .permissionDenied: return "Screen recording permission denied"
        case .cancelled: return "Capture was cancelled"
        }
    }
}

// MARK: - Overlay Window for Region Selection

class OverlayWindow: NSWindow {
    var onCapture: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?
    
    private var selectionView: SelectionOverlayView?
    
    init() {
        guard let screen = NSScreen.main else {
            super.init(contentRect: .zero, styleMask: .borderless, backing: .buffered, defer: false)
            return
        }
        
        super.init(
            contentRect: screen.frame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )
        
        self.level = .screenSaver
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        self.ignoresMouseEvents = false
        self.acceptsMouseMovedEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        
        let selectionView = SelectionOverlayView(frame: screen.frame)
        selectionView.onComplete = { [weak self] rect in
            self?.onCapture?(rect)
        }
        selectionView.onCancel = { [weak self] in
            self?.onCancel?()
        }
        
        self.contentView = selectionView
        self.selectionView = selectionView
    }
    
    func show() {
        makeKeyAndOrderFront(nil)
        NSCursor.crosshair.push()
    }
    
    override func close() {
        NSCursor.pop()
        super.close()
    }
}

// MARK: - Selection Overlay View

class SelectionOverlayView: NSView {
    var onComplete: ((CGRect) -> Void)?
    var onCancel: (() -> Void)?
    
    private var startPoint: CGPoint?
    private var currentPoint: CGPoint?
    private var isDragging = false
    
    private var selectionRect: CGRect {
        guard let start = startPoint, let current = currentPoint else { return .zero }
        return CGRect(
            x: min(start.x, current.x),
            y: min(start.y, current.y),
            width: abs(current.x - start.x),
            height: abs(current.y - start.y)
        )
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupTrackingArea()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTrackingArea()
    }
    
    private func setupTrackingArea() {
        let trackingArea = NSTrackingArea(
            rect: bounds,
            options: [.activeAlways, .mouseMoved, .inVisibleRect],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(trackingArea)
    }
    
    override var acceptsFirstResponder: Bool { true }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { onCancel?() }
    }
    
    override func mouseDown(with event: NSEvent) {
        startPoint = convert(event.locationInWindow, from: nil)
        currentPoint = startPoint
        isDragging = true
        needsDisplay = true
    }
    
    override func mouseDragged(with event: NSEvent) {
        currentPoint = convert(event.locationInWindow, from: nil)
        needsDisplay = true
    }
    
    override func mouseUp(with event: NSEvent) {
        isDragging = false
        let rect = selectionRect
        if rect.width > 10 && rect.height > 10 {
            let screenRect = CGRect(
                x: rect.origin.x,
                y: bounds.height - rect.origin.y - rect.height,
                width: rect.width,
                height: rect.height
            )
            onComplete?(screenRect)
        } else {
            onCancel?()
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        NSColor.black.withAlphaComponent(0.3).setFill()
        bounds.fill()
        
        if isDragging && selectionRect.width > 0 && selectionRect.height > 0 {
            NSColor.clear.setFill()
            let path = NSBezierPath(rect: selectionRect)
            NSGraphicsContext.current?.compositingOperation = .copy
            path.fill()
            
            NSColor.white.setStroke()
            let borderPath = NSBezierPath(rect: selectionRect)
            borderPath.lineWidth = 1
            borderPath.stroke()
            
            drawSizeLabel()
        }
        
        if !isDragging {
            drawInstructions()
        }
    }
    
    private func drawSizeLabel() {
        let rect = selectionRect
        let text = "\(Int(rect.width)) × \(Int(rect.height))"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 12, weight: .medium),
            .backgroundColor: NSColor.black.withAlphaComponent(0.7)
        ]
        let string = NSAttributedString(string: " \(text) ", attributes: attributes)
        let size = string.size()
        let labelOrigin = CGPoint(x: rect.midX - size.width / 2, y: rect.maxY + 8)
        string.draw(at: labelOrigin)
    }
    
    private func drawInstructions() {
        let text = "Drag to select area • Press ESC to cancel"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 16, weight: .medium)
        ]
        let string = NSAttributedString(string: text, attributes: attributes)
        let size = string.size()
        let point = CGPoint(x: bounds.midX - size.width / 2, y: bounds.midY - size.height / 2)
        
        let bgRect = CGRect(x: point.x - 16, y: point.y - 8, width: size.width + 32, height: size.height + 16)
        NSColor.black.withAlphaComponent(0.7).setFill()
        NSBezierPath(roundedRect: bgRect, xRadius: 8, yRadius: 8).fill()
        
        string.draw(at: point)
    }
}
