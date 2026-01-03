import Cocoa

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var windowController: PlayerWindowController?
    private let lockManager = LockManager.shared

    func applicationDidFinishLaunching(_ notification: Notification) {
        lockManager.ensurePinConfigured()
        let controller = PlayerWindowController()
        windowController = controller
        controller.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refocusApp),
            name: NSApplication.didResignActiveNotification,
            object: nil
        )
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
        lockManager.authorizeExit() ? .terminateNow : .terminateCancel
    }

    @objc private func refocusApp() {
        guard LockManager.shared.isLocked else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}
