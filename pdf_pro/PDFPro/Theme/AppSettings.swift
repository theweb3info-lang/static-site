//
//  AppSettings.swift
//  PDF Pro
//

import SwiftUI

enum AppAppearance: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
}

final class AppSettings: ObservableObject {
    static let shared = AppSettings()

    @AppStorage("appearance") var appearance: AppAppearance = .system
    @AppStorage("defaultSaveLocation") var defaultSaveLocation: String = ""

    var colorScheme: ColorScheme? {
        switch appearance {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}
