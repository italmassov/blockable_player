import Cocoa
import UniformTypeIdentifiers

final class PlayerViewController: NSViewController {
    private let engine: VideoEngine
    private let openButton = NSButton(title: "Open", target: nil, action: nil)
    private let fullScreenButton = NSButton(title: "Full Screen", target: nil, action: nil)
    private let playPauseButton = NSButton(title: "", target: nil, action: nil)
    private let playheadSlider = NSSlider(value: 0, minValue: 0, maxValue: 1, target: nil, action: nil)
    private let volumeSlider = NSSlider(value: 0.8, minValue: 0, maxValue: 1, target: nil, action: nil)
    private let volumeIcon = NSImageView()
    private let lockButton = NSButton(title: "Lock", target: nil, action: nil)
    private let unlockButton = NSButton(title: "Unlock Controls", target: nil, action: nil)
    private let closeButton = NSButton(title: "Close", target: nil, action: nil)
    private let settingsButton = NSButton(title: "Settings", target: nil, action: nil)
    private let lockLabel = NSTextField(labelWithString: "Locked")
    private let timeLabel = NSTextField(labelWithString: "--:-- / --:--")
    private let hudLabel = NSTextField(labelWithString: "")
    private var isLocked = false
    private var playheadTimer: Timer?
    private var lastSeekTime: Date?
    private var keyMonitor: Any?
    private var hudWorkItem: DispatchWorkItem?

    init(engine: VideoEngine) {
        self.engine = engine
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        nil
    }

    override func loadView() {
        view = NSView()
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.black.cgColor

        let videoView = engine.view
        videoView.translatesAutoresizingMaskIntoConstraints = false

        let controls = makeControlsBar()
        controls.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(videoView)
        view.addSubview(controls)

        hudLabel.translatesAutoresizingMaskIntoConstraints = false
        hudLabel.textColor = NSColor.white
        hudLabel.font = NSFont.systemFont(ofSize: 16, weight: .semibold)
        hudLabel.alphaValue = 0
        hudLabel.alignment = .center
        hudLabel.wantsLayer = true
        hudLabel.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.4).cgColor
        hudLabel.layer?.cornerRadius = 6
        hudLabel.isBezeled = false
        hudLabel.drawsBackground = false
        hudLabel.isEditable = false
        hudLabel.isSelectable = false
        view.addSubview(hudLabel)

        NSLayoutConstraint.activate([
            videoView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoView.topAnchor.constraint(equalTo: view.topAnchor),
            videoView.bottomAnchor.constraint(equalTo: controls.topAnchor),

            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controls.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            controls.heightAnchor.constraint(equalToConstant: 64),

            hudLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            hudLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
        ])

        let click = NSClickGestureRecognizer(target: self, action: #selector(videoClicked))
        videoView.addGestureRecognizer(click)

        engine.setVolume(Float(volumeSlider.doubleValue))
        volumeSlider.needsDisplay = true

        updateLockState()
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        playheadTimer?.invalidate()
        playheadTimer = Timer.scheduledTimer(withTimeInterval: 0.25, repeats: true) { [weak self] _ in
            self?.syncPlayhead()
        }
        if keyMonitor == nil {
            keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                guard let self else { return event }
                if self.handleKeyDown(event) {
                    return nil
                }
                return event
            }
        }
    }

    override func viewDidDisappear() {
        super.viewDidDisappear()
        playheadTimer?.invalidate()
        playheadTimer = nil
        if let keyMonitor {
            NSEvent.removeMonitor(keyMonitor)
            self.keyMonitor = nil
        }
    }

    private func makeControlsBar() -> NSView {
        let bar = NSView()
        bar.wantsLayer = true
        bar.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        openButton.target = self
        openButton.action = #selector(openFile)
        openButton.bezelStyle = .texturedRounded
        openButton.imagePosition = .imageOnly
        openButton.image = NSImage(systemSymbolName: "folder", accessibilityDescription: "Open")

        fullScreenButton.target = self
        fullScreenButton.action = #selector(enterFullScreen)

        playPauseButton.target = self
        playPauseButton.action = #selector(togglePlayPause)
        playPauseButton.bezelStyle = .texturedRounded
        playPauseButton.imagePosition = .imageOnly
        playPauseButton.image = NSImage(systemSymbolName: "play.fill", accessibilityDescription: "Play")

        playheadSlider.target = self
        playheadSlider.action = #selector(playheadChanged)
        playheadSlider.isContinuous = true

        volumeIcon.image = NSImage(systemSymbolName: "speaker.wave.2.fill", accessibilityDescription: "Volume")
        volumeIcon.contentTintColor = NSColor.secondaryLabelColor

        volumeSlider.target = self
        volumeSlider.action = #selector(volumeChanged)
        volumeSlider.isContinuous = true

        timeLabel.textColor = NSColor.secondaryLabelColor
        timeLabel.font = NSFont.monospacedDigitSystemFont(ofSize: 12, weight: .medium)
        timeLabel.alignment = .right

        lockButton.target = self
        lockButton.action = #selector(lockControls)

        closeButton.target = self
        closeButton.action = #selector(closeWindow)

        settingsButton.target = self
        settingsButton.action = #selector(openSettings)
        settingsButton.bezelStyle = .texturedRounded
        settingsButton.imagePosition = .imageOnly
        settingsButton.image = NSImage(systemSymbolName: "gearshape", accessibilityDescription: "Settings")

        lockLabel.textColor = NSColor.secondaryLabelColor
        lockLabel.font = NSFont.systemFont(ofSize: 12, weight: .medium)

        unlockButton.bezelStyle = .rounded
        unlockButton.target = self
        unlockButton.action = #selector(unlockControls)

        let spacer = NSView()
        spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacer.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        fullScreenButton.bezelStyle = .texturedRounded
        fullScreenButton.imagePosition = .imageOnly
        fullScreenButton.image = NSImage(systemSymbolName: "arrow.up.left.and.arrow.down.right", accessibilityDescription: "Full Screen")

        let volumeStack = NSStackView(views: [volumeIcon, volumeSlider])
        volumeStack.orientation = .horizontal
        volumeStack.alignment = .centerY
        volumeStack.spacing = 6

        let spacerRight = NSView()
        spacerRight.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerRight.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        let stack = NSStackView(views: [
            openButton,
            playPauseButton,
            playheadSlider,
            timeLabel,
            spacer,
            volumeStack,
            settingsButton,
            lockLabel,
            unlockButton,
            lockButton,
            closeButton,
            spacerRight,
            fullScreenButton
        ])
        stack.orientation = .horizontal
        stack.alignment = .centerY
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        bar.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: bar.trailingAnchor, constant: -16),
            stack.centerYAnchor.constraint(equalTo: bar.centerYAnchor)
        ])
        fullScreenButton.setContentHuggingPriority(.required, for: .horizontal)
        fullScreenButton.setContentCompressionResistancePriority(.required, for: .horizontal)
        fullScreenButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -12).isActive = true

        playheadSlider.setContentHuggingPriority(.defaultLow, for: .horizontal)
        playheadSlider.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        volumeSlider.widthAnchor.constraint(equalToConstant: 70).isActive = true
        volumeSlider.heightAnchor.constraint(equalToConstant: 24).isActive = true
        let minPlayheadWidth = NSLayoutConstraint(
            item: playheadSlider,
            attribute: .width,
            relatedBy: .greaterThanOrEqual,
            toItem: bar,
            attribute: .width,
            multiplier: 0.6,
            constant: 0
        )
        minPlayheadWidth.isActive = true

        return bar
    }

    private func updateLockState() {
        LockManager.shared.setLocked(isLocked)
        openButton.isEnabled = !isLocked
        fullScreenButton.isEnabled = !isLocked
        playPauseButton.isEnabled = !isLocked
        playheadSlider.isHidden = isLocked
        playheadSlider.isEnabled = !isLocked
        timeLabel.isHidden = isLocked
        volumeSlider.isEnabled = !isLocked
        volumeIcon.isHidden = isLocked
        lockLabel.stringValue = isLocked ? "Locked" : "Unlocked"
        unlockButton.isHidden = !isLocked
        lockButton.isHidden = isLocked
        closeButton.isHidden = isLocked
        fullScreenButton.isHidden = isLocked
        settingsButton.isHidden = isLocked
    }

    @objc private func openFile() {
        let panel = NSOpenPanel()
        if #available(macOS 12.0, *) {
            panel.allowedContentTypes = [
                UTType(filenameExtension: "mkv"),
                UTType.mpeg4Movie,
                UTType(filenameExtension: "mov"),
                UTType(filenameExtension: "m4v"),
                UTType(filenameExtension: "avi")
            ].compactMap { $0 }
        } else {
            panel.allowedFileTypes = ["mkv", "mp4", "mov", "m4v", "avi"]
        }
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false

        if panel.runModal() == .OK, let url = panel.url {
            engine.open(url: url)
            engine.play()
            showHUD("Playing")
        }
    }

    @objc private func volumeChanged() {
        engine.setVolume(Float(volumeSlider.doubleValue))
        showHUD("Volume \(Int(volumeSlider.doubleValue * 100))%")
    }

    @objc private func enterFullScreen() {
        view.window?.toggleFullScreen(nil)
        showHUD("Full Screen")
    }

    @objc private func togglePlayPause() {
        engine.togglePlayPause()
        playPauseButton.image = NSImage(
            systemSymbolName: engine.isPlaying() ? "pause.fill" : "play.fill",
            accessibilityDescription: engine.isPlaying() ? "Pause" : "Play"
        )
        showHUD(engine.isPlaying() ? "Play" : "Pause")
    }

    @objc private func playheadChanged() {
        lastSeekTime = Date()
        engine.seek(to: Float(playheadSlider.doubleValue))
        showHUD("Seek")
    }

    @objc private func unlockControls() {
        if LockManager.shared.authorizeUnlock() {
            isLocked = false
            updateLockState()
        }
    }

    @objc private func lockControls() {
        isLocked = true
        updateLockState()
    }

    @objc private func closeWindow() {
        view.window?.performClose(nil)
    }

    @objc private func openSettings() {
        SettingsWindowController.shared.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func videoClicked() {
        guard !isLocked else { return }
        togglePlayPause()
    }

    private func handleKeyDown(_ event: NSEvent) -> Bool {
        if event.modifierFlags.contains(.command),
           event.charactersIgnoringModifiers?.lowercased() == "l" {
            if isLocked {
                if LockManager.shared.authorizeUnlock() {
                    isLocked = false
                    updateLockState()
                }
            } else {
                isLocked = true
                updateLockState()
            }
            return true
        }
        if event.modifierFlags.contains(.control),
           event.charactersIgnoringModifiers?.lowercased() == "f" {
            enterFullScreen()
            return true
        }
        if event.modifierFlags.contains(.command),
           event.charactersIgnoringModifiers?.lowercased() == "f" {
            enterFullScreen()
            return true
        }
        guard !isLocked else { return false }
        if (event.modifierFlags.contains(.command) || event.modifierFlags.contains(.control)),
           event.charactersIgnoringModifiers?.lowercased() == "o" {
            openFile()
            return true
        }
        if event.modifierFlags.contains(.command),
           event.charactersIgnoringModifiers?.lowercased() == "w" {
            closeWindow()
            return true
        }
        if event.modifierFlags.contains(.command),
           event.charactersIgnoringModifiers?.lowercased() == "q" {
            NSApp.terminate(nil)
            return true
        }
        switch event.keyCode {
        case 49:
            togglePlayPause()
            return true
        case 123:
            engine.seek(by: -10)
            showHUD("-10s")
            return true
        case 124:
            engine.seek(by: 10)
            showHUD("+10s")
            return true
        case 125:
            adjustVolume(by: -0.05)
            return true
        case 126:
            adjustVolume(by: 0.05)
            return true
        default:
            return false
        }
    }

    private func adjustVolume(by delta: Double) {
        let next = max(0, min(1, volumeSlider.doubleValue + delta))
        volumeSlider.doubleValue = next
        engine.setVolume(Float(next))
        showHUD("Volume \(Int(next * 100))%")
    }

    private func syncPlayhead() {
        guard !isLocked else { return }
        if let lastSeekTime, Date().timeIntervalSince(lastSeekTime) < 0.35 {
            return
        }
        guard let position = engine.currentPosition() else { return }
        playheadSlider.doubleValue = Double(position)
        playPauseButton.image = NSImage(
            systemSymbolName: engine.isPlaying() ? "pause.fill" : "play.fill",
            accessibilityDescription: engine.isPlaying() ? "Pause" : "Play"
        )
        if let current = engine.currentTimeSeconds(),
           let duration = engine.durationSeconds() {
            timeLabel.stringValue = "\(formatTime(current)) / \(formatTime(duration))"
        } else {
            timeLabel.stringValue = "--:-- / --:--"
        }
    }

    private func showHUD(_ message: String) {
        hudWorkItem?.cancel()
        hudLabel.stringValue = "  \(message)  "
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.15
            hudLabel.animator().alphaValue = 1
        }
        let work = DispatchWorkItem { [weak self] in
            NSAnimationContext.runAnimationGroup { context in
                context.duration = 0.35
                self?.hudLabel.animator().alphaValue = 0
            }
        }
        hudWorkItem = work
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.9, execute: work)
    }

    private func formatTime(_ seconds: Double) -> String {
        let total = Int(seconds)
        let minutes = total / 60
        let secs = total % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}
