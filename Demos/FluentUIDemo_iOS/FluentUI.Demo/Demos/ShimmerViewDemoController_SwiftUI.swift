//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import FluentUI
import SwiftUI
import UIKit

class ShimmerViewDemoControllerSwiftUI: DemoHostingController {
    init() {
        super.init(rootView: AnyView(ShimmerViewDemoView()), title: "Shimmer View (SwiftUI)")
    }

    @objc required dynamic init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    @MainActor required dynamic init(rootView: AnyView) {
        preconditionFailure("init(rootView:) has not been implemented")
    }
}

struct ShimmerViewDemoView: View {
    @Environment(\.fluentTheme) var fluentTheme: FluentTheme

    var body: some View {
        ShimmerLines(style: .concealing, lineCount: 4, firstLineFillPercent: 0.20, lastLineFillPercent: 0.50)
    }
}
