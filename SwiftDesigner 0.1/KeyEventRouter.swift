import SwiftUI
import AppKit

struct KeyEventRouter: NSViewRepresentable {
    var onKeyDown: (NSEvent) -> Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(onKeyDown: onKeyDown)
    }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)

        context.coordinator.monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            if context.coordinator.onKeyDown(event) { return nil }
            return event
        }

        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        context.coordinator.onKeyDown = onKeyDown
    }

    static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
        if let m = coordinator.monitor { NSEvent.removeMonitor(m) }
    }

    final class Coordinator {
        var monitor: Any?
        var onKeyDown: (NSEvent) -> Bool
        init(onKeyDown: @escaping (NSEvent) -> Bool) { self.onKeyDown = onKeyDown }
    }
}