//
//  Screenshot.swift
//  ScreenshotPro
//
//  Screenshot data model
//

import SwiftUI
import UniformTypeIdentifiers

/// 截图数据模型
struct Screenshot: Identifiable, Codable {
    let id: UUID
    let createdAt: Date
    let captureMode: CaptureMode
    var annotations: [Annotation]
    var beautifySettings: BeautifySettings
    
    // 非 Codable 属性
    private var _image: NSImage?
    private var imagePath: URL?
    
    var image: NSImage? {
        get {
            if let img = _image {
                return img
            }
            if let path = imagePath {
                return NSImage(contentsOf: path)
            }
            return nil
        }
        set {
            _image = newValue
        }
    }
    
    init(image: NSImage, captureMode: CaptureMode) {
        self.id = UUID()
        self.createdAt = Date()
        self.captureMode = captureMode
        self.annotations = []
        self.beautifySettings = BeautifySettings()
        self._image = image
    }
    
    // MARK: - Codable
    
    enum CodingKeys: String, CodingKey {
        case id, createdAt, captureMode, annotations, beautifySettings, imagePath
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        captureMode = try container.decode(CaptureMode.self, forKey: .captureMode)
        annotations = try container.decode([Annotation].self, forKey: .annotations)
        beautifySettings = try container.decode(BeautifySettings.self, forKey: .beautifySettings)
        imagePath = try container.decodeIfPresent(URL.self, forKey: .imagePath)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(captureMode, forKey: .captureMode)
        try container.encode(annotations, forKey: .annotations)
        try container.encode(beautifySettings, forKey: .beautifySettings)
        try container.encodeIfPresent(imagePath, forKey: .imagePath)
    }
    
    // MARK: - Image Operations
    
    /// 保存图片到文件并更新路径
    mutating func saveImage(to directory: URL) throws {
        guard let image = _image else { return }
        
        let filename = "\(id.uuidString).png"
        let url = directory.appendingPathComponent(filename)
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw ScreenshotError.imageConversionFailed
        }
        
        try pngData.write(to: url)
        imagePath = url
    }
    
    /// 渲染最终图片（包含标注和美化效果）
    func renderFinal() -> NSImage? {
        guard let baseImage = image else { return nil }
        
        let size = baseImage.size
        let finalImage = NSImage(size: size)
        
        finalImage.lockFocus()
        
        // 绘制背景（如果有）
        if beautifySettings.hasBackground {
            drawBackground(in: NSRect(origin: .zero, size: size))
        }
        
        // 应用圆角和阴影
        let imageRect = beautifySettings.hasBackground 
            ? NSRect(x: beautifySettings.padding, 
                     y: beautifySettings.padding, 
                     width: size.width - beautifySettings.padding * 2, 
                     height: size.height - beautifySettings.padding * 2)
            : NSRect(origin: .zero, size: size)
        
        // 绘制阴影
        if beautifySettings.shadowEnabled {
            let shadow = NSShadow()
            shadow.shadowColor = NSColor.black.withAlphaComponent(CGFloat(beautifySettings.shadowOpacity))
            shadow.shadowOffset = NSSize(width: 0, height: -beautifySettings.shadowOffset)
            shadow.shadowBlurRadius = CGFloat(beautifySettings.shadowBlur)
            shadow.set()
        }
        
        // 绘制图片（带圆角）
        let path = NSBezierPath(roundedRect: imageRect, xRadius: beautifySettings.cornerRadius, yRadius: beautifySettings.cornerRadius)
        path.addClip()
        baseImage.draw(in: imageRect)
        
        // 绘制标注
        for annotation in annotations {
            annotation.draw()
        }
        
        finalImage.unlockFocus()
        
        return finalImage
    }
    
    private func drawBackground(in rect: NSRect) {
        switch beautifySettings.backgroundType {
        case .solid:
            NSColor(beautifySettings.backgroundColor).setFill()
            NSBezierPath(rect: rect).fill()
            
        case .gradient:
            let gradient = NSGradient(colors: beautifySettings.gradientColors.map { NSColor($0) })
            gradient?.draw(in: rect, angle: beautifySettings.gradientAngle)
            
        case .transparent:
            // 绘制透明棋盘格
            drawTransparencyGrid(in: rect)
            
        case .image:
            if let bgImage = beautifySettings.backgroundImage {
                bgImage.draw(in: rect)
            }
        }
    }
    
    private func drawTransparencyGrid(in rect: NSRect) {
        let gridSize: CGFloat = 10
        let colors = [NSColor.white, NSColor(white: 0.9, alpha: 1.0)]
        
        var row = 0
        var y = rect.minY
        while y < rect.maxY {
            var col = 0
            var x = rect.minX
            while x < rect.maxX {
                colors[(row + col) % 2].setFill()
                let cellRect = NSRect(x: x, y: y, width: gridSize, height: gridSize)
                NSBezierPath(rect: cellRect).fill()
                x += gridSize
                col += 1
            }
            y += gridSize
            row += 1
        }
    }
}

// MARK: - Screenshot Error

enum ScreenshotError: LocalizedError {
    case imageConversionFailed
    case saveFailed
    case loadFailed
    
    var errorDescription: String? {
        switch self {
        case .imageConversionFailed:
            return "Failed to convert image"
        case .saveFailed:
            return "Failed to save screenshot"
        case .loadFailed:
            return "Failed to load screenshot"
        }
    }
}

// MARK: - Beautify Settings

struct BeautifySettings: Codable {
    var shadowEnabled: Bool = true
    var shadowBlur: Double = 20
    var shadowOffset: Double = 5
    var shadowOpacity: Double = 0.3
    
    var cornerRadius: CGFloat = 8
    var padding: CGFloat = 40
    
    var backgroundType: BackgroundType = .gradient
    var backgroundColor: Color = .white
    var gradientColors: [Color] = [Color(red: 0.4, green: 0.2, blue: 0.8), Color(red: 0.2, green: 0.6, blue: 0.9)]
    var gradientAngle: CGFloat = 45
    var backgroundImage: NSImage?
    
    var mockupType: MockupType = .none
    var watermarkEnabled: Bool = false
    var watermarkText: String = ""
    var watermarkPosition: WatermarkPosition = .bottomRight
    
    var hasBackground: Bool {
        backgroundType != .transparent || padding > 0
    }
    
    // Codable 兼容
    enum CodingKeys: String, CodingKey {
        case shadowEnabled, shadowBlur, shadowOffset, shadowOpacity
        case cornerRadius, padding
        case backgroundType, gradientAngle
        case mockupType, watermarkEnabled, watermarkText, watermarkPosition
    }
    
    init() {}
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        shadowEnabled = try container.decodeIfPresent(Bool.self, forKey: .shadowEnabled) ?? true
        shadowBlur = try container.decodeIfPresent(Double.self, forKey: .shadowBlur) ?? 20
        shadowOffset = try container.decodeIfPresent(Double.self, forKey: .shadowOffset) ?? 5
        shadowOpacity = try container.decodeIfPresent(Double.self, forKey: .shadowOpacity) ?? 0.3
        cornerRadius = try container.decodeIfPresent(CGFloat.self, forKey: .cornerRadius) ?? 8
        padding = try container.decodeIfPresent(CGFloat.self, forKey: .padding) ?? 40
        backgroundType = try container.decodeIfPresent(BackgroundType.self, forKey: .backgroundType) ?? .gradient
        gradientAngle = try container.decodeIfPresent(CGFloat.self, forKey: .gradientAngle) ?? 45
        mockupType = try container.decodeIfPresent(MockupType.self, forKey: .mockupType) ?? .none
        watermarkEnabled = try container.decodeIfPresent(Bool.self, forKey: .watermarkEnabled) ?? false
        watermarkText = try container.decodeIfPresent(String.self, forKey: .watermarkText) ?? ""
        watermarkPosition = try container.decodeIfPresent(WatermarkPosition.self, forKey: .watermarkPosition) ?? .bottomRight
    }
}

// MARK: - Enums

enum BackgroundType: String, Codable, CaseIterable {
    case solid = "Solid Color"
    case gradient = "Gradient"
    case transparent = "Transparent"
    case image = "Image"
}

enum MockupType: String, Codable, CaseIterable {
    case none = "None"
    case macbook = "MacBook"
    case macbookPro = "MacBook Pro"
    case imac = "iMac"
    case iphone = "iPhone"
    case ipad = "iPad"
    case browser = "Browser Window"
}

enum WatermarkPosition: String, Codable, CaseIterable {
    case topLeft = "Top Left"
    case topRight = "Top Right"
    case bottomLeft = "Bottom Left"
    case bottomRight = "Bottom Right"
    case center = "Center"
}

// MARK: - CaptureMode Codable

extension CaptureMode: Codable {}

// MARK: - Color Codable Extension

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        let nsColor = NSColor(self)
        let rgbColor = nsColor.usingColorSpace(.deviceRGB) ?? nsColor
        try container.encode(rgbColor.redComponent, forKey: .red)
        try container.encode(rgbColor.greenComponent, forKey: .green)
        try container.encode(rgbColor.blueComponent, forKey: .blue)
        try container.encode(rgbColor.alphaComponent, forKey: .opacity)
    }
}
