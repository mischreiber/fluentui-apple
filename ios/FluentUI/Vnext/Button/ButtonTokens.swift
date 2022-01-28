//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI
import UIKit

/// Pre-defined styles of the button
@objc public enum MSFButtonStyle: Int, CaseIterable {
    case primary
    case secondary
    case ghost
    /// For use with small and large sizes only
    case accentFloating
    /// For use with small and large sizes only
    case subtleFloating

    var isFloatingStyle: Bool {
        return self == .accentFloating || self == .subtleFloating
    }
}

/// Pre-defined sizes of the button
@objc public enum MSFButtonSize: Int, CaseIterable {
    case small
    case medium
    case large
}

/// Representation of design tokens to buttons at runtime which interfaces with the Design Token System auto-generated code.
/// Updating these properties causes the SwiftUI button to update its view automatically.
public class ButtonTokens: ControlTokens {
    /// Creates an instance of `ButtonTokens`.
    public init(style: MSFButtonStyle,
                size: MSFButtonSize) {
        self.style = style
        self.size = size

        super.init()
    }

    /// Creates an instance of `ButtonTokens` with optional token value overrides.
    convenience public init(style: MSFButtonStyle,
                            size: MSFButtonSize,
                            borderRadius: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            borderSize: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            iconSize: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            interspace: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            padding: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            textFont: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> FontInfo)? = nil,
                            textMinimumHeight: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            textAdditionalHorizontalPadding: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)? = nil,
                            textColor: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)? = nil,
                            borderColor: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)? = nil,
                            backgroundColor: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)? = nil,
                            iconColor: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)? = nil,
                            restShadow: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ShadowInfo)? = nil,
                            pressedShadow: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ShadowInfo)? = nil) {
        self.init(style: style, size: size)

        // Optional overrides
        if let borderRadius = borderRadius {
            self.borderRadiusOverride = borderRadius
        }
        if let borderSize = borderSize {
            self.borderSizeOverride = borderSize
        }
        if let iconSize = iconSize {
            self.iconSizeOverride = iconSize
        }
        if let interspace = interspace {
            self.interspaceOverride = interspace
        }
        if let padding = padding {
            self.paddingOverride = padding
        }
        if let textFont = textFont {
            self.textFontOverride = textFont
        }
        if let textMinimumHeight = textMinimumHeight {
            self.textMinimumHeightOverride = textMinimumHeight
        }
        if let textAdditionalHorizontalPadding = textAdditionalHorizontalPadding {
            self.textAdditionalHorizontalPaddingOverride = textAdditionalHorizontalPadding
        }
        if let textColor = textColor {
            self.textColorOverride = textColor
        }
        if let borderColor = borderColor {
            self.borderColorOverride = borderColor
        }
        if let backgroundColor = backgroundColor {
            self.backgroundColorOverride = backgroundColor
        }
        if let iconColor = iconColor {
            self.iconColorOverride = iconColor
        }
        if let restShadow = restShadow {
            self.restShadowOverride = restShadow
        }
        if let pressedShadow = pressedShadow {
            self.pressedShadowOverride = pressedShadow
        }
    }

    let style: MSFButtonStyle
    let size: MSFButtonSize

    var borderRadiusOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var borderRadius: CGFloat { borderRadiusOverride?(style, size) ?? {
        switch size {
        case .small, .medium:
            return globalTokens.borderRadius[.large]
        case .large:
            return globalTokens.borderRadius[.xLarge]
        }
    }()}

    var borderSizeOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var borderSize: CGFloat { borderSizeOverride?(style, size) ?? {
        switch style {
        case .primary, .ghost, .accentFloating, .subtleFloating:
            return globalTokens.borderSize[.none]
        case .secondary:
            return globalTokens.borderSize[.thin]
        }
    }()}

    var iconSizeOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var iconSize: CGFloat { iconSizeOverride?(style, size) ?? {
        switch style {
        case .primary, .secondary, .ghost:
            switch size {
            case .small:
                return globalTokens.iconSize[.xSmall]
            case .medium,
                    .large:
                return globalTokens.iconSize[.small]
            }
        case .accentFloating, .subtleFloating:
            return globalTokens.iconSize[.medium]
        }
    }()}

    var interspaceOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var interspace: CGFloat { interspaceOverride?(style, size) ?? {
        switch style {
        case .primary, .secondary, .ghost:
            switch size {
            case .small:
                return globalTokens.spacing[.xxSmall]
            case .medium, .large:
                return globalTokens.spacing[.xSmall]
            }
        case .accentFloating, .subtleFloating:
            return globalTokens.spacing[.xSmall]
        }
    }()}

    var paddingOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var padding: CGFloat { paddingOverride?(style, size) ?? {
        switch style {
        case .primary, .secondary, .ghost:
            switch size {
            case .small:
                return globalTokens.spacing[.xSmall]
            case .medium:
                return globalTokens.spacing[.small]
            case .large:
                return globalTokens.spacing[.large]
            }
        case .accentFloating:
            switch size {
            case .small, .medium:
                return globalTokens.spacing[.small]
            case .large:
                return globalTokens.spacing[.medium]
            }
        case .subtleFloating:
            switch size {
            case .small, .medium:
                return globalTokens.spacing[.small]
            case .large:
                return globalTokens.spacing[.medium]
            }
        }
    }()}

    var textFontOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> FontInfo)?
    var textFont: FontInfo { textFontOverride?(style, size) ?? {
        switch style {
        case .primary, .secondary, .ghost:
            switch size {
            case .small, .medium:
                return aliasTokens.typography[.caption1Strong]
            case .large:
                return aliasTokens.typography[.body1Strong]
            }
        case .accentFloating:
            switch size {
            case .small, .medium:
                return aliasTokens.typography[.body2Strong]
            case .large:
                return aliasTokens.typography[.body1Strong]
            }
        case .subtleFloating:
            switch size {
            case .small, .medium:
                return aliasTokens.typography[.body2Strong]
            case .large:
                return aliasTokens.typography[.body1Strong]
            }
        }
    }()}

    var textMinimumHeightOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var textMinimumHeight: CGFloat { textMinimumHeightOverride?(style, size) ?? globalTokens.iconSize[.medium] }

    var textAdditionalHorizontalPaddingOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> CGFloat)?
    var textAdditionalHorizontalPadding: CGFloat { textAdditionalHorizontalPaddingOverride?(style, size) ?? {
        switch size {
        case .small, .medium:
            return globalTokens.spacing[.xSmall]
        case .large:
            return globalTokens.spacing[.xxSmall]
        }
    }()}

    var textColorOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)?
    var textColor: ButtonDynamicColors { textColorOverride?(style, size) ?? {
        switch style {
        case .primary, .accentFloating:
            return .init(
                rest: aliasTokens.foregroundColors[.neutralInverted],
                hover: aliasTokens.foregroundColors[.neutralInverted],
                pressed: aliasTokens.foregroundColors[.neutralInverted],
                selected: aliasTokens.foregroundColors[.neutralInverted],
                disabled: aliasTokens.foregroundColors[.neutralInverted]
            )
        case .subtleFloating:
            return .init(
                rest: aliasTokens.foregroundColors[.neutral3],
                hover: aliasTokens.foregroundColors[.neutral3],
                pressed: aliasTokens.foregroundColors[.neutral3],
                selected: aliasTokens.foregroundColors[.brandRest],
                disabled: aliasTokens.foregroundColors[.neutralDisabled]
            )
        case .secondary, .ghost:
            return .init(
                rest: aliasTokens.foregroundColors[.brandRest],
                hover: aliasTokens.foregroundColors[.brandHover],
                pressed: aliasTokens.foregroundColors[.brandPressed],
                selected: aliasTokens.foregroundColors[.brandSelected],
                disabled: aliasTokens.foregroundColors[.brandDisabled]
            )
        }
    }()}

    var borderColorOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)?
    var borderColor: ButtonDynamicColors { borderColorOverride?(style, size) ?? {
        switch style {
        case .primary:
            return .init(
                rest: aliasTokens.backgroundColors[.brandRest],
                hover: aliasTokens.backgroundColors[.brandHover],
                pressed: aliasTokens.backgroundColors[.brandPressed],
                selected: aliasTokens.backgroundColors[.brandSelected],
                disabled: aliasTokens.backgroundColors[.brandDisabled]
            )
        case .secondary, .accentFloating, .subtleFloating:
            return .init(
                rest: aliasTokens.backgroundColors[.brandRest],
                hover: aliasTokens.backgroundColors[.brandHover],
                pressed: aliasTokens.backgroundColors[.brandPressed],
                selected: aliasTokens.backgroundColors[.brandSelected],
                disabled: aliasTokens.backgroundColors[.brandDisabled]
            )
        case .ghost:
            return .init(
                rest: DynamicColor(light: ColorValue.clear),
                hover: DynamicColor(light: ColorValue.clear),
                pressed: DynamicColor(light: ColorValue.clear),
                selected: DynamicColor(light: ColorValue.clear),
                disabled: DynamicColor(light: ColorValue.clear)
            )
        }
    }()}

    var backgroundColorOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)?
    var backgroundColor: ButtonDynamicColors { backgroundColorOverride?(style, size) ?? {
        switch style {
        case .primary, .accentFloating:
            return .init(
                rest: aliasTokens.backgroundColors[.brandRest],
                hover: aliasTokens.backgroundColors[.brandHover],
                pressed: aliasTokens.backgroundColors[.brandPressed],
                selected: aliasTokens.backgroundColors[.brandSelected],
                disabled: aliasTokens.backgroundColors[.brandDisabled]
            )
        case .secondary, .ghost:
            return .init(
                rest: DynamicColor(light: ColorValue.clear),
                hover: DynamicColor(light: ColorValue.clear),
                pressed: DynamicColor(light: ColorValue.clear),
                selected: DynamicColor(light: ColorValue.clear),
                disabled: DynamicColor(light: ColorValue.clear)
            )
        case .subtleFloating:
            return .init(
                rest: aliasTokens.backgroundColors[.neutral1],
                hover: aliasTokens.backgroundColors[.neutral1],
                pressed: aliasTokens.backgroundColors[.neutral5],
                selected: aliasTokens.backgroundColors[.neutral1],
                disabled: aliasTokens.backgroundColors[.neutral1]
            )
        }
    }()}

    var iconColorOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ButtonDynamicColors)?
    var iconColor: ButtonDynamicColors { iconColorOverride?(style, size) ?? {
        switch style {
        case .primary, .accentFloating:
            return .init(
                rest: aliasTokens.foregroundColors[.neutralInverted],
                hover: aliasTokens.foregroundColors[.neutralInverted],
                pressed: aliasTokens.foregroundColors[.neutralInverted],
                selected: aliasTokens.foregroundColors[.neutralInverted],
                disabled: aliasTokens.foregroundColors[.neutralInverted]
            )
        case .secondary, .ghost:
            return .init(
                rest: aliasTokens.foregroundColors[.brandRest],
                hover: aliasTokens.foregroundColors[.brandHover],
                pressed: aliasTokens.foregroundColors[.brandPressed],
                selected: aliasTokens.foregroundColors[.brandSelected],
                disabled: aliasTokens.foregroundColors[.brandDisabled]
            )
        case .subtleFloating:
            return .init(
                rest: aliasTokens.foregroundColors[.neutral3],
                hover: aliasTokens.foregroundColors[.neutral3],
                pressed: aliasTokens.foregroundColors[.neutral3],
                selected: aliasTokens.foregroundColors[.brandRest],
                disabled: aliasTokens.foregroundColors[.neutralDisabled]
            )
        }
    }()}

    var restShadowOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ShadowInfo)?
    var restShadow: ShadowInfo { restShadowOverride?(style, size) ?? aliasTokens.elevation[.interactiveElevation1Rest] }

    var pressedShadowOverride: ((_ style: MSFButtonStyle, _ size: MSFButtonSize) -> ShadowInfo)?
    var pressedShadow: ShadowInfo { pressedShadowOverride?(style, size) ?? aliasTokens.elevation[.interactiveElevation1Pressed] }
}
