//
//  AnnotationEngine.swift
//  ScreenshotPro
//
//  Annotation rendering and management engine
//

import SwiftUI
import CoreImage
import Accelerate

// MARK: - Annotation Engine

/// 标注引擎 - 处理标注的渲染、编辑和图像处理
@MainActor
class AnnotationEngine: ObservableObject {
    @Published var annotations: [Annotation] = []
    @Published var selectedAnnotation: Annotation?
    @Published var currentTool: AnnotationType = .arrow
    @Published var currentColor: Color = .red
    @Published var currentStrokeWidth: CGFloat = 3
    @Published var currentFontSize: CGFloat = 16
    
    // 序号自动递增
    private var nextNumber: Int = 1
    
    // 历史记录（撤销/重做）
    private var undoStack: [[Annotation]] = []
    private var redoStack: [[Annotation]] = []
    private let maxUndoLevels = 50
    
    init() {
        // 从设置加载默认值
        currentColor = SettingsManager.shared.defaultAnnotationColor
        currentStrokeWidth = SettingsManager.shared.defaultStrokeWidth
        currentFontSize = SettingsManager.shared.defaultFontSize
    }
    
    // MARK: - Annotation Management
    
    /// 添加标注
    func addAnnotation(_ annotation: Annotation) {
        saveUndoState()
        var newAnnotation = annotation
        
        // 如果是序号标注，自动设置编号
        if annotation.type == .number {
            newAnnotation.number = nextNumber
            nextNumber += 1
        }
        
        annotations.append(newAnnotation)
    }
    
    /// 更新标注
    func updateAnnotation(_ annotation: Annotation) {
        saveUndoState()
        if let index = annotations.firstIndex(where: { $0.id == annotation.id }) {
            annotations[index] = annotation
        }
    }
    
    /// 删除标注
    func deleteAnnotation(_ annotation: Annotation) {
        saveUndoState()
        annotations.removeAll { $0.id == annotation.id }
        if selectedAnnotation?.id == annotation.id {
            selectedAnnotation = nil
        }
    }
    
    /// 删除选中的标注
    func deleteSelected() {
        guard let selected = selectedAnnotation else { return }
        deleteAnnotation(selected)
    }
    
    /// 清除所有标注
    func clearAll() {
        guard !annotations.isEmpty else { return }
        saveUndoState()
        annotations.removeAll()
        selectedAnnotation = nil
        nextNumber = 1
    }
    
    /// 选择标注
    func selectAnnotation(at point: CGPoint) {
        // 从上到下遍历（后添加的在上层）
        for annotation in annotations.reversed() {
            if annotation.contains(point: point) {
                selectedAnnotation = annotation
                return
            }
        }
        selectedAnnotation = nil
    }
    
    /// 取消选择
    func deselectAll() {
        selectedAnnotation = nil
    }
    
    // MARK: - Undo/Redo
    
    /// 撤销
    func undo() {
        guard !undoStack.isEmpty else { return }
        redoStack.append(annotations)
        annotations = undoStack.removeLast()
        selectedAnnotation = nil
    }
    
    /// 重做
    func redo() {
        guard !redoStack.isEmpty else { return }
        undoStack.append(annotations)
        annotations = redoStack.removeLast()
        selectedAnnotation = nil
    }
    
    var canUndo: Bool { !undoStack.isEmpty }
    var canRedo: Bool { !redoStack.isEmpty }
    
    private func saveUndoState() {
        undoStack.append(annotations)
        if undoStack.count > maxUndoLevels {
            undoStack.removeFirst()
        }
        redoStack.removeAll()
    }
    
    // MARK: - Layer Operations
    
    /// 将选中标注移到最上层
    func bringToFront() {
        guard let selected = selectedAnnotation,
              let index = annotations.firstIndex(where: { $0.id == selected.id }) else { return }
        saveUndoState()
        annotations.remove(at: index)
        annotations.append(selected)
    }
    
    /// 将选中标注移到最下层
    func sendToBack() {
        guard let selected = selectedAnnotation,
              let index = annotations.firstIndex(where: { $0.id == selected.id }) else { return }
        saveUndoState()
        annotations.remove(at: index)
        annotations.insert(selected, at: 0)
    }
    
    // MARK: - Rendering
    
    /// 渲染所有标注到图像
    func render(on image: NSImage) -> NSImage {
        let size = image.size
        let finalImage = NSImage(size: size)
        
        finalImage.lockFocus()
        
        // 先画原图
        image.draw(in: NSRect(origin: .zero, size: size))
        
        // 按顺序绘制标注
        for annotation in annotations {
            if annotation.type == .blur {
                applyBlur(annotation, on: finalImage)
            } else {
                annotation.draw()
            }
        }
        
        finalImage.unlockFocus()
        
        return finalImage
    }
    
    /// 应用模糊效果
    private func applyBlur(_ annotation: Annotation, on image: NSImage) {
        let rect = annotation.boundingRect()
        guard rect.width > 0 && rect.height > 0 else { return }
        
        // 获取区域图像
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let cropped = cgImage.cropping(to: rect) else { return }
        
        let ciImage = CIImage(cgImage: cropped)
        
        // 应用模糊滤镜
        let filter: CIFilter?
        switch annotation.blurType {
        case .gaussian:
            filter = CIFilter(name: "CIGaussianBlur")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(annotation.blurRadius, forKey: kCIInputRadiusKey)
            
        case .mosaic:
            filter = CIFilter(name: "CIPixellate")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(annotation.blurRadius * 2, forKey: kCIInputScaleKey)
            
        case .pixelate:
            filter = CIFilter(name: "CIPixellate")
            filter?.setValue(ciImage, forKey: kCIInputImageKey)
            filter?.setValue(annotation.blurRadius, forKey: kCIInputScaleKey)
        }
        
        guard let outputImage = filter?.outputImage else { return }
        
        let context = CIContext()
        guard let processedCGImage = context.createCGImage(outputImage, from: ciImage.extent) else { return }
        
        // 绘制处理后的图像
        let nsImage = NSImage(cgImage: processedCGImage, size: rect.size)
        nsImage.draw(in: rect)
    }
}

// MARK: - Image Processing Extensions

extension NSImage {
    /// 应用高斯模糊
    func applyGaussianBlur(radius: CGFloat) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()
        guard let resultCGImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }
        
        return NSImage(cgImage: resultCGImage, size: size)
    }
    
    /// 应用马赛克效果
    func applyPixelate(scale: CGFloat) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        
        let ciImage = CIImage(cgImage: cgImage)
        guard let filter = CIFilter(name: "CIPixellate") else { return nil }
        
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(scale, forKey: kCIInputScaleKey)
        
        guard let outputImage = filter.outputImage else { return nil }
        
        let context = CIContext()
        guard let resultCGImage = context.createCGImage(outputImage, from: ciImage.extent) else {
            return nil
        }
        
        return NSImage(cgImage: resultCGImage, size: size)
    }
    
    /// 裁剪图像
    func cropped(to rect: CGRect) -> NSImage? {
        guard let cgImage = self.cgImage(forProposedRect: nil, context: nil, hints: nil),
              let cropped = cgImage.cropping(to: rect) else {
            return nil
        }
        return NSImage(cgImage: cropped, size: NSSize(width: cropped.width, height: cropped.height))
    }
    
    /// 调整大小
    func resized(to newSize: NSSize) -> NSImage {
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        NSGraphicsContext.current?.imageInterpolation = .high
        draw(in: NSRect(origin: .zero, size: newSize),
             from: NSRect(origin: .zero, size: size),
             operation: .copy,
             fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
    
    /// 添加圆角
    func withRoundedCorners(radius: CGFloat) -> NSImage {
        let newImage = NSImage(size: size)
        newImage.lockFocus()
        
        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
        path.addClip()
        draw(in: rect)
        
        newImage.unlockFocus()
        return newImage
    }
    
    /// 添加阴影
    func withShadow(blur: CGFloat = 20, offset: CGFloat = 5, opacity: CGFloat = 0.3, padding: CGFloat = 40) -> NSImage {
        let newSize = NSSize(
            width: size.width + padding * 2,
            height: size.height + padding * 2
        )
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        let shadow = NSShadow()
        shadow.shadowColor = NSColor.black.withAlphaComponent(opacity)
        shadow.shadowOffset = NSSize(width: 0, height: -offset)
        shadow.shadowBlurRadius = blur
        shadow.set()
        
        let drawRect = NSRect(
            x: padding,
            y: padding,
            width: size.width,
            height: size.height
        )
        
        draw(in: drawRect)
        
        newImage.unlockFocus()
        return newImage
    }
    
    /// 添加背景
    func withBackground(color: NSColor, padding: CGFloat = 40) -> NSImage {
        let newSize = NSSize(
            width: size.width + padding * 2,
            height: size.height + padding * 2
        )
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        // 绘制背景
        color.setFill()
        NSRect(origin: .zero, size: newSize).fill()
        
        // 绘制图像
        let drawRect = NSRect(
            x: padding,
            y: padding,
            width: size.width,
            height: size.height
        )
        draw(in: drawRect)
        
        newImage.unlockFocus()
        return newImage
    }
    
    /// 添加渐变背景
    func withGradientBackground(colors: [NSColor], angle: CGFloat = 45, padding: CGFloat = 40) -> NSImage {
        let newSize = NSSize(
            width: size.width + padding * 2,
            height: size.height + padding * 2
        )
        
        let newImage = NSImage(size: newSize)
        newImage.lockFocus()
        
        // 绘制渐变背景
        if let gradient = NSGradient(colors: colors) {
            gradient.draw(in: NSRect(origin: .zero, size: newSize), angle: angle)
        }
        
        // 绘制图像
        let drawRect = NSRect(
            x: padding,
            y: padding,
            width: size.width,
            height: size.height
        )
        draw(in: drawRect)
        
        newImage.unlockFocus()
        return newImage
    }
}

// MARK: - Color Presets

extension AnnotationEngine {
    /// 预设颜色
    static let colorPresets: [Color] = [
        .red, .orange, .yellow, .green, .blue, .purple, .pink,
        .black, .white, .gray
    ]
    
    /// 预设笔画宽度
    static let strokeWidthPresets: [CGFloat] = [1, 2, 3, 5, 8, 12]
    
    /// 预设字体大小
    static let fontSizePresets: [CGFloat] = [12, 14, 16, 20, 24, 32, 48, 64]
}
