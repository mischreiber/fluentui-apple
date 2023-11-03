//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

/// Representation of design tokens to controls at runtime which interfaces with the Design Token System auto-generated code.
/// Updating these properties causes the SwiftUI controls to update its view automatically.
public class PersonaButtonCarouselTokenSet: ControlTokenSet {
    public enum Tokens: TokenSetKey {
        /// The background color for the `PersonaButtonCarousel`.
        case backgroundColor
    }

    init() {
        super.init { token, theme in
            guard let token = token as? Tokens else { preconditionFailure() }
            switch token {
            case .backgroundColor:
                return .uiColor { theme.color(.background1) }
            }
        }
    }
}
