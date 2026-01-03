import Cocoa

final class TriangleVolumeSliderCell: NSSliderCell {
    override func drawBar(inside rect: NSRect, flipped: Bool) {
        let barRect = rect.insetBy(dx: 2, dy: rect.height * 0.0)
        let path = NSBezierPath()
        path.move(to: NSPoint(x: barRect.minX, y: barRect.maxY))
        path.line(to: NSPoint(x: barRect.minX, y: barRect.minY))
        path.line(to: NSPoint(x: barRect.maxX, y: barRect.midY))
        path.close()

        NSColor.tertiaryLabelColor.setFill()
        path.fill()

        let progress = CGFloat((doubleValue - minValue) / (maxValue - minValue))
        if progress > 0 {
            let clipRect = NSRect(x: barRect.minX, y: barRect.minY, width: barRect.width * progress, height: barRect.height)
            NSGraphicsContext.saveGraphicsState()
            NSBezierPath(rect: clipRect).addClip()
            NSColor.systemBlue.setFill()
            path.fill()
            NSGraphicsContext.restoreGraphicsState()
        }
    }

    override func drawKnob(_ knobRect: NSRect) {
        // No knob for the wedge-style volume control.
    }
}
