//
//  SplitView.swift
//  PDF Pro
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct SplitView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var sourceURL: URL?
    @State private var pdfDocument: PDFDocument?
    @State private var splitMode: SplitMode = .range
    @State private var rangeStart = 1
    @State private var rangeEnd = 1
    @State private var pagesPerFile = 1
    @State private var extractPages = ""
    @State private var isProcessing = false
    @State private var isDragging = false
    @State private var errorMessage: String?
    @State private var previewPage: NSImage?

    enum SplitMode: String, CaseIterable {
        case range = "Page Range"
        case everyN = "Every N Pages"
        case extract = "Extract Pages"

        var icon: String {
            switch self {
            case .range: return "doc.text.magnifyingglass"
            case .everyN: return "square.grid.3x3"
            case .extract: return "text.page.badge.magnifyingglass"
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if let doc = pdfDocument {
                splitControls(doc)
            } else {
                pickFileView
            }
        }
        .frame(minWidth: 560, minHeight: 420)
        .background(Color(nsColor: .windowBackgroundColor))
        .navigationTitle("Split PDF")
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

    // MARK: – Pick file

    private var pickFileView: some View {
        VStack(spacing: 20) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color(hex: 0xED8936).opacity(0.08))
                    .frame(width: 80, height: 80)

                Image(systemName: "scissors")
                    .font(.system(size: 32, weight: .light))
                    .foregroundStyle(Color(hex: 0xED8936))
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
                .tint(Color(hex: 0xED8936))
                .controlSize(.large)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(32)
        .dropZoneStyle(isTargeted: isDragging, accentColor: Color(hex: 0xED8936))
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

    // MARK: – Split controls

    private func splitControls(_ doc: PDFDocument) -> some View {
        HStack(spacing: 0) {
            // Left: Preview
            VStack {
                if let preview = previewPage {
                    Image(nsImage: preview)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 200, maxHeight: 280)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .subtleShadow()
                } else {
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(width: 160, height: 220)
                        .overlay {
                            Image(systemName: "doc.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(.tertiary)
                        }
                }

                Text("Page \(rangeStart) of \(doc.pageCount)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)
            }
            .frame(width: 240)
            .padding()

            Divider()

            // Right: Controls
            VStack(alignment: .leading, spacing: 0) {
                // File info bar
                HStack(spacing: 8) {
                    Image(systemName: "doc.fill")
                        .foregroundStyle(Color(hex: 0xED8936))
                    Text(sourceURL?.lastPathComponent ?? "PDF")
                        .font(.system(size: 13, weight: .medium))
                        .lineLimit(1)
                    Text("· \(doc.pageCount) pages")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Change…") { chooseFile() }
                        .controlSize(.small)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)

                Divider()

                // Mode picker
                Picker("", selection: $splitMode) {
                    ForEach(SplitMode.allCases, id: \.self) { mode in
                        Label(mode.rawValue, systemImage: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 20)
                .padding(.vertical, 16)

                // Mode-specific controls
                Group {
                    switch splitMode {
                    case .range:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Extract a range of pages")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("From").font(.caption).foregroundStyle(.secondary)
                                    TextField("", value: $rangeStart, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                }
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("To").font(.caption).foregroundStyle(.secondary)
                                    TextField("", value: $rangeEnd, format: .number)
                                        .textFieldStyle(.roundedBorder)
                                        .frame(width: 80)
                                }
                                Spacer()
                            }
                        }

                    case .everyN:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Split into chunks of N pages")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            HStack(spacing: 8) {
                                Text("Pages per file")
                                    .font(.system(size: 13))
                                TextField("", value: $pagesPerFile, format: .number)
                                    .textFieldStyle(.roundedBorder)
                                    .frame(width: 80)
                                Spacer()
                            }

                            if pagesPerFile > 0 {
                                let fileCount = (doc.pageCount + pagesPerFile - 1) / pagesPerFile
                                Text("Will create \(fileCount) file\(fileCount == 1 ? "" : "s")")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                    case .extract:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Pick specific pages")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            TextField("e.g. 1, 3, 5-8", text: $extractPages)
                                .textFieldStyle(.roundedBorder)

                            Text("Comma-separated page numbers or ranges")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
                .padding(.horizontal, 20)

                Spacer()

                Divider()

                // Action bar
                HStack {
                    Spacer()
                    Button {
                        performSplit(doc)
                    } label: {
                        Label("Split", systemImage: "scissors")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(hex: 0xED8936))
                    .controlSize(.large)
                    .disabled(isProcessing)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
            }
        }
        .onAppear {
            rangeEnd = doc.pageCount
            updatePreview(doc, page: 0)
        }
        .onChange(of: rangeStart) { _ in
            updatePreview(doc, page: max(0, rangeStart - 1))
        }
    }

    private func updatePreview(_ doc: PDFDocument, page: Int) {
        guard page >= 0, page < doc.pageCount else { return }
        previewPage = doc.page(at: page)?.thumbnail(of: CGSize(width: 400, height: 560), for: .mediaBox)
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
        sourceURL = url
        pdfDocument = doc
        rangeStart = 1
        rangeEnd = doc.pageCount
        pagesPerFile = 1
        extractPages = ""
        updatePreview(doc, page: 0)
    }

    private func performSplit(_ doc: PDFDocument) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.canCreateDirectories = true
        panel.prompt = "Select Output Folder"
        guard panel.runModal() == .OK, let outDir = panel.url else { return }

        isProcessing = true

        Task.detached {
            do {
                switch splitMode {
                case .range:
                    let start = max(1, rangeStart)
                    let end = min(rangeEnd, doc.pageCount)
                    guard start <= end else {
                        await MainActor.run {
                            errorMessage = "Invalid page range"
                            isProcessing = false
                        }
                        return
                    }
                    let newDoc = PDFDocument()
                    for i in (start - 1)..<end {
                        if let page = doc.page(at: i)?.copy() as? PDFPage {
                            newDoc.insert(page, at: newDoc.pageCount)
                        }
                    }
                    let out = outDir.appendingPathComponent("Pages_\(start)-\(end).pdf")
                    guard newDoc.write(to: out) else {
                        throw SplitError.writeFailed
                    }

                case .everyN:
                    let n = max(pagesPerFile, 1)
                    var chunk = PDFDocument()
                    var fileIdx = 1
                    for i in 0..<doc.pageCount {
                        if let page = doc.page(at: i)?.copy() as? PDFPage {
                            chunk.insert(page, at: chunk.pageCount)
                        }
                        if chunk.pageCount >= n || i == doc.pageCount - 1 {
                            let out = outDir.appendingPathComponent("Part_\(fileIdx).pdf")
                            guard chunk.write(to: out) else {
                                throw SplitError.writeFailed
                            }
                            chunk = PDFDocument()
                            fileIdx += 1
                        }
                    }

                case .extract:
                    let indices = parsePageList(extractPages, maxPage: doc.pageCount)
                    guard !indices.isEmpty else {
                        await MainActor.run {
                            errorMessage = "No valid pages specified"
                            isProcessing = false
                        }
                        return
                    }
                    let newDoc = PDFDocument()
                    for i in indices {
                        if let page = doc.page(at: i)?.copy() as? PDFPage {
                            newDoc.insert(page, at: newDoc.pageCount)
                        }
                    }
                    let out = outDir.appendingPathComponent("Extracted.pdf")
                    guard newDoc.write(to: out) else {
                        throw SplitError.writeFailed
                    }
                }

                await MainActor.run {
                    isProcessing = false
                    NSWorkspace.shared.open(outDir)
                }
            } catch {
                await MainActor.run {
                    isProcessing = false
                    errorMessage = "Failed to write output file"
                }
            }
        }
    }

    private func parsePageList(_ input: String, maxPage: Int) -> [Int] {
        var result: [Int] = []
        let parts = input.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        for part in parts {
            if part.contains("-") {
                let range = part.split(separator: "-").compactMap { Int($0) }
                guard range.count == 2 else { continue }
                let lo = min(range[0], range[1])
                let hi = max(range[0], range[1])
                for p in lo...hi where p >= 1 && p <= maxPage {
                    result.append(p - 1)
                }
            } else if let p = Int(part), p >= 1, p <= maxPage {
                result.append(p - 1)
            }
        }
        return result
    }
}

private enum SplitError: Error {
    case writeFailed
}
