//
//  HistoryView.swift
//  ScreenshotPro
//
//  Screenshot history browser — grid layout with hover actions
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var historyManager: HistoryManager
    @EnvironmentObject var appState: AppState
    
    @State private var selectedIds = Set<UUID>()
    @State private var showingDeleteConfirmation = false
    @State private var viewMode: ViewMode = .grid
    
    private let columns = [GridItem(.adaptive(minimum: 200), spacing: SPSpacing.lg)]
    
    enum ViewMode: String, CaseIterable {
        case grid, list
        var icon: String { self == .grid ? "square.grid.2x2" : "list.bullet" }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            HStack(spacing: SPSpacing.md) {
                // Search
                HStack(spacing: SPSpacing.sm) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 12))
                        .foregroundStyle(.tertiary)
                    TextField("Search…", text: $historyManager.searchQuery)
                        .textFieldStyle(.plain)
                        .font(.system(size: 13))
                }
                .padding(.horizontal, SPSpacing.sm)
                .padding(.vertical, SPSpacing.xs)
                .background(
                    RoundedRectangle(cornerRadius: SPRadius.sm)
                        .fill(Color.primary.opacity(0.04))
                )
                .frame(maxWidth: 220)
                
                Picker("Sort", selection: $historyManager.sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Text(order.rawValue).tag(order)
                    }
                }
                .frame(width: 140)
                
                // View mode toggle
                Picker("", selection: $viewMode) {
                    ForEach(ViewMode.allCases, id: \.self) { mode in
                        Image(systemName: mode.icon).tag(mode)
                    }
                }
                .pickerStyle(.segmented)
                .frame(width: 80)
                
                Spacer()
                
                if !selectedIds.isEmpty {
                    Button("Delete (\(selectedIds.count))", role: .destructive) {
                        showingDeleteConfirmation = true
                    }
                    .controlSize(.small)
                }
            }
            .padding(.horizontal, SPSpacing.lg)
            .padding(.vertical, SPSpacing.md)
            
            Divider()
            
            // Content
            if historyManager.filteredScreenshots.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: SPSpacing.lg) {
                        ForEach(historyManager.filteredScreenshots) { screenshot in
                            HistoryItemView(
                                screenshot: screenshot,
                                isSelected: selectedIds.contains(screenshot.id),
                                onSelect: { toggleSelection(screenshot.id) },
                                onOpen: { openEditor(for: screenshot) },
                                onDelete: { historyManager.delete(screenshot) }
                            )
                        }
                    }
                    .padding(SPSpacing.lg)
                }
            }
            
            Divider()
            
            // Status
            HStack {
                Text("\(historyManager.filteredScreenshots.count) screenshots")
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(historyManager.formattedStorageSize())
                    .font(.system(size: 11))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, SPSpacing.lg)
            .padding(.vertical, SPSpacing.xs)
        }
        .background(Color.surfacePrimary)
        .confirmationDialog("Delete Selected?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete \(selectedIds.count) Screenshots", role: .destructive) {
                historyManager.delete(selectedIds)
                selectedIds.removeAll()
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: SPSpacing.lg) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 44))
                .foregroundStyle(.quaternary)
            Text("No Screenshots Yet")
                .font(.system(size: 16, weight: .medium))
                .foregroundStyle(.secondary)
            Text("Captured screenshots will appear here")
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func toggleSelection(_ id: UUID) {
        if selectedIds.contains(id) { selectedIds.remove(id) }
        else { selectedIds.insert(id) }
    }
    
    private func openEditor(for screenshot: Screenshot) {
        let editorWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 900, height: 700),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered, defer: false
        )
        editorWindow.center()
        editorWindow.title = "Edit Screenshot"
        editorWindow.contentView = NSHostingView(
            rootView: EditorView(screenshot: screenshot)
                .environmentObject(appState)
                .environmentObject(SettingsManager.shared)
        )
        editorWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
