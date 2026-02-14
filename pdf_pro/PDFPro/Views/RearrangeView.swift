//
//  RearrangeView.swift
//  PDF Pro
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct RearrangeView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var sourceURL: URL?
    @State private var pages: [PageItem] = []
    @State private var isDragging = false
    @State private var selection = Set<UUID>()
    @State private var hasChanges = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let columns = [GridItem(.adaptive(minimum: 130), spacing: 18)]

    var body: some View {
        VStack(spacing: 0) {
            if pages.isEmpty && !isLoading {
                pickFileView
            } else if isLoading {
                ProgressView("Loading pages…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                pageGrid
                Divider()
                footer
            }
        }
        .frame(minWidth: 640, minHeight: 500)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Rearrange Pages")
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button { dismiss() } label: {
                    Label("Back", systemImage: "chevron.left")
                        .labelStyle(.iconOnly)
                }
            }
            if !pages.isEmpty {
                ToolbarItem(placement: .primaryAction) {
                    Button("Change File…") { chooseFile() }
                        .controlSize(.small)
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

    // MARK: – Pick file

    private var pickFileView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: 0x9F7AEA).opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: "rectangle.grid.2x2")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color(hex: 0x9F7AEA))
            }

            VStack(spacing: 6) {
                Text("Drop a PDF here")
                    .font(.title3.weight(.medium))
                Text("or click to browse")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Button("Choose File…") { chooseFile() }
                .buttonStyle(.borderedProminent)
                .tint(Color(hex: 0x9F7AEA))
                .controlSize(.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .dropZoneStyle(isTargeted: isDragging, accentColor: Color(hex: 0x9F7AEA))
        .padding(20)
        .onDrop(of: [.pdf, .fileURL], isTargeted: $isDragging) { providers in
            for p in providers {
                if p.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                    p.loadItem(forTypeIdentifier: UTType.fileURL.identifier) { data, _ in
                        guard let data = data as? Data,
                              let url = URL(dataRepresentation: data, relativeTo: nil),
                              url.pathExtension.lowercased() == "pdf" else { return }
                        DispatchQueue.main.async { loadFile(url) }
                    }
                }
            }
            return true
        }
    }

    // MARK: – Page grid

    private var pageGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                ForEach(pages) { page in
                    PageThumbnailView(
                        page: page,
                        isSelected: selection.contains(page.id)
                    )
                    .onTapGesture {
                        withAnimation(.easeOut(duration: 0.15)) {
                            if selection.contains(page.id) {
                                selection.remove(page.id)
                            } else {
                                selection.insert(page.id)
                            }
                        }
                    }
                    .draggable(page.id.uuidString) {
                        PageThumbnailView(page: page, isSelected: true)
                            .frame(width: 90, height: 130)
                    }
                    .dropDestination(for: String.self) { dropped, _ in
                        guard let droppedId = dropped.first,
                              let dragUUID = UUID(uuidString: droppedId),
                              let fromIdx = pages.firstIndex(where: { $0.id == dragUUID }),
                              let toIdx = pages.firstIndex(where: { $0.id == page.id }),
                              fromIdx != toIdx else { return false }
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            pages.move(fromOffsets: IndexSet(integer: fromIdx),
                                       toOffset: toIdx > fromIdx ? toIdx + 1 : toIdx)
                        }
                        hasChanges = true
                        return true
                    }
                    .contextMenu {
                        Button { rotatePage(page, by: -90) } label: {
                            Label("Rotate Left", systemImage: "rotate.left")
                        }
                        Button { rotatePage(page, by: 90) } label: {
                            Label("Rotate Right", systemImage: "rotate.right")
                        }
                        Divider()
                        Button(role: .destructive) { deletePage(page) } label: {
                            Label("Delete Page", systemImage: "trash")
                        }
                    }
                }
            }
            .padding(20)
        }
    }

    // MARK: – Footer

    private var footer: some View {
        HStack(spacing: 12) {
            HStack(spacing: 4) {
                Image(systemName: "doc.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Text("\(pages.count) pages")
                    .foregroundStyle(.secondary)
                    .font(.callout)
            }

            if !selection.isEmpty {
                Button(role: .destructive) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        pages.removeAll { selection.contains($0.id) }
                        selection.removeAll()
                        hasChanges = true
                    }
                } label: {
                    Label("Delete \(selection.count)", systemImage: "trash")
                }
                .controlSize(.small)
            }

            Spacer()

            if hasChanges, sourceURL != nil {
                Button("Overwrite Original") { save(to: sourceURL!) }
                    .controlSize(.small)
            }

            Button {
                saveAs()
            } label: {
                Label("Save As…", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: 0x9F7AEA))
            .disabled(!hasChanges && selection.isEmpty)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
    }

    // MARK: – Actions

    private func chooseFile() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.pdf]
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        loadFile(url)
    }

    private func loadFile(_ url: URL) {
        guard let doc = PDFDocument(url: url) else {
            errorMessage = "Cannot read \(url.lastPathComponent)"
            return
        }
        isLoading = true
        sourceURL = url
        selection.removeAll()
        hasChanges = false

        Task.detached {
            var newPages: [PageItem] = []
            let thumbSize = CGSize(width: 180, height: 240)
            for i in 0..<doc.pageCount {
                guard let page = doc.page(at: i) else { continue }
                let thumb = page.thumbnail(of: thumbSize, for: .mediaBox)
                newPages.append(PageItem(
                    originalIndex: i,
                    thumbnail: thumb,
                    rotation: page.rotation,
                    pdfPage: page
                ))
            }
            await MainActor.run {
                pages = newPages
                isLoading = false
            }
        }
    }

    private func deletePage(_ page: PageItem) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            pages.removeAll { $0.id == page.id }
            selection.remove(page.id)
            hasChanges = true
        }
    }

    private func rotatePage(_ page: PageItem, by degrees: Int) {
        guard let idx = pages.firstIndex(where: { $0.id == page.id }) else { return }
        pages[idx].rotation = (pages[idx].rotation + degrees + 360) % 360
        pages[idx].pdfPage.rotation = pages[idx].rotation
        let thumbSize = CGSize(width: 180, height: 240)
        pages[idx].thumbnail = pages[idx].pdfPage.thumbnail(of: thumbSize, for: .mediaBox)
        hasChanges = true
    }

    private func buildDocument() -> PDFDocument {
        let doc = PDFDocument()
        for (i, item) in pages.enumerated() {
            if let copy = item.pdfPage.copy() as? PDFPage {
                copy.rotation = item.rotation
                doc.insert(copy, at: i)
            }
        }
        return doc
    }

    private func saveAs() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.pdf]
        panel.nameFieldStringValue = sourceURL?.lastPathComponent ?? "Rearranged.pdf"
        guard panel.runModal() == .OK, let url = panel.url else { return }
        save(to: url)
    }

    private func save(to url: URL) {
        let doc = buildDocument()
        if doc.write(to: url) {
            hasChanges = false
        } else {
            errorMessage = "Failed to save file"
        }
    }
}

// MARK: – Models

struct PageItem: Identifiable {
    let id = UUID()
    let originalIndex: Int
    var thumbnail: NSImage
    var rotation: Int
    var pdfPage: PDFPage
}

// MARK: – Thumbnail view

private struct PageThumbnailView: View {
    let page: PageItem
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 8) {
            Image(nsImage: page.thumbnail)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 110, height: 150)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(
                            isSelected ? Color(hex: 0x9F7AEA) : Color.black.opacity(0.06),
                            lineWidth: isSelected ? 2.5 : 0.5
                        )
                }
                .shadow(color: .black.opacity(0.1), radius: isSelected ? 6 : 3, y: isSelected ? 3 : 1)

            Text("\(page.originalIndex + 1)")
                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? Color(hex: 0x9F7AEA) : .secondary)
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isSelected ? Color(hex: 0x9F7AEA).opacity(0.08) : .clear)
        }
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}
