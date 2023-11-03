//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Design token set for the `Separator` control.
public class SeparatorTokenSet: ControlTokenSet {
    public enum Tokens: TokenSetKey {
        /// The color of the Separator
        case color
    }

    init() {
        super.init { token, theme in
            guard let token = token as? Tokens else { preconditionFailure() }
            switch token {
            case .color:
                return .uiColor { theme.color(.stroke2) }
            }
        }
    }
}

extension SeparatorTokenSet {
    /// The default thickness for the Separator: half pt.
    static var thickness: CGFloat { return GlobalTokens.stroke(.width05) }
}
