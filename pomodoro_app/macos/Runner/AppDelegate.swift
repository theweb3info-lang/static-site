import Cocoa
import FlutterMacOS
import IOKit.pwr_mgt

@main
class AppDelegate: FlutterAppDelegate {
    private var platformChannel: FlutterMethodChannel?
    
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        // Return false to keep app running in menu bar
        return false
    }

    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let controller = mainFlutterWindow?.contentViewController as! FlutterViewController
        
        platformChannel = FlutterMethodChannel(
            name: "com.pomodoro.app/platform",
            binaryMessenger: controller.engine.binaryMessenger
        )
        
        platformChannel?.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "lockScreen":
                self?.lockScreen(result: result)
            case "startScreensaver":
                self?.startScreensaver(result: result)
            case "sleepDisplay":
                self?.sleepDisplay(result: result)
            case "playSystemSound":
                if let args = call.arguments as? [String: Any],
                   let soundName = args["name"] as? String {
                    self?.playSystemSound(name: soundName, result: result)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Sound name required", details: nil))
                }
            case "isMenuBarMode":
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    /// Lock the screen using CGSession
    private func lockScreen(result: @escaping FlutterResult) {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        
        do {
            try task.run()
            task.waitUntilExit()
            
            // Alternative method: Use CGSession to lock
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let lockTask = Process()
                lockTask.launchPath = "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession"
                lockTask.arguments = ["-suspend"]
                
                do {
                    try lockTask.run()
                    result(true)
                } catch {
                    // If CGSession fails, the display sleep should still work
                    result(true)
                }
            }
        } catch {
            result(FlutterError(code: "LOCK_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    /// Start the screensaver
    private func startScreensaver(result: @escaping FlutterResult) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-a", "ScreenSaverEngine"]
        
        do {
            try task.run()
            result(true)
        } catch {
            result(FlutterError(code: "SCREENSAVER_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    /// Put the display to sleep
    private func sleepDisplay(result: @escaping FlutterResult) {
        let task = Process()
        task.launchPath = "/usr/bin/pmset"
        task.arguments = ["displaysleepnow"]
        
        do {
            try task.run()
            result(true)
        } catch {
            result(FlutterError(code: "SLEEP_FAILED", message: error.localizedDescription, details: nil))
        }
    }
    
    /// Play a system sound
    private func playSystemSound(name: String, result: @escaping FlutterResult) {
        if let sound = NSSound(named: NSSound.Name(name)) {
            sound.play()
            result(nil)
        } else {
            // Try to play as system sound file
            let soundPath = "/System/Library/Sounds/\(name).aiff"
            if let sound = NSSound(contentsOfFile: soundPath, byReference: true) {
                sound.play()
                result(nil)
            } else {
                NSSound.beep()
                result(nil)
            }
        }
    }
}
