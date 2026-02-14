//
//  EditorView.swift
//  ScreenshotPro
//
//  Floating screenshot editor — clean toolbar + canvas + side panel
//

import SwiftUI
import UniformTypeIdentifiers

struct EditorView: View {
    @State var screenshot: Screenshot
    @StateObject private var annotationEngine = AnnotationEngine()
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var settings: SettingsManager
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var showingBeautifyPanel = false
    @State private var showingExportSheet = false
    
    var body: some View {
        HStack(spacing: 0) {
            // Main editor area
            VStack(spacing: 0) {
                editorToolbar
                
                Divider()
                
                // Canvas
                GeometryReader { geometry in
                    ZStack {
                        TransparencyGridView()
                        
                        CanvasView(
                            screenshot: screenshot,
                            annotationEngine: annotationEngine,
                            scale: scale,
                            offset: offset
                        )
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(magnificationGesture)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.windowBackgroundColor))
                    .clipped()
                }
                
                Divider()
                
                editorStatusBar
            }
            
            // Side panel
            if showingBeautifyPanel {
                Divider()
                
                BeautifyPanel(settings: $screenshot.beautifySettings)
                    .frame(width: 270)
                    .transition(.move(edge: .trailing).combined(with: .opacity))
            }
        }
        .frame(minWidth: 800, minHeight: 600)
        .background(Color.surfacePrimary)
        .onAppear {
            annotationEngine.annotations = screenshot.annotations
        }
        .onChange(of: annotationEngine.annotations) { newValue in
            screenshot.annotations = newValue
        }
        .fileExporter(
            isPresented: $showingExportSheet,
            document: ScreenshotDocument(screenshot: screenshot, engine: annotationEngine),
            contentType: .png,
            defaultFilename: "Screenshot_\(Date().formatted(date: .numeric, time: .omitted))"
        ) { _ in }
    }
    
    // MARK: - Toolbar
    
    private var editorToolbar: some View {
        HStack(spacing: SPSpacing.md) {
            // Tools
            HStack(spacing: 2) {
                ForEach(AnnotationType.allCases) { tool in
                    EditorToolButton(
                        icon: tool.icon,
                        label: tool.displayName,
                        isSelected: annotationEngine.currentTool == tool
                    ) {
                        annotationEngine.currentTool = tool
                    }
                }
            }
            .padding(3)
            .background(
                RoundedRectangle(cornerRadius: SPRadius.sm + 2)
                    .fill(Color.primary.opacity(0.04))
            )
            
            Divider().frame(height: 22)
            
            // Color
            ColorPicker("", selection: $annotationEngine.currentColor)
                .labelsHidden()
                .frame(width: 28)
            
            // Quick colors
            HStack(spacing: 3) {
                ForEach([Color.red, .orange, .yellow, .green, .blue, .purple], id: \.self) { color in
                    Circle()
                        .fill(color)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(annotationEngine.currentColor == color ? Color.primary.opacity(0.5) : Color.clear, lineWidth: 1.5)
                                .padding(1)
                        )
                        .onTapGesture { annotationEngine.currentColor = color }
                }
            }
            
            Divider().frame(height: 22)
            
            // Stroke width
            Picker("", selection: $annotationEngine.currentStrokeWidth) {
                ForEach(AnnotationEngine.strokeWidthPresets, id: \.self) { w in
                    Text("\(Int(w))").tag(w)
                }
            }
            .frame(width: 52)
            .labelsHidden()
            
            Spacer()
            
            // Actions
            HStack(spacing: SPSpacing.xxs) {
                Group {
                    Button(action: { annotationEngine.undo() }) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(!annotationEngine.canUndo)
                    .keyboardShortcut("z", modifiers: .command)
                    
                    Button(action: { annotationEngine.redo() }) {
                        Image(systemName: "arrow.uturn.forward")
                    }
                    .disabled(!annotationEngine.canRedo)
                    .keyboardShortcut("z", modifiers: [.command, .shift])
                }
                .font(.system(size: 13))
                .buttonStyle(.borderless)
                
                Divider().frame(height: 22)
                
                Button(action: { annotationEngine.deleteSelected() }) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                }
                .disabled(annotationEngine.selectedAnnotation == nil)
                .buttonStyle(.borderless)
                
                Divider().frame(height: 22)
                
                // Beautify toggle
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingBeautifyPanel.toggle()
                    }
                }) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 13))
                        .foregroundColor(showingBeautifyPanel ? .brand : .primary)
                }
                .buttonStyle(.borderless)
                .help("Beautify")
                
                Divider().frame(height: 22)
                
                // Copy
                Button(action: copyToClipboard) {
                    Image(systemName: "doc.on.clipboard")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .help("Copy to Clipboard")
                
                // Save
                Button(action: { showingExportSheet = true }) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 13))
                }
                .buttonStyle(.borderless)
                .help("Save As…")
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, SPSpacing.sm)
        .background(Color.surfacePrimary)
    }
    
    // MARK: - Status Bar
    
    private var editorStatusBar: some View {
        HStack {
            let size = screenshot.image?.size ?? .zero
            Text("\(Int(size.width)) × \(Int(size.height))")
                .font(.system(size: 11, design: .monospaced))
                .foregroundStyle(.tertiary)
            
            if annotationEngine.annotations.count > 0 {
                Text("•")
                    .foregroundStyle(.quaternary)
                Text("\(annotationEngine.annotations.count) annotations")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            
            Spacer()
            
            HStack(spacing: SPSpacing.sm) {
                Button(action: { scale = max(0.1, scale - 0.25) }) {
                    Image(systemName: "minus")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)
                
                Text("\(Int(scale * 100))%")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(width: 36)
                
                Button(action: { scale = min(5.0, scale + 0.25) }) {
                    Image(systemName: "plus")
                        .font(.system(size: 10))
                }
                .buttonStyle(.borderless)
                
                Button(action: { scale = 1.0 }) {
                    Text("Fit")
                        .font(.system(size: 10, weight: .medium))
                }
                .buttonStyle(.borderless)
            }
        }
        .padding(.horizontal, SPSpacing.md)
        .padding(.vertical, SPSpacing.xs)
        .background(Color.surfacePrimary)
    }
    
    // MARK: - Gestures
    
    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                scale = max(0.1, min(5.0, value))
            }
    }
    
    // MARK: - Actions
    
    private func copyToClipboard() {
        guard let image = screenshot.image else { return }
        let finalImage = annotationEngine.render(on: image)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([finalImage])
    }
}

// MARK: - Editor Tool Button

struct EditorToolButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .medium))
                .frame(width: 28, height: 26)
                .background(
                    RoundedRectangle(cornerRadius: SPRadius.sm)
                        .fill(isSelected ? Color.brand : Color.clear)
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
        .help(label)
    }
}

// MARK: - Canvas View

struct CanvasView: View {
    let screenshot: Screenshot
    @ObservedObject var annotationEngine: AnnotationEngine
    let scale: CGFloat
    let offset: CGSize
    
    @State private var currentAnnotation: Annotation?
    @State private var isDrawing = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = screenshot.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                ForEach(annotationEngine.annotations) { annotation in
                    AnnotationView(
                        annotation: annotation,
                        isSelected: annotationEngine.selectedAnnotation?.id == annotation.id
                    )
                    .onTapGesture {
                        annotationEngine.selectedAnnotation = annotation
                    }
                }
                
                if let current = currentAnnotation {
                    AnnotationView(annotation: current, isSelected: false)
                }
            }
            .contentShape(Rectangle())
            .gesture(drawingGesture(in: geometry))
        }
    }
    
    private func drawingGesture(in geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                let location = value.location
                
                if !isDrawing {
                    isDrawing = true
                    currentAnnotation = Annotation(
                        type: annotationEngine.currentTool,
                        startPoint: location,
                        color: annotationEngine.currentColor,
                        strokeWidth: annotationEngine.currentStrokeWidth
                    )
                } else {
                    currentAnnotation?.endPoint = location
                    if annotationEngine.currentTool == .freehand || annotationEngine.currentTool == .blur {
                        currentAnnotation?.pathPoints.append(location)
                    }
                }
            }
            .onEnded { value in
                isDrawing = false
                if var annotation = currentAnnotation {
                    annotation.endPoint = value.location
                    let minSize: CGFloat = 5
                    let w = abs(annotation.endPoint.x - annotation.startPoint.x)
                    let h = abs(annotation.endPoint.y - annotation.startPoint.y)
                    
                    if annotation.type == .number || annotation.type == .text {
                        annotationEngine.addAnnotation(annotation)
                    } else if w > minSize || h > minSize || !annotation.pathPoints.isEmpty {
                        annotationEngine.addAnnotation(annotation)
                    }
                }
                currentAnnotation = nil
            }
    }
}

// MARK: - Annotation View

struct AnnotationView: View {
    let annotation: Annotation
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            AnnotationShape(annotation: annotation)
                .stroke(annotation.color, lineWidth: annotation.strokeWidth)
            
            if isSelected {
                Rectangle()
                    .stroke(Color.brand, style: StrokeStyle(lineWidth: 1, dash: [4, 3]))
                    .frame(width: annotation.boundingRect().width + 8,
                           height: annotation.boundingRect().height + 8)
                    .position(
                        x: annotation.boundingRect().midX,
                        y: annotation.boundingRect().midY
                    )
            }
        }
    }
}

// MARK: - Annotation Shape

struct AnnotationShape: Shape {
    let annotation: Annotation
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        switch annotation.type {
        case .arrow:
            path.move(to: annotation.startPoint)
            path.addLine(to: annotation.endPoint)
            let angle = atan2(annotation.endPoint.y - annotation.startPoint.y,
                             annotation.endPoint.x - annotation.startPoint.x)
            let arrowAngle: CGFloat = .pi / 6
            let arrowSize = annotation.arrowHeadSize
            let p1 = CGPoint(x: annotation.endPoint.x - arrowSize * cos(angle - arrowAngle),
                            y: annotation.endPoint.y - arrowSize * sin(angle - arrowAngle))
            let p2 = CGPoint(x: annotation.endPoint.x - arrowSize * cos(angle + arrowAngle),
                            y: annotation.endPoint.y - arrowSize * sin(angle + arrowAngle))
            path.move(to: annotation.endPoint)
            path.addLine(to: p1)
            path.move(to: annotation.endPoint)
            path.addLine(to: p2)
            
        case .rectangle:
            let r = CGRect(x: min(annotation.startPoint.x, annotation.endPoint.x),
                          y: min(annotation.startPoint.y, annotation.endPoint.y),
                          width: abs(annotation.endPoint.x - annotation.startPoint.x),
                          height: abs(annotation.endPoint.y - annotation.startPoint.y))
            path.addRoundedRect(in: r, cornerSize: CGSize(width: 4, height: 4))
            
        case .ellipse:
            let r = CGRect(x: min(annotation.startPoint.x, annotation.endPoint.x),
                          y: min(annotation.startPoint.y, annotation.endPoint.y),
                          width: abs(annotation.endPoint.x - annotation.startPoint.x),
                          height: abs(annotation.endPoint.y - annotation.startPoint.y))
            path.addEllipse(in: r)
            
        case .line:
            path.move(to: annotation.startPoint)
            path.addLine(to: annotation.endPoint)
            
        case .freehand, .blur:
            guard !annotation.pathPoints.isEmpty else { break }
            path.move(to: annotation.pathPoints[0])
            for point in annotation.pathPoints.dropFirst() {
                path.addLine(to: point)
            }
            
        case .highlight:
            let r = CGRect(x: min(annotation.startPoint.x, annotation.endPoint.x),
                          y: min(annotation.startPoint.y, annotation.endPoint.y),
                          width: abs(annotation.endPoint.x - annotation.startPoint.x),
                          height: abs(annotation.endPoint.y - annotation.startPoint.y))
            path.addRect(r)
            
        default:
            break
        }
        
        return path
    }
}

// MARK: - Transparency Grid

struct TransparencyGridView: View {
    let gridSize: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                let rows = Int(size.height / gridSize) + 1
                let cols = Int(size.width / gridSize) + 1
                for row in 0..<rows {
                    for col in 0..<cols {
                        let rect = CGRect(x: CGFloat(col) * gridSize, y: CGFloat(row) * gridSize,
                                         width: gridSize, height: gridSize)
                        let color = (row + col) % 2 == 0 ? Color.white : Color.gray.opacity(0.15)
                        context.fill(Path(rect), with: .color(color))
                    }
                }
            }
        }
    }
}

// MARK: - Screenshot Document

@MainActor
struct ScreenshotDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.png, .jpeg] }
    
    let screenshot: Screenshot
    let engine: AnnotationEngine
    
    init(screenshot: Screenshot, engine: AnnotationEngine) {
        self.screenshot = screenshot
        self.engine = engine
    }
    
    init(configuration: ReadConfiguration) throws {
        throw CocoaError(.fileReadCorruptFile)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        guard let image = screenshot.image else { throw CocoaError(.fileWriteUnknown) }
        let finalImage = engine.render(on: image)
        guard let tiffData = finalImage.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData),
              let pngData = bitmap.representation(using: .png, properties: [:]) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: pngData)
    }
}

#Preview {
    let screenshot = Screenshot(image: NSImage(systemSymbolName: "photo", accessibilityDescription: nil)!, captureMode: .region)
    return EditorView(screenshot: screenshot)
        .environmentObject(AppState.shared)
        .environmentObject(SettingsManager.shared)
}
