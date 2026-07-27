//
//  NSScreen+Extensions.swift
//  DynamicNotchKit
//
//  Created by Kai Azim on 2024-04-06.
//

import SwiftUI

extension NSScreen {
    static var screenWithMouse: NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        let screens = NSScreen.screens
        let screenWithMouse = (screens.first { NSMouseInRect(mouseLocation, $0.frame, false) })

        return screenWithMouse
    }

    var hasNotch: Bool {
        auxiliaryTopLeftArea?.width != nil && auxiliaryTopRightArea?.width != nil
    }

    var notchSize: NSSize? {
        guard
            let topLeftNotchpadding: CGFloat = auxiliaryTopLeftArea?.width,
            let topRightNotchpadding: CGFloat = auxiliaryTopRightArea?.width
        else {
            return nil
        }

        let notchHeight = safeAreaInsets.top
        let notchWidth = frame.width - topLeftNotchpadding - topRightNotchpadding
        return .init(width: notchWidth, height: notchHeight)
    }

    var notchFrame: NSRect? {
        guard let notchSize else { return nil }
        return .init(
            x: frame.midX - (notchSize.width / 2),
            y: frame.maxY - notchSize.height,
            width: notchSize.width,
            height: notchSize.height
        )
    }

    var menubarHeight: CGFloat {
        // `visibleFrame` transiently reports no menu bar (or a wrong value)
        // while the system is mid-transition — a Dock size change (e.g. a
        // Continuity/Handoff icon appearing), a fullscreen Space switch. The
        // screen-parameters notification fires during exactly those moments,
        // so an unclamped read renders the fake notch at a visibly wrong
        // height. Clamp to the plausible menu bar range; 24pt is the standard
        // menu bar height on non-notched Macs.
        let measuredMenubarHeight = frame.maxY - visibleFrame.maxY
        guard measuredMenubarHeight >= 20, measuredMenubarHeight <= 44 else {
            return 24
        }
        return measuredMenubarHeight
    }

    var notchFrameWithMenubarAsBackup: NSRect {
        if let notchFrame {
            return notchFrame
        } else {
            let arbitraryNotchWidth: CGFloat = 200
            let arbitraryNotchHeight: CGFloat = menubarHeight

            let arbitraryNotchFrame = NSRect(
                x: frame.midX - (arbitraryNotchWidth / 2),
                y: frame.maxY - arbitraryNotchHeight,
                width: arbitraryNotchWidth,
                height: arbitraryNotchHeight
            )

            return arbitraryNotchFrame
        }
    }
}
