//
//  Annotation.swift
//  ScreenshotPro
//
//  Annotation models for screenshot markup
//

import SwiftUI

// MARK: - Annotation Protocol

/// 标注基础协议
protocol AnnotationProtocol: Identifiable, Codable {
    var id: UUID { get }
    var type: AnnotationType { get }
    var color: Color { get set }
    var strokeWidth: CGFloat { get set }
    var isSelected: Bool { get set }
    
    func draw()
    func contains(point: CGPoint) -> Bool
    func boundingRect() -> CGRect
}

// MARK: - Annotation Type

enum AnnotationType: String, Codable, CaseIterable, Identifiable {
    case arrow = "Arrow"
    case rectangle = "Rectangle"
    case ellipse = "Ellipse"
    case line = "Line"
    case text = "Text"
    case blur = "Blur"
    case highlight = "Highlight"
    case number = "Number"
    case freehand = "Freehand"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .arrow: return "arrow.up.right"
        case .rectangle: return "rectangle"
        case .ellipse: return "circle"
        case .line: return "line.diagonal"
        case .text: return "textformat"
        case .blur: return "eye.slash"
        case .highlight: return "highlighter"
        case .number: return "number"
        case .freehand: return "pencil.tip"
        }
    }
    
    var displayName: String { rawValue }
}

// MARK: - Annotation (Main Type)

/// 通用标注类型，包含所有可能的标注数据
struct Annotation: Identifiable, Codable, Equatable {
    static func == (lhs: Annotation, rhs: Annotation) -> Bool {
        lhs.id == rhs.id && lhs.type == rhs.type && lhs.startPoint == rhs.startPoint && lhs.endPoint == rhs.endPoint && lhs.strokeWidth == rhs.strokeWidth && lhs.text == rhs.text && lhs.number == rhs.number && lhs.isSelected == rhs.isSelected
    }
    
    let id: UUID
    var type: AnnotationType
    var color: Color
    var strokeWidth: CGFloat
    var isSelected: Bool = false
    
    // 位置和大小
    var startPoint: CGPoint
    var endPoint: CGPoint
    var rotation: Double = 0
    
    // 文字标注属性
    var text: String = ""
    var fontSize: CGFloat = 16
    var fontName: String = "SF Pro"
    var isBold: Bool = false
    var isItalic: Bool = false
    
    // 序号标注属性
    var number: Int = 1
    
    // 自由绘制路径
    var pathPoints: [CGPoint] = []
    
    // 模糊属性
    var blurRadius: CGFloat = 10
    var blurType: BlurType = .gaussian
    
    // 箭头属性
    var arrowHeadSize: CGFloat = 15
    var arrowStyle: ArrowStyle = .filled
    
    // 形状填充
    var isFilled: Bool = false
    var fillOpacity: Double = 0.3
    
    init(type: AnnotationType, startPoint: CGPoint, color: Color = .red, strokeWidth: CGFloat = 3) {
        self.id = UUID()
        self.type = type
        self.startPoint = startPoint
        self.endPoint = startPoint
        self.color = color
        self.strokeWidth = strokeWidth
    }
    
    // MARK: - Drawing
    
    func draw() {
        let nsColor = NSColor(color)
        nsColor.setStroke()
        
        switch type {
        case .arrow:
            drawArrow()
        case .rectangle:
            drawRectangle()
        case .ellipse:
            drawEllipse()
        case .line:
            drawLine()
        case .text:
            drawText()
        case .blur:
            // 模糊在渲染时特殊处理
            break
        case .highlight:
            drawHighlight()
        case .number:
            drawNumber()
        case .freehand:
            drawFreehand()
        }
    }
    
    private func drawArrow() {
        let path = NSBezierPath()
        path.lineWidth = strokeWidth
        path.lineCapStyle = .round
        
        // 画线
        path.move(to: startPoint)
        path.line(to: endPoint)
        NSColor(color).setStroke()
        path.stroke()
        
        // 画箭头
        let angle = atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x)
        let arrowAngle: CGFloat = .pi / 6
        
        let point1 = CGPoint(
            x: endPoint.x - arrowHeadSize * cos(angle - arrowAngle),
            y: endPoint.y - arrowHeadSize * sin(angle - arrowAngle)
        )
        let point2 = CGPoint(
            x: endPoint.x - arrowHeadSize * cos(angle + arrowAngle),
            y: endPoint.y - arrowHeadSize * sin(angle + arrowAngle)
        )
        
        let arrowPath = NSBezierPath()
        arrowPath.move(to: endPoint)
        arrowPath.line(to: point1)
        arrowPath.line(to: point2)
        arrowPath.close()
        
        if arrowStyle == .filled {
            NSColor(color).setFill()
            arrowPath.fill()
        }
        arrowPath.stroke()
    }
    
    private func drawRectangle() {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        
        let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        path.lineWidth = strokeWidth
        
        if isFilled {
            NSColor(color).withAlphaComponent(fillOpacity).setFill()
            path.fill()
        }
        
        NSColor(color).setStroke()
        path.stroke()
    }
    
    private func drawEllipse() {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        
        let path = NSBezierPath(ovalIn: rect)
        path.lineWidth = strokeWidth
        
        if isFilled {
            NSColor(color).withAlphaComponent(fillOpacity).setFill()
            path.fill()
        }
        
        NSColor(color).setStroke()
        path.stroke()
    }
    
    private func drawLine() {
        let path = NSBezierPath()
        path.lineWidth = strokeWidth
        path.lineCapStyle = .round
        path.move(to: startPoint)
        path.line(to: endPoint)
        NSColor(color).setStroke()
        path.stroke()
    }
    
    private func drawText() {
        var attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor(color),
            .font: NSFont.systemFont(ofSize: fontSize, weight: isBold ? .bold : .regular)
        ]
        
        if let font = NSFont(name: fontName, size: fontSize) {
            var traits: NSFontTraitMask = []
            if isBold { traits.insert(.boldFontMask) }
            if isItalic { traits.insert(.italicFontMask) }
            let modifiedFont = NSFontManager.shared.convert(font, toHaveTrait: traits)
            attributes[.font] = modifiedFont
        }
        
        let string = NSAttributedString(string: text, attributes: attributes)
        string.draw(at: startPoint)
    }
    
    private func drawHighlight() {
        let rect = CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(endPoint.x - startPoint.x),
            height: abs(endPoint.y - startPoint.y)
        )
        
        NSColor(color).withAlphaComponent(0.4).setFill()
        let path = NSBezierPath(rect: rect)
        path.fill()
    }
    
    private func drawNumber() {
        let size: CGFloat = 28
        let rect = CGRect(x: startPoint.x - size/2, y: startPoint.y - size/2, width: size, height: size)
        
        // 画圆形背景
        let circlePath = NSBezierPath(ovalIn: rect)
        NSColor(color).setFill()
        circlePath.fill()
        
        // 画数字
        let text = "\(number)"
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: NSColor.white,
            .font: NSFont.systemFont(ofSize: 16, weight: .bold)
        ]
        
        let string = NSAttributedString(string: text, attributes: attributes)
        let textSize = string.size()
        let textRect = CGRect(
            x: startPoint.x - textSize.width/2,
            y: startPoint.y - textSize.height/2,
            width: textSize.width,
            height: textSize.height
        )
        string.draw(in: textRect)
    }
    
    private func drawFreehand() {
        guard pathPoints.count > 1 else { return }
        
        let path = NSBezierPath()
        path.lineWidth = strokeWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        path.move(to: pathPoints[0])
        for point in pathPoints.dropFirst() {
            path.line(to: point)
        }
        
        NSColor(color).setStroke()
        path.stroke()
    }
    
    // MARK: - Hit Testing
    
    func contains(point: CGPoint) -> Bool {
        let tolerance: CGFloat = 10
        
        switch type {
        case .arrow, .line:
            return distanceToLine(from: startPoint, to: endPoint, point: point) < tolerance
            
        case .rectangle, .highlight:
            let rect = boundingRect().insetBy(dx: -tolerance, dy: -tolerance)
            return rect.contains(point)
            
        case .ellipse:
            return boundingRect().insetBy(dx: -tolerance, dy: -tolerance).contains(point)
            
        case .text:
            let textRect = CGRect(x: startPoint.x, y: startPoint.y, width: 200, height: fontSize + 10)
            return textRect.contains(point)
            
        case .number:
            let size: CGFloat = 28
            let rect = CGRect(x: startPoint.x - size/2, y: startPoint.y - size/2, width: size, height: size)
            return rect.contains(point)
            
        case .freehand, .blur:
            for pathPoint in pathPoints {
                if hypot(point.x - pathPoint.x, point.y - pathPoint.y) < tolerance {
                    return true
                }
            }
            return false
        }
    }
    
    func boundingRect() -> CGRect {
        switch type {
        case .number:
            let size: CGFloat = 28
            return CGRect(x: startPoint.x - size/2, y: startPoint.y - size/2, width: size, height: size)
            
        case .text:
            return CGRect(x: startPoint.x, y: startPoint.y, width: 200, height: fontSize + 10)
            
        case .freehand, .blur:
            guard !pathPoints.isEmpty else {
                return CGRect(origin: startPoint, size: .zero)
            }
            let minX = pathPoints.map { $0.x }.min() ?? 0
            let maxX = pathPoints.map { $0.x }.max() ?? 0
            let minY = pathPoints.map { $0.y }.min() ?? 0
            let maxY = pathPoints.map { $0.y }.max() ?? 0
            return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
            
        default:
            return CGRect(
                x: min(startPoint.x, endPoint.x),
                y: min(startPoint.y, endPoint.y),
                width: abs(endPoint.x - startPoint.x),
                height: abs(endPoint.y - startPoint.y)
            )
        }
    }
    
    private func distanceToLine(from start: CGPoint, to end: CGPoint, point: CGPoint) -> CGFloat {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = hypot(dx, dy)
        
        if length == 0 {
            return hypot(point.x - start.x, point.y - start.y)
        }
        
        let t = max(0, min(1, ((point.x - start.x) * dx + (point.y - start.y) * dy) / (length * length)))
        let nearestX = start.x + t * dx
        let nearestY = start.y + t * dy
        
        return hypot(point.x - nearestX, point.y - nearestY)
    }
}

// MARK: - Supporting Types

enum BlurType: String, Codable, CaseIterable {
    case gaussian = "Gaussian"
    case mosaic = "Mosaic"
    case pixelate = "Pixelate"
}

enum ArrowStyle: String, Codable, CaseIterable {
    case filled = "Filled"
    case outline = "Outline"
    case open = "Open"
}
