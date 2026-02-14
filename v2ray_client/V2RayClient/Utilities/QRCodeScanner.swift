import Foundation
import AppKit
import CoreImage

class QRCodeScanner {
    
    // MARK: - Scan from Screen
    
    static func scanFromScreen(completion: @escaping (String?) -> Void) {
        // Take a screenshot of all screens
        guard let screenshot = captureScreen() else {
            completion(nil)
            return
        }
        
        // Detect QR codes
        if let qrContent = detectQRCode(in: screenshot) {
            completion(qrContent)
        } else {
            completion(nil)
        }
    }
    
    // MARK: - Scan from Image
    
    static func scanFromImage(_ image: NSImage) -> String? {
        return detectQRCode(in: image)
    }
    
    // MARK: - Scan from File
    
    static func scanFromFile(_ url: URL) -> String? {
        guard let image = NSImage(contentsOf: url) else {
            return nil
        }
        return detectQRCode(in: image)
    }
    
    // MARK: - Scan from Clipboard
    
    static func scanFromClipboard() -> String? {
        guard let image = NSPasteboard.general.readObjects(forClasses: [NSImage.self], options: nil)?.first as? NSImage else {
            return nil
        }
        return detectQRCode(in: image)
    }
    
    // MARK: - Generate QR Code
    
    static func generateQRCode(from string: String, size: CGSize = CGSize(width: 200, height: 200)) -> NSImage? {
        guard let data = string.data(using: .utf8),
              let filter = CIFilter(name: "CIQRCodeGenerator") else {
            return nil
        }
        
        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")
        
        guard let ciImage = filter.outputImage else {
            return nil
        }
        
        // Scale up the QR code
        let scaleX = size.width / ciImage.extent.size.width
        let scaleY = size.height / ciImage.extent.size.height
        let transformedImage = ciImage.transformed(by: CGAffineTransform(scaleX: scaleX, y: scaleY))
        
        // Convert to NSImage
        let rep = NSCIImageRep(ciImage: transformedImage)
        let nsImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        
        return nsImage
    }
    
    // MARK: - Private Methods
    
    private static func captureScreen() -> NSImage? {
        let screenRect = NSScreen.main?.frame ?? .zero
        
        guard let cgImage = CGWindowListCreateImage(
            screenRect,
            .optionOnScreenOnly,
            kCGNullWindowID,
            [.bestResolution]
        ) else {
            return nil
        }
        
        return NSImage(cgImage: cgImage, size: screenRect.size)
    }
    
    private static func detectQRCode(in image: NSImage) -> String? {
        guard let tiffData = image.tiffRepresentation,
              let bitmapImage = NSBitmapImageRep(data: tiffData),
              let ciImage = CIImage(bitmapImageRep: bitmapImage) else {
            return nil
        }
        
        let context = CIContext()
        let options: [String: Any] = [
            CIDetectorAccuracy: CIDetectorAccuracyHigh
        ]
        
        guard let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options) else {
            return nil
        }
        
        let features = detector.features(in: ciImage)
        
        for feature in features {
            if let qrFeature = feature as? CIQRCodeFeature,
               let message = qrFeature.messageString {
                return message
            }
        }
        
        return nil
    }
}

// MARK: - Screen Capture Permission

extension QRCodeScanner {
    static func requestScreenCapturePermission() -> Bool {
        // On macOS 10.15+, screen recording permission is required
        let testRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        if let _ = CGWindowListCreateImage(testRect, .optionOnScreenOnly, kCGNullWindowID, []) {
            return true
        }
        
        // Open System Preferences to Screen Recording
        if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ScreenCapture") {
            NSWorkspace.shared.open(url)
        }
        
        return false
    }
}

// MARK: - SwiftUI Integration

import SwiftUI

struct QRCodeView: View {
    let content: String
    let size: CGFloat
    
    var body: some View {
        if let image = QRCodeScanner.generateQRCode(from: content, size: CGSize(width: size, height: size)) {
            Image(nsImage: image)
                .interpolation(.none)
                .resizable()
                .frame(width: size, height: size)
        } else {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(width: size, height: size)
                .overlay {
                    Text("Failed to generate QR")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
        }
    }
}

struct QRCodeSheet: View {
    let server: ServerConfig
    @Environment(\.dismiss) var dismiss
    
    var shareLink: String {
        ConfigParser.generateShareLink(from: server)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text(server.name)
                .font(.headline)
            
            QRCodeView(content: shareLink, size: 200)
            
            Text(shareLink)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .truncationMode(.middle)
                .textSelection(.enabled)
            
            HStack {
                Button("Copy Link") {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(shareLink, forType: .string)
                }
                
                Button("Done") {
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(24)
        .frame(width: 300)
    }
}
