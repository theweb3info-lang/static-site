//
//  MergeView.swift
//  PDF Pro
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct MergeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var items: [MergeItem] = []
    @State private var isDragging = false
    @State private var isProcessing = false
    @State private var progress: Double = 0
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var body: some View {
        VStack(spacing: 0) {
            if items.isEmpty {
                dropZone
            } else {
                fileList
            }

            Divider()
            footer
        }
        .frame(minWidth: 600, minHeight: 450)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Merge PDFs")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                }
            }
        }
        .alert("Error", isPresented: .init(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK") { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "")
        }
    }

    // MARK: – Drop zone (empty state)

    private var dropZone: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.brandBlue.opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: "doc.on.doc")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color.brandBlue)
            }

            VStack(spacing: 6) {
                Text("Drop PDF files here")
                    .font(.title3.weight(.medium))
                Text("or click to browse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Choose Files…") { addFiles() }
                .buttonStyle(.borderedProminent)
                .tint(Color.brandBlue)
                .controlSize(.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .dropZoneStyle(isTargeted: isDragging, accentColor: .brandBlue)
        .padding(20)
        .onDrop(of: [.pdf, .fileURL], isTargeted: $isDragging, perform: handleDrop)
    }

    // MARK: – File list

    private var fileList: some View {
        List {
            ForEach(items) { item in
                MergeRow(item: item) { removeItem(item) }
            }
            .onMove(perform: moveItems)
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onDrop(of: [.pdf, .fileURL], isTargeted: $isDragging, perform: handleDrop)
    }

    // MARK: – Footer

    private var footer: some View {
        HStack(spacing: 12) {
            if !items.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "doc.fill")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Text("\(items.count) files · \(items.reduce(0) { $0 + $1.pageCount }) pages")
                        .foregroundStyle(.secondary)
                        .font(.callout)
                }
            }

            Spacer()

            if isProcessing {
                ProgressView(value: progress)
                    .frame(width: 120)
            }

            Button("Add Files…") { addFiles() }
                .disabled(isProcessing)

            Button {
                merge()
            } label: {
                Label("Merge", systemImage: "doc.on.doc.fill")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.brandBlue)
            .disabled(items.count < 2 || isProcessing)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: – Actions

    private func addFiles() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = true
        guard panel.runModal() == .OK else { return }
        for url in panel.urls { addFile(url) }
    }

    private func addFile(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() || true else { return }
        defer { url.stopAccessingSecurityScopedResource() }

        guard let doc = PDFDocument(url: url) else {
            errorMessage = "Cannot read \(url.lastPathComponent)"
            return
        }
        let thumbSize = CGSize(width: 48, height: 64)
        let thumb = doc.page(at: 0)?.thumbnail(of: thumbSize, for: .mediaBox)
        items.append(MergeItem(url: url, name: url.lastPathComponent, pageCount: doc.pageCount, thumbnail: thumb))
        errorMessage = nil
    }

    private func removeItem(_ item: MergeItem) {
        withAnimation(.easeOut(duration: 0.2)) {
            items.removeAll { $0.id == item.id }
        }
    }

    private func moveItems(from src: IndexSet, to dst: Int) {
        items.move(fromOffsets: src, toOffset: dst)
    }

    private func handleDrop(_ providers: [NSItemProvider]) -> Bool {
        for p in providers {
            if p.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                p.loadFileRepresentation(forTypeIdentifier: UTType.pdf.identifier) { url, _ in
                    guard let url else { return }
                    let tmp = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
                    try? FileManager.default.removeItem(at: tmp)
                    try? FileManager.default.copyItem(at: url, to: tmp)
                    DispatchQueue.main.async { addFile(tmp) }
                }
            } else if p.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                p.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                    guard let data = data as? Data,
                          let url = URL(dataRepresentation: data, relativeTo: nil),
                          url.pathExtension.lowercased() == "pdf" else { return }
                    DispatchQueue.main.async { addFile(url) }
                }
            }
        }
        return true
    }

    private func merge() {
        isProcessing = true
        progress = 0

        let totalPages = items.reduce(0) { $0 + $1.pageCount }
        let merged = PDFDocument()
        var pageIdx = 0

        Task.detached {
            for item in items {
                guard let doc = PDFDocument(url: item.url) else { continue }
                for i in 0..<doc.pageCount {
                    if let page = doc.page(at: i) {
                        merged.insert(page, at: pageIdx)
                        pageIdx += 1
                        let p = Double(pageIdx) / Double(max(totalPages, 1))
                        await MainActor.run { progress = p }
                    }
                }
            }

            await MainActor.run {
                let panel = NSSavePanel()
                panel.allowedContentTypes = [.pdf]
                panel.nameFieldStringValue = "Merged.pdf"
                panel.begin { resp in
                    isProcessing = false
                    guard resp == .OK, let url = panel.url else { return }
                    if merged.write(to: url) {
                        NSWorkspace.shared.open(url)
                    } else {
                        errorMessage = "Failed to save merged file"
                    }
                }
            }
        }
    }
}

// MARK: – Models

struct MergeItem: Identifiable {
    let id = UUID()
    let url: URL
    let name: String
    let pageCount: Int
    let thumbnail: NSImage?
}

// MARK: - Merge Row

private struct MergeRow: View {
    let item: MergeItem
    let onDelete: () -> Void
    @State private var isHovering = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: "line.3.horizontal")
                .font(.caption)
                .foregroundStyle(.tertiary)

            // Thumbnail
            Group {
                if let thumb = item.thumbnail {
                    Image(nsImage: thumb)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 36, height: 48)
            .background(Color(nsColor: .controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            .subtleShadow()

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.system(size: 13, weight: .medium))
                    .lineLimit(1)
                Text("\(item.pageCount) page\(item.pageCount == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if isHovering {
                Button { onDelete() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .transition(.opacity)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
        .animation(.easeOut(duration: 0.15), value: isHovering)
    }
}
