//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// View Modifier that adds a "shimmering" effect to any view.
public struct Shimmer: ViewModifier, TokenizedControlView {
    public typealias TokenSetKeyType = ShimmerTokenSet.Tokens
    @ObservedObject public var tokenSet: ShimmerTokenSet

    public func body(content: Content) -> some View {
        if isShimmering {
            content
                .modifier(AnimatedMask(tokenSet: tokenSet,
                                       style: style,
                                       shouldAddShimmeringCover: shouldAddShimmeringCover,
                                       usesTextHeightForLabels: usesTextHeightForLabels,
                                       isLabel: isLabel,
                                       phase: phase,
                                       contentSize: contentSize)
                    .animation(Animation.linear(duration: /*tokenSet[.shimmerDuration].float*/ 1.0) // TODO Shimmer
                        .delay(tokenSet[.shimmerDelay].float)
                        .repeatForever(autoreverses: false)
                    ))
                .onSizeChange { newSize in
                    contentSize = newSize
                }
                .onAppear {
                    if !UIAccessibility.isReduceMotionEnabled {
                        phase = .init(1.0 + (tokenSet[.shimmerWidth].float / contentSize.width))
                    }
                }
            /// RTL languages require shimmer in the respective direction.
                .flipsForRightToLeftLayoutDirection(true)
                .matchedGeometryEffect(id: UUID(), in: self.animationId)
        } else {
            content
        }
    }

    /// An animatable modifier to interpolate between `phase` values.
    struct AnimatedMask: AnimatableModifier {
        var tokenSet: ShimmerTokenSet
        var style: MSFShimmerStyle
        var shouldAddShimmeringCover: Bool
        var usesTextHeightForLabels: Bool
        var isLabel: Bool
        var phase: CGFloat
        var contentSize: CGSize

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            let gradientMask = GradientMask(tokenSet: tokenSet,
                                            style: style,
                                            contentSize: contentSize,
                                            phase: phase)

            if shouldAddShimmeringCover {
                ZStack {
                    content
                    HStack {
                        RoundedRectangle(cornerRadius: isLabel && tokenSet[.labelCornerRadius].float >= 0 ? tokenSet[.labelCornerRadius].float : tokenSet[.cornerRadius].float)
                            .foregroundColor(tokenSet[.tintColor].color)
                            .frame(width: contentSize.width,
                                   height: !isLabel || usesTextHeightForLabels ? contentSize.height : tokenSet[.labelHeight].float)
                            .mask(gradientMask)
                    }
                }
            } else {
                content
                    .mask(gradientMask)
            }
        }
    }

    /// A slanted, animatable gradient between light (transparent) and dark (opaque) parts of shimmer  to use as mask.
    /// The `phase` parameter shifts the gradient, moving the shimmer band.
    struct GradientMask: View {
        var tokenSet: ShimmerTokenSet
        var style: MSFShimmerStyle
        var contentSize: CGSize
        var phase: CGFloat

        var body: some View {
            let light = Color.white.opacity(self.tokenSet[.shimmerAlpha].float)
            let dark = Color(self.tokenSet[.darkGradient].uiColor.light)

            let widthPercentage = tokenSet[.shimmerWidth].float / contentSize.width
            LinearGradient(gradient: Gradient(stops: [
                .init(color: style == .concealing ? light : dark, location: phase - widthPercentage),
                .init(color: style == .concealing ? dark : light, location: phase - widthPercentage / 2.0),
                .init(color: style == .concealing ? light : dark, location: phase)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        }
    }

    @Environment(\.fluentTheme) var fluentTheme: FluentTheme

    var style: MSFShimmerStyle
    var shouldAddShimmeringCover: Bool = true
    var usesTextHeightForLabels: Bool = false

    /// When displaying one or more shimmers, this ID will synchronize the animations.
    let animationId: Namespace.ID
    /// Determines whether content to shimmer is a label.
    let isLabel: Bool
    /// Whether the shimmering effect is active.
    let isShimmering: Bool

    @State private var phase: CGFloat = 0
    @State private var contentSize: CGSize = CGSize()
}
