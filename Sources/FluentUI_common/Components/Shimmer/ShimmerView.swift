//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// ViewModifier that uses GeometryReader to get the size of the content view and sets it in the SizePreferenceKey
fileprivate struct OnSizeChangeViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content.background(GeometryReader { geometryReader in
            Color.clear.preference(key: SizePreferenceKey.self,
                                   value: geometryReader.size)
        })
    }
}

/// PreferenceKey that will store the measured size of the view
fileprivate struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}

fileprivate extension View {
    /// Measures the size of a view, monitors when its size is updated, and takes a closure to be called when it does
    /// - Parameter action: Block to be performed on size change
    /// - Returns The modified view.
    func onSizeChange(perform action: @escaping (CGSize) -> Void) -> some View {
        self.modifier(OnSizeChangeViewModifier())
            .onPreferenceChange(SizePreferenceKey.self,
                                perform: action)
    }
}


/// Properties that can be used to customize the appearance of the `Shimmer`.
@objc public protocol MSFShimmerState {

    /// Determines whether the shimmer is a revealing shimmer or a concealing shimmer.
    var style: MSFShimmerStyle { get set }

    /// Determines whether the view itself is shimmered or an added cover on top is shimmered.
    var shouldAddShimmeringCover: Bool { get set }

    /// Whether to use the height of the view (if the view is a label), else default to token value.
    var usesTextHeightForLabels: Bool { get set }
}

/// View Modifier that adds a "shimmering" effect to any view.
public struct Shimmer: ViewModifier, TokenizedControlView {
    public typealias TokenSetKeyType = ShimmerTokenSet.Tokens
    @ObservedObject public var tokenSet: ShimmerTokenSet

    public func body(content: Content) -> some View {
        if isShimmering {
            content
                .modifier(AnimatedMask(tokenSet: tokenSet,
                                       state: state,
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
        var state: MSFShimmerState
        var isLabel: Bool
        var phase: CGFloat
        var contentSize: CGSize

        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }

        func body(content: Content) -> some View {
            let gradientMask = GradientMask(tokenSet: tokenSet,
                                            state: state,
                                            contentSize: contentSize,
                                            phase: phase)

            if state.shouldAddShimmeringCover {
                ZStack {
                    content
                    HStack {
                        RoundedRectangle(cornerRadius: isLabel && tokenSet[.labelCornerRadius].float >= 0 ? tokenSet[.labelCornerRadius].float : tokenSet[.cornerRadius].float)
                            .foregroundColor(tokenSet[.tintColor].color)
                            .frame(width: contentSize.width,
                                   height: !isLabel || state.usesTextHeightForLabels ? contentSize.height : tokenSet[.labelHeight].float)
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
        var state: MSFShimmerState
        var contentSize: CGSize
        var phase: CGFloat

        var body: some View {
            let light = Color.white.opacity(self.tokenSet[.shimmerAlpha].float)
            let dark = Color(self.tokenSet[.darkGradient].uiColor.light)

            let widthPercentage = tokenSet[.shimmerWidth].float / contentSize.width
            LinearGradient(gradient: Gradient(stops: [
                .init(color: state.style == .concealing ? light : dark, location: phase - widthPercentage),
                .init(color: state.style == .concealing ? dark : light, location: phase - widthPercentage / 2.0),
                .init(color: state.style == .concealing ? light : dark, location: phase)]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
        }
    }

    @Environment(\.fluentTheme) var fluentTheme: FluentTheme
    @ObservedObject var state: MSFShimmerStateImpl

    /// When displaying one or more shimmers, this ID will synchronize the animations.
    let animationId: Namespace.ID
    /// Determines whether content to shimmer is a label.
    let isLabel: Bool
    /// Whether the shimmering effect is active.
    let isShimmering: Bool

    @State private var phase: CGFloat = 0
    @State private var contentSize: CGSize = CGSize()
}

class MSFShimmerStateImpl: ControlState, MSFShimmerState {
    @Published var style: MSFShimmerStyle
    @Published var shouldAddShimmeringCover: Bool = true
    @Published var usesTextHeightForLabels: Bool = false

    init(style: MSFShimmerStyle) {
        self.style = style
        super.init()
    }

    convenience init(style: MSFShimmerStyle,
                     shouldAddShimmeringCover: Bool = true,
                     usesTextHeightForLabels: Bool = false) {
        self.init(style: style)
        self.shouldAddShimmeringCover = shouldAddShimmeringCover
        self.usesTextHeightForLabels = usesTextHeightForLabels
    }
}
