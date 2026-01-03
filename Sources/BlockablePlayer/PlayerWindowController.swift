import Cocoa

final class PlayerWindowController: NSWindowController, NSWindowDelegate {
    private let lockManager = LockManager.shared

    init() {
        let window = LockingWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1000, height: 700),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.title = "Blockable Player"
        window.isReleasedWhenClosed = false
        window.minSize = NSSize(width: 900, height: 700)
        window.center()

        let engine = EngineFactory.makeEngine()
        window.contentViewController = PlayerViewController(engine: engine)

        super.init(window: window)
        window.delegate = self
    }

    required init?(coder: NSCoder) {
        nil
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        lockManager.authorizeExit()
    }
}
