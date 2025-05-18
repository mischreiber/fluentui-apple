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

    public var body: some View {
        VStack {
            previewContent
            settingsList
        }
    }

    @ViewBuilder
    private var previewContent: some View {
        switch shimmerDemoContent {
        case .shimmerLabel:
            VStack {
                Text("This is a single label being shimmered.")
                    .padding(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .shimmering(style: style,
                        usesTextHeightForLabels: usesTextHeightForLabels,
                        animationId: namespace,
                        isLabel: true)
            .padding()

        case .shimmerMultipleLines:
            ShimmerLines(style: style,
                         lineCount: numberOfLines,
                         firstLineFillPercent: firstLineFillPercent,
                         lastLineFillPercent: lastLineFillPercent)
            .padding()

        case .shimmerImage:
            Image("PlaceholderImage")
                .foregroundColor(Color.gray)
                .shimmering(style: style,
                            usesTextHeightForLabels: usesTextHeightForLabels,
                            animationId: namespace)
                .padding()

        case .shimmerIndividual:
            HStack {
                Image("PlaceholderImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
                    .shimmering(style: style,
                                usesTextHeightForLabels: usesTextHeightForLabels,
                                animationId: namespace)
                VStack {
                    Text("This is the upper label being shimmered.")
                        .shimmering(style: style,
                                    usesTextHeightForLabels: usesTextHeightForLabels,
                                    animationId: namespace,
                                    isLabel: true)
                    Text("This is the lower label being shimmered.")
                        .shimmering(style: style,
                                    usesTextHeightForLabels: usesTextHeightForLabels,
                                    animationId: namespace,
                                    isLabel: true)
                }
            }
            .padding()

        case .shimmerStack:
            HStack {
                Image("PlaceholderImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.gray)
                VStack(spacing: 10) {
                    Text("This is the upper label being shimmered.")
                    Text("This is the lower label being shimmered.")
                }
            }
            .shimmering(style: style,
                        usesTextHeightForLabels: usesTextHeightForLabels,
                        animationId: namespace)
            .padding()
        }
    }

    @ViewBuilder
    private var settingsList: some View {
        FluentList {
            FluentListSection {
                Picker(selection: $shimmerDemoContent, label: Text("Demo Content")) {
                    ForEach(ShimmerDemos.allCases, id: \.self) { demo in
                        Text(demo.label).tag(demo)
                    }
                }

                Toggle("Uses Text Height For Labels", isOn: $usesTextHeightForLabels)
            }

            if shimmerDemoContent == .shimmerMultipleLines {
                FluentListSection("Number of Lines") {
                    ListActionItem(title: "Increase") {
                        numberOfLines += 1
                    }

                    ListActionItem(title: "Decrease") {
                        numberOfLines -= 1
                    }
                    .disabled(numberOfLines <= 0)
                }

                FluentListSection("Fill Percent") {
                    VStack {
                        Slider(value: $firstLineFillPercent, in: 0...1)
                        Text("First Line Fill Percent: \(firstLineFillPercent * 100, specifier: "%.2f")%")
                    }

                    VStack {
                        Slider(value: $lastLineFillPercent, in: 0...1)
                        Text("Last Line Fill Percent: \(lastLineFillPercent * 100, specifier: "%.2f")%")
                    }
                }
            }

            FluentListSection {
                Picker(selection: $style, label: Text("Style")) {
                    Text(".revealing").tag(MSFShimmerStyle.revealing)
                    Text(".concealing").tag(MSFShimmerStyle.concealing)
                }
            }
        }
        .fluentListStyle(.insetGrouped)
        .tint(fluentTheme.swiftUIColor(.brandForeground1))
    }

    @Environment(\.fluentTheme) var fluentTheme
    @Namespace var namespace: Namespace.ID
    @State var style: MSFShimmerStyle = .revealing
    @State var usesTextHeightForLabels: Bool = true
    @State var numberOfLines: Int = 3
    @State var firstLineFillPercent: Double = 0.94
    @State var lastLineFillPercent: Double = 0.6

    @State private var shimmerDemoContent: ShimmerDemos = .shimmerLabel

    private enum ShimmerDemos: Int, CaseIterable {
        case shimmerLabel
        case shimmerMultipleLines
        case shimmerImage
        case shimmerIndividual
        case shimmerStack

        var label: String {
            switch self {
            case .shimmerLabel:
                return "Label"
            case .shimmerMultipleLines:
                return "Multiple Lines"
            case .shimmerImage:
                return "Image"
            case .shimmerIndividual:
                return "Individual Views"
            case .shimmerStack:
                return "Stack"
            }
        }
    }
}
