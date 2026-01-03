import Cocoa

final class SettingsViewController: NSViewController {
    private let changePinButton = NSButton(title: "Change PIN", target: nil, action: nil)

    override func loadView() {
        view = NSView()
        view.translatesAutoresizingMaskIntoConstraints = false

        let label = NSTextField(labelWithString: "Security")
        label.font = NSFont.systemFont(ofSize: 14, weight: .semibold)

        changePinButton.target = self
        changePinButton.action = #selector(changePin)
        changePinButton.bezelStyle = .rounded

        let stack = NSStackView(views: [label, changePinButton])
        stack.orientation = .vertical
        stack.alignment = .leading
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            view.widthAnchor.constraint(equalToConstant: 280),
            view.heightAnchor.constraint(equalToConstant: 140)
        ])
    }

    @objc private func changePin() {
        _ = LockManager.shared.promptSetPin(force: false)
    }
}
