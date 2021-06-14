//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

/// UIKit wrapper that exposes the SwiftUI Avatar implementation
@objc open class MSFAvatar: NSObject, FluentUIWindowProvider {

    @objc open var view: UIView {
        return hostingController.view
    }

    @objc open var state: MSFAvatarState!

    @objc public convenience init(style: MSFAvatarStyle = .default,
                                  size: MSFAvatarSize = .large) {
        self.init(style: style,
                  size: size,
                  theme: nil)
    }

    @objc public init(style: MSFAvatarStyle = .default,
                      size: MSFAvatarSize = .large,
                      theme: FluentUIStyle? = nil) {
        super.init()

        let avatarState = AvatarState(style: style,
                                      size: size)

        let avatarview = AvatarView(avatarState)

        state = avatarState
        hostingController = UIHostingController(rootView: AnyView(avatarview
                                                                    .windowProvider(self)
                                                                    .modifyIf(theme != nil, { avatarview in
                                                                        avatarview.customTheme(theme!)
                                                                    })))
        hostingController.disableSafeAreaInsets()
        view.backgroundColor = UIColor.clear
    }

    var window: UIWindow? {
        return self.view.window
    }

    private var hostingController: UIHostingController<AnyView>!

    private var avatarview: AvatarView!
}
