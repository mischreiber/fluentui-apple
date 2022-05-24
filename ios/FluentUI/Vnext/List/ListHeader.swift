//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit
import SwiftUI

struct Header: View, ConfigurableTokenizedControl {
    init(state: MSFListSectionStateImpl) {
        self.state = state
    }

    var body: some View {
        let backgroundColor: Color = {
            guard let stateBackgroundColor = state.backgroundColor else {
                return Color(dynamicColor: tokenValue(\.backgroundColor))
            }
            return Color(stateBackgroundColor)
        }()

        HStack(spacing: 0) {
            if let title = state.title, !title.isEmpty {
                Text(title)
                    .font(.fluent(tokenValue(\.textFont)))
                    .foregroundColor(Color(dynamicColor: tokenValue(\.textColor)))
            }
            Spacer()
        }
        .padding(EdgeInsets(top: tokenValue(\.topPadding),
                            leading: tokenValue(\.leadingPadding),
                            bottom: tokenValue(\.bottomPadding),
                            trailing: tokenValue(\.trailingPadding)))
        .frame(minHeight: tokenValue(\.headerHeight))
        .background(backgroundColor)
    }

    let defaultTokens: HeaderTokens = .init()
    @Environment(\.fluentTheme) var fluentTheme: FluentTheme
    @ObservedObject var state: MSFListSectionStateImpl
}
