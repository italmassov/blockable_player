import Cocoa

final class LockingWindow: NSWindow {
    override func keyDown(with event: NSEvent) {
        if LockManager.shared.isLocked {
            let blockedWhenLocked: Set<UInt16> = [49, 53, 123, 124]
            if blockedWhenLocked.contains(event.keyCode) {
                return
            }
        }
        super.keyDown(with: event)
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        if LockManager.shared.isLocked {
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers == "w" {
                return true
            }
            if event.modifierFlags.contains(.command),
               event.charactersIgnoringModifiers == "q" {
                return true
            }
        }
        return super.performKeyEquivalent(with: event)
    }
}
