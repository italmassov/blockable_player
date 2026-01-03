import Cocoa
import CryptoKit

final class LockManager {
    static let shared = LockManager()

    private let store = KeychainStore(service: "com.example.blockableplayer")
    private let account = "pinHash"
    private var pinHash: String?
    private(set) var isLocked = false

    private init() {
        pinHash = store.read(account: account)
    }

    func ensurePinConfigured() {
        if pinHash != nil {
            return
        }
        if promptSetPin(force: true) {
            return
        }
        NSApp.terminate(nil)
    }

    func authorizeExit() -> Bool {
        if !isLocked {
            return true
        }
        guard let pinHash else { return false }
        let alert = NSAlert()
        alert.messageText = "Enter PIN to Exit"
        alert.informativeText = "Playback is locked. Enter the PIN to close the app."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Unlock")
        alert.addButton(withTitle: "Cancel")

        let input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.placeholderString = "PIN"
        alert.accessoryView = input

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return false }
        return LockManager.hash(pin: input.stringValue) == pinHash
    }

    func authorizeUnlock() -> Bool {
        guard let pinHash else { return false }
        let alert = NSAlert()
        alert.messageText = "Enter PIN to Unlock Controls"
        alert.informativeText = "Controls are locked. Enter the PIN to unlock."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Unlock")
        alert.addButton(withTitle: "Cancel")

        let input = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.placeholderString = "PIN"
        alert.accessoryView = input

        let response = alert.runModal()
        guard response == .alertFirstButtonReturn else { return false }
        return LockManager.hash(pin: input.stringValue) == pinHash
    }

    func setLocked(_ locked: Bool) {
        isLocked = locked
    }

    func promptSetPin(force: Bool) -> Bool {
        while true {
            let alert = NSAlert()
            alert.messageText = "Set a PIN"
            alert.informativeText = "Create a PIN to lock and unlock playback controls."
            alert.alertStyle = .informational
            alert.addButton(withTitle: "Save PIN")
            if !force {
                alert.addButton(withTitle: "Cancel")
            }

            let container = NSView(frame: NSRect(x: 0, y: 0, width: 240, height: 64))
            let pinField = NSSecureTextField(frame: NSRect(x: 0, y: 36, width: 240, height: 22))
            pinField.placeholderString = "Enter PIN"
            let confirmField = NSSecureTextField(frame: NSRect(x: 0, y: 6, width: 240, height: 22))
            confirmField.placeholderString = "Confirm PIN"
            container.addSubview(pinField)
            container.addSubview(confirmField)
            alert.accessoryView = container

            let response = alert.runModal()
            if response != .alertFirstButtonReturn {
                return false
            }

            let pin = pinField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            let confirm = confirmField.stringValue.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !pin.isEmpty else {
                showError("PIN cannot be empty.")
                continue
            }
            guard pin == confirm else {
                showError("PIN entries do not match.")
                continue
            }

            let hash = LockManager.hash(pin: pin)
            store.write(account: account, value: hash)
            pinHash = hash
            return true
        }
    }

    private func showError(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "PIN Error"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private static func hash(pin: String) -> String {
        let data = Data(pin.utf8)
        let digest = SHA256.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
