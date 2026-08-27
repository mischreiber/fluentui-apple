//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import UIKit

class BrandedSwitch: UISwitch {
    override init(frame: CGRect) {
        super.init(frame: frame)

        // Notifications are delivered synchronously on the thread that posted them, and
        // `.didChangeTheme` is only ever posted from the main actor. A target/selector observer keeps
        // this handler main actor-isolated, so the non-`Sendable` `Notification` never has to cross an
        // isolation boundary — unlike the block-based API, whose closure is `@Sendable`.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(themeDidChange(_:)),
                                               name: .didChangeTheme,
                                               object: nil)
    }

    @objc private func themeDidChange(_ notification: Notification) {
        guard FluentTheme.isApplicableThemeChange(notification, for: self) else {
            return
        }
        onTintColor = fluentTheme.color(.brandForeground1)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        guard let newWindow else {
            return
        }
        onTintColor = newWindow.fluentTheme.color(.brandForeground1)
    }
}
