//
//  HistoryManager.swift
//  ScreenshotPro
//
//  Screenshot history management with persistence
//

import SwiftUI
import Combine

// MARK: - History Manager

/// 截图历史管理器
@MainActor
class HistoryManager: ObservableObject {
    static let shared = HistoryManager()
    
    @Published private(set) var screenshots: [Screenshot] = []
    @Published var searchQuery: String = ""
    @Published var selectedDate: Date?
    @Published var sortOrder: SortOrder = .dateDescending
    
    private let storageDirectory: URL
    private let metadataFile: URL
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var filteredScreenshots: [Screenshot] {
        var result = screenshots
        
        // 按日期筛选
        if let date = selectedDate {
            let calendar = Calendar.current
            result = result.filter {
                calendar.isDate($0.createdAt, inSameDayAs: date)
            }
        }
        
        // 按搜索词筛选（匹配截图模式）
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.captureMode.rawValue.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        // 排序
        switch sortOrder {
        case .dateDescending:
            result.sort { $0.createdAt > $1.createdAt }
        case .dateAscending:
            result.sort { $0.createdAt < $1.createdAt }
        }
        
        return result
    }
    
    var groupedByDate: [Date: [Screenshot]] {
        let calendar = Calendar.current
        var groups: [Date: [Screenshot]] = [:]
        
        for screenshot in filteredScreenshots {
            let date = calendar.startOfDay(for: screenshot.createdAt)
            groups[date, default: []].append(screenshot)
        }
        
        return groups
    }
    
    var sortedDates: [Date] {
        groupedByDate.keys.sorted(by: >)
    }
    
    // MARK: - Initialization
    
    private init() {
        // 设置存储目录
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        storageDirectory = appSupport.appendingPathComponent("ScreenshotPro/History", isDirectory: true)
        metadataFile = storageDirectory.appendingPathComponent("metadata.json")
        
        // 创建目录
        try? FileManager.default.createDirectory(at: storageDirectory, withIntermediateDirectories: true)
        
        // 加载历史记录
        loadHistory()
        
        // 清理过期记录
        cleanupOldScreenshots()
    }
    
    // MARK: - Public Methods
    
    /// 添加截图到历史
    func add(_ screenshot: Screenshot) {
        var mutableScreenshot = screenshot
        
        // 保存图片文件
        do {
            try mutableScreenshot.saveImage(to: storageDirectory)
        } catch {
            print("Failed to save screenshot image: \(error)")
        }
        
        screenshots.insert(mutableScreenshot, at: 0)
        
        // 限制数量
        let maxItems = SettingsManager.shared.maxHistoryItems
        if screenshots.count > maxItems {
            let removed = screenshots.removeLast()
            deleteImageFile(for: removed)
        }
        
        saveMetadata()
    }
    
    /// 删除截图
    func delete(_ screenshot: Screenshot) {
        screenshots.removeAll { $0.id == screenshot.id }
        deleteImageFile(for: screenshot)
        saveMetadata()
    }
    
    /// 批量删除
    func delete(_ ids: Set<UUID>) {
        let toDelete = screenshots.filter { ids.contains($0.id) }
        screenshots.removeAll { ids.contains($0.id) }
        for screenshot in toDelete {
            deleteImageFile(for: screenshot)
        }
        saveMetadata()
    }
    
    /// 清空所有历史
    func clearAll() {
        for screenshot in screenshots {
            deleteImageFile(for: screenshot)
        }
        screenshots.removeAll()
        saveMetadata()
    }
    
    /// 根据 ID 获取截图
    func getScreenshot(by id: UUID) -> Screenshot? {
        screenshots.first { $0.id == id }
    }
    
    /// 导出截图
    func export(_ screenshot: Screenshot, to url: URL, format: ImageFormat = .png) throws {
        guard let image = screenshot.renderFinal() else {
            throw HistoryError.imageNotFound
        }
        
        guard let tiffData = image.tiffRepresentation,
              let bitmap = NSBitmapImageRep(data: tiffData) else {
            throw HistoryError.exportFailed
        }
        
        let data: Data?
        switch format {
        case .png:
            data = bitmap.representation(using: .png, properties: [:])
        case .jpeg:
            let quality = SettingsManager.shared.jpegQuality
            data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: quality])
        case .tiff:
            data = bitmap.representation(using: .tiff, properties: [:])
        case .heic:
            // HEIC 需要特殊处理，这里简化为 PNG
            data = bitmap.representation(using: .png, properties: [:])
        }
        
        guard let imageData = data else {
            throw HistoryError.exportFailed
        }
        
        try imageData.write(to: url)
    }
    
    // MARK: - Private Methods
    
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: metadataFile.path) else { return }
        
        do {
            let data = try Data(contentsOf: metadataFile)
            screenshots = try JSONDecoder().decode([Screenshot].self, from: data)
        } catch {
            print("Failed to load history: \(error)")
        }
    }
    
    private func saveMetadata() {
        do {
            let data = try JSONEncoder().encode(screenshots)
            try data.write(to: metadataFile)
        } catch {
            print("Failed to save history metadata: \(error)")
        }
    }
    
    private func deleteImageFile(for screenshot: Screenshot) {
        let imageURL = storageDirectory.appendingPathComponent("\(screenshot.id.uuidString).png")
        try? FileManager.default.removeItem(at: imageURL)
    }
    
    private func cleanupOldScreenshots() {
        let retentionDays = SettingsManager.shared.historyRetentionDays
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -retentionDays, to: Date()) ?? Date()
        
        let oldScreenshots = screenshots.filter { $0.createdAt < cutoffDate }
        for screenshot in oldScreenshots {
            deleteImageFile(for: screenshot)
        }
        
        screenshots.removeAll { $0.createdAt < cutoffDate }
        
        if !oldScreenshots.isEmpty {
            saveMetadata()
        }
    }
    
    /// 获取历史存储大小
    func getStorageSize() -> Int64 {
        var size: Int64 = 0
        
        if let enumerator = FileManager.default.enumerator(at: storageDirectory, includingPropertiesForKeys: [.fileSizeKey]) {
            while let fileURL = enumerator.nextObject() as? URL {
                do {
                    let resourceValues = try fileURL.resourceValues(forKeys: [.fileSizeKey])
                    size += Int64(resourceValues.fileSize ?? 0)
                } catch {}
            }
        }
        
        return size
    }
    
    /// 格式化存储大小
    func formattedStorageSize() -> String {
        let size = getStorageSize()
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
}

// MARK: - Supporting Types

enum SortOrder: String, CaseIterable {
    case dateDescending = "Newest First"
    case dateAscending = "Oldest First"
}

enum HistoryError: LocalizedError {
    case imageNotFound
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .imageNotFound:
            return "Screenshot image not found"
        case .exportFailed:
            return "Failed to export screenshot"
        }
    }
}

// MARK: - History Item View

struct HistoryItemView: View {
    let screenshot: Screenshot
    let isSelected: Bool
    let onSelect: () -> Void
    let onOpen: () -> Void
    let onDelete: () -> Void
    
    @State private var isHovering = false
    
    var body: some View {
        VStack(spacing: 8) {
            // 缩略图
            ZStack {
                if let image = screenshot.image {
                    Image(nsImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 120)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.title)
                                .foregroundColor(.gray)
                        )
                }
                
                // 悬浮操作按钮
                if isHovering {
                    VStack {
                        Spacer()
                        HStack(spacing: 8) {
                            Button(action: onOpen) {
                                Image(systemName: "pencil")
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            
                            Button(action: onDelete) {
                                Image(systemName: "trash")
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(8)
                    }
                }
            }
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            
            // 信息
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Image(systemName: screenshot.captureMode.icon)
                        .font(.caption)
                    Text(screenshot.captureMode.rawValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Text(screenshot.createdAt.formatted(date: .omitted, time: .shortened))
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(8)
        .background(isHovering ? Color.gray.opacity(0.1) : Color.clear)
        .cornerRadius(12)
        .onTapGesture { onSelect() }
        .onHover { isHovering = $0 }
        .contextMenu {
            Button("Open in Editor") { onOpen() }
            Button("Copy to Clipboard") { copyToClipboard() }
            Divider()
            Button("Show in Finder") { showInFinder() }
            Divider()
            Button("Delete", role: .destructive) { onDelete() }
        }
    }
    
    private func copyToClipboard() {
        guard let image = screenshot.image else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.writeObjects([image])
    }
    
    private func showInFinder() {
        let storageDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            .appendingPathComponent("ScreenshotPro/History")
        let imageURL = storageDirectory.appendingPathComponent("\(screenshot.id.uuidString).png")
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            NSWorkspace.shared.activateFileViewerSelecting([imageURL])
        }
    }
}
