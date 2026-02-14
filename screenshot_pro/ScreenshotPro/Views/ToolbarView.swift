//
//  ToolbarView.swift
//  ScreenshotPro
//
//  Reusable toolbar components — Beautify panel, presets
//

import SwiftUI

// MARK: - Beautify Panel

struct BeautifyPanel: View {
    @Binding var settings: BeautifySettings
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: SPSpacing.lg) {
                // Header
                Text("Beautify")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.secondary)
                
                // Presets
                VStack(alignment: .leading, spacing: SPSpacing.sm) {
                    Text("PRESETS")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.tertiary)
                        .tracking(1)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 65))], spacing: SPSpacing.sm) {
                        PresetButton(name: "Clean", colors: [.white, Color.gray.opacity(0.2)]) { applyPreset(.clean) }
                        PresetButton(name: "Gradient", colors: [.purple, .blue]) { applyPreset(.gradient) }
                        PresetButton(name: "Dark", colors: [Color(.darkGray), .black]) { applyPreset(.dark) }
                        PresetButton(name: "Ocean", colors: [.cyan, .blue]) { applyPreset(.ocean) }
                        PresetButton(name: "Sunset", colors: [.orange, .pink]) { applyPreset(.sunset) }
                        PresetButton(name: "Forest", colors: [.green, .mint]) { applyPreset(.forest) }
                    }
                }
                
                Divider()
                
                // Shadow
                SPSection("Shadow") {
                    Toggle("Enable", isOn: $settings.shadowEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                    
                    if settings.shadowEnabled {
                        SPSlider(label: "Blur", value: $settings.shadowBlur, range: 0...50)
                        SPSlider(label: "Offset", value: $settings.shadowOffset, range: 0...30)
                        SPSlider(label: "Opacity", value: $settings.shadowOpacity, range: 0...1)
                    }
                }
                
                Divider()
                
                // Corner Radius
                SPSection("Corners") {
                    SPSlider(label: "Radius", value: Binding(
                        get: { Double(settings.cornerRadius) },
                        set: { settings.cornerRadius = CGFloat($0) }
                    ), range: 0...30)
                }
                
                Divider()
                
                // Background
                SPSection("Background") {
                    Picker("Type", selection: $settings.backgroundType) {
                        ForEach(BackgroundType.allCases, id: \.self) { t in Text(t.rawValue).tag(t) }
                    }
                    .controlSize(.small)
                    
                    SPSlider(label: "Padding", value: Binding(
                        get: { Double(settings.padding) },
                        set: { settings.padding = CGFloat($0) }
                    ), range: 0...100)
                    
                    if settings.backgroundType == .solid {
                        ColorPicker("Color", selection: $settings.backgroundColor)
                            .controlSize(.small)
                    }
                    
                    if settings.backgroundType == .gradient {
                        GradientEditor(colors: $settings.gradientColors, angle: $settings.gradientAngle)
                    }
                }
                
                Divider()
                
                // Mockup
                SPSection("Device Mockup") {
                    Picker("Device", selection: $settings.mockupType) {
                        ForEach(MockupType.allCases, id: \.self) { t in Text(t.rawValue).tag(t) }
                    }
                    .controlSize(.small)
                }
                
                Divider()
                
                // Watermark
                SPSection("Watermark") {
                    Toggle("Enable", isOn: $settings.watermarkEnabled)
                        .toggleStyle(.switch)
                        .controlSize(.small)
                    
                    if settings.watermarkEnabled {
                        TextField("Text", text: $settings.watermarkText)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.small)
                        
                        Picker("Position", selection: $settings.watermarkPosition) {
                            ForEach(WatermarkPosition.allCases, id: \.self) { p in Text(p.rawValue).tag(p) }
                        }
                        .controlSize(.small)
                    }
                }
            }
            .padding(SPSpacing.lg)
        }
        .background(Color.surfacePrimary)
    }
    
    private func applyPreset(_ preset: BeautifyPreset) {
        withAnimation(.easeOut(duration: 0.2)) {
            switch preset {
            case .clean:
                settings.backgroundType = .solid
                settings.backgroundColor = .white
                settings.shadowEnabled = true
                settings.shadowBlur = 15; settings.cornerRadius = 8
            case .gradient:
                settings.backgroundType = .gradient
                settings.gradientColors = [Color(red: 0.4, green: 0.2, blue: 0.8), Color(red: 0.2, green: 0.6, blue: 0.9)]
                settings.shadowEnabled = true; settings.cornerRadius = 12
            case .dark:
                settings.backgroundType = .solid
                settings.backgroundColor = Color(white: 0.1)
                settings.shadowEnabled = true; settings.cornerRadius = 8
            case .ocean:
                settings.backgroundType = .gradient
                settings.gradientColors = [.cyan, .blue]
                settings.shadowEnabled = true; settings.cornerRadius = 12
            case .sunset:
                settings.backgroundType = .gradient
                settings.gradientColors = [.orange, .pink]
                settings.shadowEnabled = true; settings.cornerRadius = 12
            case .forest:
                settings.backgroundType = .gradient
                settings.gradientColors = [.green, .mint]
                settings.shadowEnabled = true; settings.cornerRadius = 12
            }
        }
    }
}

enum BeautifyPreset { case clean, gradient, dark, ocean, sunset, forest }

// MARK: - Reusable Components

struct SPSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SPSpacing.sm) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.tertiary)
                .tracking(1)
            
            content
        }
    }
}

struct SPSlider: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    
    var body: some View {
        VStack(spacing: 2) {
            HStack {
                Text(label)
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(value))")
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
            Slider(value: $value, in: range)
                .controlSize(.small)
        }
    }
}

// MARK: - Gradient Editor

struct GradientEditor: View {
    @Binding var colors: [Color]
    @Binding var angle: CGFloat
    
    var body: some View {
        VStack(spacing: SPSpacing.sm) {
            HStack {
                ForEach(0..<colors.count, id: \.self) { i in
                    ColorPicker("", selection: $colors[i])
                        .labelsHidden()
                        .controlSize(.small)
                }
                if colors.count < 5 {
                    Button(action: { colors.append(.gray) }) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 12))
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            SPSlider(label: "Angle", value: Binding(
                get: { Double(angle) },
                set: { angle = CGFloat($0) }
            ), range: 0...360)
            
            RoundedRectangle(cornerRadius: SPRadius.sm)
                .fill(LinearGradient(
                    colors: colors,
                    startPoint: gradientStart,
                    endPoint: gradientEnd
                ))
                .frame(height: 32)
        }
    }
    
    private var gradientStart: UnitPoint {
        let r = angle * .pi / 180
        return UnitPoint(x: 0.5 + 0.5 * cos(r + .pi), y: 0.5 + 0.5 * sin(r + .pi))
    }
    private var gradientEnd: UnitPoint {
        let r = angle * .pi / 180
        return UnitPoint(x: 0.5 + 0.5 * cos(r), y: 0.5 + 0.5 * sin(r))
    }
}

// MARK: - Preset Button

struct PresetButton: View {
    let name: String
    let colors: [Color]
    let action: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 3) {
                RoundedRectangle(cornerRadius: SPRadius.sm)
                    .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: SPRadius.sm)
                            .stroke(Color.primary.opacity(isHovering ? 0.15 : 0.06), lineWidth: 1)
                    )
                    .scaleEffect(isHovering ? 1.04 : 1.0)
                
                Text(name)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}

// MARK: - Annotation Toolbar (Side panel variant)

struct AnnotationToolbar: View {
    @ObservedObject var engine: AnnotationEngine
    
    var body: some View {
        VStack(spacing: SPSpacing.lg) {
            SPSection("Tools") {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 34))], spacing: SPSpacing.sm) {
                    ForEach(AnnotationType.allCases) { tool in
                        ToolIconButton(icon: tool.icon, isSelected: engine.currentTool == tool) {
                            engine.currentTool = tool
                        }
                        .help(tool.displayName)
                    }
                }
            }
            
            Divider()
            
            SPSection("Color") {
                ColorPicker("", selection: $engine.currentColor)
                    .labelsHidden()
                
                LazyVGrid(columns: Array(repeating: GridItem(.fixed(18)), count: 5), spacing: SPSpacing.xs) {
                    ForEach(AnnotationEngine.colorPresets, id: \.self) { color in
                        ColorDot(color: color, isSelected: engine.currentColor == color) {
                            engine.currentColor = color
                        }
                    }
                }
            }
            
            Divider()
            
            SPSection("Stroke") {
                HStack {
                    ForEach(AnnotationEngine.strokeWidthPresets, id: \.self) { width in
                        StrokeWidthButton(width: width, isSelected: engine.currentStrokeWidth == width) {
                            engine.currentStrokeWidth = width
                        }
                    }
                }
            }
            
            if engine.currentTool == .text {
                Divider()
                SPSection("Font Size") {
                    Picker("", selection: $engine.currentFontSize) {
                        ForEach(AnnotationEngine.fontSizePresets, id: \.self) { s in
                            Text("\(Int(s))pt").tag(s)
                        }
                    }
                    .pickerStyle(.menu)
                    .controlSize(.small)
                }
            }
            
            Spacer()
        }
        .padding(SPSpacing.lg)
        .frame(width: 170)
        .background(Color.surfacePrimary)
    }
}

// MARK: - Tool Icon Button

struct ToolIconButton: View {
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .frame(width: 34, height: 34)
                .background(
                    RoundedRectangle(cornerRadius: SPRadius.sm)
                        .fill(isSelected ? Color.brand : Color.primary.opacity(0.05))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Dot

struct ColorDot: View {
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 18, height: 18)
                .overlay(
                    Circle()
                        .stroke(isSelected ? Color.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
                        .padding(1.5)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stroke Width Button

struct StrokeWidthButton: View {
    let width: CGFloat
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: width / 2)
                .fill(Color.primary)
                .frame(width: 22, height: width)
                .padding(4)
                .background(
                    RoundedRectangle(cornerRadius: SPRadius.sm)
                        .fill(isSelected ? Color.brand.opacity(0.15) : Color.clear)
                )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HStack {
        AnnotationToolbar(engine: AnnotationEngine())
        BeautifyPanel(settings: .constant(BeautifySettings()))
    }
}
