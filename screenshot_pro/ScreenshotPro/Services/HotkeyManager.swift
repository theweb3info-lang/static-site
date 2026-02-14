//
//  HotkeyManager.swift
//  ScreenshotPro
//
//  Global hotkey management using Carbon Events
//

import SwiftUI
import Carbon.HIToolbox

// MARK: - Hotkey Manager

/// 全局快捷键管理器
class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var hotkeys: [String: RegisteredHotkey] = [:]
    private var eventHandlerRef: EventHandlerRef?
    
    private init() {
        setupEventHandler()
    }
    
    deinit {
        unregisterAll()
        if let handler = eventHandlerRef {
            RemoveEventHandler(handler)
        }
    }
    
    // MARK: - Public Methods
    
    /// 注册快捷键
    func register(keyCode: UInt32, modifiers: UInt32, id: String, handler: @escaping () -> Void) {
        // 如果已存在，先移除
        if hotkeys[id] != nil {
            unregister(id: id)
        }
        
        var hotkeyID = EventHotKeyID()
        hotkeyID.signature = OSType(id.hashValue & 0xFFFFFFFF)
        hotkeyID.id = UInt32(hotkeys.count + 1)
        
        var hotkeyRef: EventHotKeyRef?
        let carbonModifiers = convertToCarbonModifiers(modifiers)
        
        let status = RegisterEventHotKey(
            keyCode,
            carbonModifiers,
            hotkeyID,
            GetApplicationEventTarget(),
            0,
            &hotkeyRef
        )
        
        guard status == noErr, let ref = hotkeyRef else {
            print("Failed to register hotkey '\(id)': \(status)")
            return
        }
        
        hotkeys[id] = RegisteredHotkey(
            id: id,
            keyCode: keyCode,
            modifiers: modifiers,
            hotkeyRef: ref,
            hotkeyID: hotkeyID,
            handler: handler
        )
    }
    
    /// 注销快捷键
    func unregister(id: String) {
        guard let hotkey = hotkeys[id] else { return }
        UnregisterEventHotKey(hotkey.hotkeyRef)
        hotkeys.removeValue(forKey: id)
    }
    
    /// 注销所有快捷键
    func unregisterAll() {
        for (_, hotkey) in hotkeys {
            UnregisterEventHotKey(hotkey.hotkeyRef)
        }
        hotkeys.removeAll()
    }
    
    /// 更新快捷键
    func update(id: String, keyCode: UInt32, modifiers: UInt32) {
        guard let existing = hotkeys[id] else { return }
        let handler = existing.handler
        unregister(id: id)
        register(keyCode: keyCode, modifiers: modifiers, id: id, handler: handler)
    }
    
    // MARK: - Private Methods
    
    private func setupEventHandler() {
        var eventType = EventTypeSpec()
        eventType.eventClass = OSType(kEventClassKeyboard)
        eventType.eventKind = UInt32(kEventHotKeyPressed)
        
        let handler: EventHandlerUPP = { (_, event, _) -> OSStatus in
            var hotkeyID = EventHotKeyID()
            let status = GetEventParameter(
                event,
                EventParamName(kEventParamDirectObject),
                EventParamType(typeEventHotKeyID),
                nil,
                MemoryLayout<EventHotKeyID>.size,
                nil,
                &hotkeyID
            )
            
            guard status == noErr else { return status }
            
            // 查找并执行处理器
            DispatchQueue.main.async {
                for (_, hotkey) in HotkeyManager.shared.hotkeys {
                    if hotkey.hotkeyID.id == hotkeyID.id {
                        hotkey.handler()
                        break
                    }
                }
            }
            
            return noErr
        }
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            handler,
            1,
            &eventType,
            nil,
            &eventHandlerRef
        )
    }
    
    private func convertToCarbonModifiers(_ modifiers: UInt32) -> UInt32 {
        var carbonMods: UInt32 = 0
        
        if modifiers & UInt32(cmdKey) != 0 { carbonMods |= UInt32(cmdKey) }
        if modifiers & UInt32(shiftKey) != 0 { carbonMods |= UInt32(shiftKey) }
        if modifiers & UInt32(optionKey) != 0 { carbonMods |= UInt32(optionKey) }
        if modifiers & UInt32(controlKey) != 0 { carbonMods |= UInt32(controlKey) }
        
        return carbonMods
    }
}

// MARK: - Registered Hotkey

private struct RegisteredHotkey {
    let id: String
    let keyCode: UInt32
    let modifiers: UInt32
    let hotkeyRef: EventHotKeyRef
    let hotkeyID: EventHotKeyID
    let handler: () -> Void
}

// MARK: - Hotkey Recorder View

/// 快捷键录制视图
struct HotkeyRecorderView: View {
    @Binding var config: HotkeyConfig
    @State private var isRecording = false
    @State private var pendingKeyCode: UInt32?
    @State private var pendingModifiers: Set<HotkeyModifier> = []
    
    var body: some View {
        Button(action: { isRecording.toggle() }) {
            HStack {
                if isRecording {
                    if !pendingModifiers.isEmpty || pendingKeyCode != nil {
                        Text(displayString)
                            .foregroundColor(.primary)
                    } else {
                        Text("Press keys...")
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text(config.displayString)
                        .foregroundColor(.primary)
                }
            }
            .frame(minWidth: 100)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isRecording ? Color.accentColor.opacity(0.2) : Color(.windowBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(isRecording ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var displayString: String {
        var parts: [String] = []
        if pendingModifiers.contains(.control) { parts.append("⌃") }
        if pendingModifiers.contains(.option) { parts.append("⌥") }
        if pendingModifiers.contains(.shift) { parts.append("⇧") }
        if pendingModifiers.contains(.command) { parts.append("⌘") }
        if pendingKeyCode != nil { parts.append("...") }
        return parts.joined()
    }
}

// MARK: - Key Code Helpers

extension HotkeyManager {
    /// 获取按键名称
    static func keyName(for keyCode: UInt32) -> String {
        let keyMap: [UInt32: String] = [
            0x00: "A", 0x01: "S", 0x02: "D", 0x03: "F", 0x04: "H",
            0x05: "G", 0x06: "Z", 0x07: "X", 0x08: "C", 0x09: "V",
            0x0B: "B", 0x0C: "Q", 0x0D: "W", 0x0E: "E", 0x0F: "R",
            0x10: "Y", 0x11: "T", 0x12: "1", 0x13: "2", 0x14: "3",
            0x15: "4", 0x16: "6", 0x17: "5", 0x18: "=", 0x19: "9",
            0x1A: "7", 0x1B: "-", 0x1C: "8", 0x1D: "0", 0x1F: "O",
            0x20: "U", 0x22: "I", 0x23: "P", 0x25: "L", 0x26: "J",
            0x28: "K", 0x2D: "N", 0x2E: "M",
            0x7A: "F1", 0x78: "F2", 0x63: "F3", 0x76: "F4",
            0x60: "F5", 0x61: "F6", 0x62: "F7", 0x64: "F8",
            0x65: "F9", 0x6D: "F10", 0x67: "F11", 0x6F: "F12",
            0x24: "↩", 0x30: "⇥", 0x31: "Space", 0x33: "⌫", 0x35: "Esc"
        ]
        return keyMap[keyCode] ?? "?"
    }
    
    /// 检查快捷键是否已被系统使用
    static func isSystemHotkey(keyCode: UInt32, modifiers: UInt32) -> Bool {
        // 常见的系统快捷键
        let systemHotkeys: [(UInt32, UInt32)] = [
            (UInt32(kVK_ANSI_Q), UInt32(cmdKey)),  // ⌘Q
            (UInt32(kVK_ANSI_W), UInt32(cmdKey)),  // ⌘W
            (UInt32(kVK_ANSI_H), UInt32(cmdKey)),  // ⌘H
            (UInt32(kVK_Tab), UInt32(cmdKey)),      // ⌘Tab
        ]
        
        return systemHotkeys.contains { $0 == keyCode && $1 == modifiers }
    }
}
