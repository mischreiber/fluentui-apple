//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Type of callback for both action and dismiss buttons.
public typealias CardNudgeButtonAction = ((_ state: MSFCardNudgeState) -> Void)

/// Properties that can be used to customize the appearance of the `CardNudge`.
@objc public protocol MSFCardNudgeState: NSObjectProtocol {
    /// Style to draw the control.
    @objc var style: MSFCardNudgeStyle { get set }

    /// Text for the main title area of the control.
    @objc var title: String { get set }

    /// Optional subtext to draw below the main title area.
    @objc var subtitle: String? { get set }

    /// Optional icon to draw at the leading edge of the control.
    @objc var mainIcon: UIImage? { get set }

    /// Optional accented text to draw below the main title area.
    @objc var accentText: String? { get set }

    /// Optional small icon to draw at the leading edge of `accentText`.
    @objc var accentIcon: UIImage? { get set }

    /// Title to display in the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @objc var actionButtonTitle: String? { get set }

    /// Action to be dispatched by the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @objc var actionButtonAction: CardNudgeButtonAction? { get set }

    /// Action to be dispatched by the dismiss ("close") button on the trailing edge of the control.
    @objc var dismissButtonAction: CardNudgeButtonAction? { get set }

    /// Custom design token set for this control, to use in place of the control's default Fluent tokens.
    @objc var overrideTokens: CardNudgeTokens? { get set }
}

/// View that represents the CardNudge.
public struct CardNudge: View, ConfigurableTokenizedControl {
    @Environment(\.fluentTheme) var fluentTheme: FluentTheme
    @ObservedObject var state: MSFCardNudgeStateImpl
    @ObservedObject var tokens: TokenResolver<CardNudgeTokens> = .init()
    let defaultTokens: CardNudgeTokens = .init()
    func configureTokens(_ tokens: CardNudgeTokens?) {
        tokens?.style = state.style
    }

    @ViewBuilder
    var icon: some View {
        if let icon = state.mainIcon {
            ZStack {
                RoundedRectangle(cornerRadius: tokens.value(\.circleRadius))
                    .frame(width: tokens.value(\.circleSize), height: tokens.value(\.circleSize))
                    .foregroundColor(Color(dynamicColor: tokens.value(\.buttonBackgroundColor)))
                Image(uiImage: icon)
                    .renderingMode(.template)
                    .frame(width: tokens.value(\.iconSize), height: tokens.value(\.iconSize), alignment: .center)
                    .foregroundColor(Color(dynamicColor: tokens.value(\.accentColor)))
            }
            .padding(.trailing, tokens.value(\.horizontalPadding))
        }
    }

    private var hasSecondTextRow: Bool {
        state.accentIcon != nil || state.accentText != nil || state.subtitle != nil
    }

    @ViewBuilder
    var textContainer: some View {
        VStack(alignment: .leading, spacing: tokens.value(\.interTextVerticalPadding)) {
            Text(state.title)
                .font(.subheadline)
                .fontWeight(.medium)
                .lineLimit(1)
                .foregroundColor(Color(dynamicColor: tokens.value(\.textColor)))

            if hasSecondTextRow {
                HStack(spacing: tokens.value(\.accentPadding)) {
                    if let accentIcon = state.accentIcon {
                        Image(uiImage: accentIcon)
                            .renderingMode(.template)
                            .frame(width: tokens.value(\.accentIconSize), height: tokens.value(\.accentIconSize))
                            .foregroundColor(Color(dynamicColor: tokens.value(\.accentColor)))
                    }
                    if let accent = state.accentText {
                        Text(accent)
                            .font(.subheadline)
                            .layoutPriority(1)
                            .lineLimit(1)
                            .foregroundColor(Color(dynamicColor: tokens.value(\.accentColor)))
                    }
                    if let subtitle = state.subtitle {
                        Text(subtitle)
                            .font(.subheadline)
                            .lineLimit(1)
                            .foregroundColor(Color(dynamicColor: tokens.value(\.subtitleTextColor)))
                    }
                }
            }
        }
    }

    @ViewBuilder
    var buttons: some View {
        HStack(spacing: 0) {
            if let actionTitle = state.actionButtonTitle,
                      let action = state.actionButtonAction {
                SwiftUI.Button(actionTitle) {
                    action(state)
                }
                .lineLimit(1)
                .padding(.horizontal, tokens.value(\.buttonInnerPaddingHorizontal))
                .padding(.vertical, tokens.value(\.verticalPadding))
                .foregroundColor(Color(dynamicColor: tokens.value(\.accentColor)))
                .background(
                    RoundedRectangle(cornerRadius: tokens.value(\.circleRadius))
                        .foregroundColor(Color(dynamicColor: tokens.value(\.buttonBackgroundColor)))
                )
            }
            if let dismissAction = state.dismissButtonAction {
                SwiftUI.Button(action: {
                    dismissAction(state)
                }, label: {
                    Image("dismiss-20x20", bundle: FluentUIFramework.resourceBundle)
                })
                .padding(.horizontal, tokens.value(\.buttonInnerPaddingHorizontal))
                .padding(.vertical, tokens.value(\.verticalPadding))
                .accessibility(identifier: "Accessibility.Dismiss.Label")
                .foregroundColor(Color(dynamicColor: tokens.value(\.textColor)))
            }
        }
    }

    @ViewBuilder
    var innerContents: some View {
        HStack(spacing: 0) {
            icon
            textContainer
            Spacer(minLength: tokens.value(\.accentPadding))
            buttons
                .layoutPriority(1)
        }
        .padding(.vertical, tokens.value(\.mainContentVerticalPadding))
        .padding(.horizontal, tokens.value(\.horizontalPadding))
        .frame(minHeight: tokens.value(\.minimumHeight))
    }

    public var body: some View {
        innerContents
            .background(
                RoundedRectangle(cornerRadius: tokens.value(\.cornerRadius))
                    .strokeBorder(lineWidth: tokens.value(\.outlineWidth))
                    .foregroundColor(Color(dynamicColor: tokens.value(\.outlineColor)))
                    .background(
                        Color(dynamicColor: tokens.value(\.backgroundColor))
                            .cornerRadius(tokenValue(\.cornerRadius))
                    )
            )
            .padding(.vertical, tokens.value(\.verticalPadding))
            .padding(.horizontal, tokens.value(\.horizontalPadding))
            .designTokens(tokens, fluentTheme) { tokens in
                tokens.style = state.style
            }
    }

    public init(style: MSFCardNudgeStyle, title: String) {
        let state = MSFCardNudgeStateImpl(style: style, title: title)
        self.state = state
    }
}

class MSFCardNudgeStateImpl: NSObject, ControlConfiguration, MSFCardNudgeState {
    @Published var title: String
    @Published var subtitle: String?
    @Published var mainIcon: UIImage?
    @Published var accentIcon: UIImage?
    @Published var accentText: String?

    /// Title to display in the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @Published var actionButtonTitle: String?

    /// Action to be dispatched by the action button on the trailing edge of the control.
    ///
    /// To show an action button, provide values for both `actionButtonTitle` and  `actionButtonAction`.
    @Published var actionButtonAction: CardNudgeButtonAction?

    /// Action to be dispatched by the dismiss ("close") button on the trailing edge of the control.
    @Published var dismissButtonAction: CardNudgeButtonAction?

    /// Design token set for this control, to use in place of the control's default Fluent tokens.
    @Published var overrideTokens: CardNudgeTokens?

    /// Style to draw the control.
    @Published var style: MSFCardNudgeStyle

    @objc init(style: MSFCardNudgeStyle, title: String) {
        self.style = style
        self.title = title

        super.init()
    }
}
