//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import FluentUI

/// Definition of a DemoController
struct DemoDescriptor: Identifiable, Hashable {
    let title: String
    let id = UUID()
}

let demos: [DemoDescriptor] = [
    DemoDescriptor(title: "Button")
]

struct ContentView: View {
    @State private var currentDemo: DemoDescriptor?
    @State var date = Date()

    var body: some View {
        NavigationSplitView {
            List(demos, selection: $currentDemo) { demo in
                NavigationLink(demo.title, value: demo)
            }
        } detail: {
            if let title = currentDemo?.title {
                DetailView(value: title)
            } else {
                Text("Choose a link")
            }
        }
    }

    struct DetailView: View {
        var value: String

        var body: some View {
            Text("\(value)")
                .font(.largeTitle)
        }
    }
}

#Preview {
    ContentView()
}
