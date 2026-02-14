//
//  PDFProApp.swift
//  PDF Pro — Merge · Split · Rearrange
//
//  macOS 13.0+  •  Swift + SwiftUI + PDFKit
//

import SwiftUI

@main
struct PDFProApp: App {
    @StateObject private var settings = AppSettings.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .preferredColorScheme(settings.colorScheme)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 800, height: 600)
        .commands {
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appInfo) {
                Button("About PDF Pro") {
                    NSApp.orderFrontStandardAboutPanel(options: aboutOptions)
                }
            }
        }

        Settings {
            SettingsView()
                .preferredColorScheme(settings.colorScheme)
        }
    }

    private var aboutOptions: [NSApplication.AboutPanelOptionKey: Any] {
        [
            .applicationName: "PDF Pro",
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            .version: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1",
            .credits: NSAttributedString(
                string: "Merge · Split · Rearrange\nYour PDFs, handled locally & privately.",
                attributes: [
                    .font: NSFont.systemFont(ofSize: 11),
                    .foregroundColor: NSColor.secondaryLabelColor
                ]
            )
        ]
    }
}
