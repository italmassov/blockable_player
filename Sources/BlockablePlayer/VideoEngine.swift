import Cocoa

protocol VideoEngine {
    var view: NSView { get }
    func open(url: URL)
    func play()
    func togglePlayPause()
    func isPlaying() -> Bool
    func setVolume(_ value: Float)
    func currentPosition() -> Float?
    func seek(to position: Float)
    func seek(by seconds: Double)
    func currentTimeSeconds() -> Double?
    func durationSeconds() -> Double?
}

enum EngineFactory {
    static func makeEngine() -> VideoEngine {
        if let engine = LibVlcEngine() {
            return engine
        }
        return PlaceholderEngine()
    }
}

final class PlaceholderEngine: VideoEngine {
    private let label: NSTextField

    init() {
        label = NSTextField(labelWithString: "libVLC failed to initialize. Video playback is disabled.")
        label.alignment = .center
        label.font = NSFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = NSColor.secondaryLabelColor
    }

    var view: NSView {
        label
    }

    func open(url: URL) {
        // No-op without a playback engine.
    }

    func play() {
        // No-op without a playback engine.
    }

    func togglePlayPause() {
        // No-op without a playback engine.
    }

    func isPlaying() -> Bool {
        false
    }

    func setVolume(_ value: Float) {
        // No-op without a playback engine.
    }

    func currentPosition() -> Float? {
        nil
    }

    func seek(to position: Float) {
        // No-op without a playback engine.
    }

    func seek(by seconds: Double) {
        // No-op without a playback engine.
    }

    func currentTimeSeconds() -> Double? {
        nil
    }

    func durationSeconds() -> Double? {
        nil
    }
}
