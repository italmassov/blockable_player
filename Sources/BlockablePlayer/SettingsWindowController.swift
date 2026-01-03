import Cocoa

final class SettingsWindowController: NSWindowController {
    static let shared = SettingsWindowController()

    init() {
        let viewController = SettingsViewController()
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 280, height: 140),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "Settings"
        window.isReleasedWhenClosed = false
        window.center()
        window.contentViewController = viewController
        super.init(window: window)
    }

    required init?(coder: NSCoder) {
        nil
    }
}
