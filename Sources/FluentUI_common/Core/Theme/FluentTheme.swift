//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import Combine
import SwiftUI

/// Base class that allows for customization of global, alias, and control tokens.
@objc(MSFFluentTheme)
public class FluentTheme: NSObject, ObservableObject {
    /// Initializes and returns a new `FluentTheme`.
    ///
    /// Control tokens can be customized via `register(controlType:tokens:) `;
    /// see that method's description for additional information.
    ///
    /// - Returns: An initialized `FluentTheme` instance, with optional overrides.
    @objc public convenience override init() {
        self.init(colorOverrides: nil as [ColorToken: Color]?,
                  shadowOverrides: nil as [ShadowToken: ShadowInfo]?,
                  typographyOverrides: nil as [TypographyToken: FontInfo]?,
                  gradientOverrides: nil as [GradientToken: [Color]]?)
    }

    /// Initializes and returns a new `FluentTheme`.
    ///
    /// A `FluentTheme` receives any custom alias tokens on initialization via arguments here.
    /// Control tokens can be customized via `register(controlType:tokens:) `;
    /// see that method's description for additional information.
    ///
    /// - Parameters:
    ///   - colorOverrides: A `Dictionary` of override values mapped to `ColorTokens`.
    ///   - shadowOverrides: A `Dictionary` of override values mapped to `ShadowTokens`.
    ///   - typographyOverrides: A `Dictionary` of override values mapped to `TypographyTokens`.
    ///   - gradientOverrides: A `Dictionary` of override values mapped to `GradientTokens`.
    ///
    /// - Returns: An initialized `FluentTheme` instance, with optional overrides.
    public init(colorOverrides: [ColorToken: Color]? = nil,
                shadowOverrides: [ShadowToken: ShadowInfo]? = nil,
                typographyOverrides: [TypographyToken: FontInfo]? = nil,
                gradientOverrides: [GradientToken: [Color]]? = nil) {

        let platformThemeProvider = Self.platformThemeProvider
        let colorTokenSet = TokenSet<ColorToken, DynamicColor>(
            platformThemeProvider.platformColorValue(_:),
            colorOverrides?.mapValues { $0.dynamicColor }
        )
        let shadowTokenSet = TokenSet<ShadowToken, ShadowInfo>(FluentTheme.defaultShadow(_:), shadowOverrides)
        let typographyTokenSet = TokenSet<TypographyToken, FontInfo>(platformThemeProvider.platformTypographyValue(_:), typographyOverrides)
        let gradientTokenSet = TokenSet<GradientToken, [DynamicColor]>({ [colorTokenSet] token in
            // Reference the colorTokenSet as part of the gradient lookup
            return FluentTheme.defaultGradientColor(token, colorTokenSet: colorTokenSet)
        }, gradientOverrides?.mapValues { $0.map { $0.dynamicColor} })

        self.colorTokenSet = colorTokenSet
        self.shadowTokenSet = shadowTokenSet
        self.typographyTokenSet = typographyTokenSet
        self.gradientTokenSet = gradientTokenSet
    }

    /// Registers a custom set of `ControlTokenValue` instances for a given `ControlTokenSet`.
    ///
    /// - Parameters:
    ///   - tokenSetType: The token set type to register custom tokens for.
    ///   - tokens: A custom set of tokens to register.
    public func register<T: TokenSetKey>(tokenSetType: ControlTokenSet<T>.Type, tokenSet: [T: ControlTokenValue]?) {
        controlTokenSets[tokenKey(tokenSetType)] = tokenSet
    }

    /// Returns the `ControlTokenValue` array for a given `TokenizedControl`, if any overrides have been registered.
    ///
    /// - Parameter tokenSetType: The token set type to fetch the token overrides for.
    ///
    /// - Returns: An array of `ControlTokenValue` instances for the given control, or `nil` if no custom tokens have been registered.
    public func tokens<T: TokenSetKey>(for tokenSetType: ControlTokenSet<T>.Type) -> [T: ControlTokenValue]? {
        return controlTokenSets[tokenKey(tokenSetType)] as? [T: ControlTokenValue]
    }

    /// The shared `FluentTheme` instance used by default for controls in the app.
    ///
    /// This static `FluentTheme` instance will normally return the default token values associated
    /// with Fluent. However, it is also available for overriding in cases where a single custom theme
    /// is desired for the app linking this library.
    ///
    /// Note that any custom themes set on a `UIView` hierarchy or via a SwiftUI view modifier will
    /// take precedence over this value. This value provides the fallback theme for cases where those
    /// overrides are not provided.
    @objc(sharedTheme)
    public static var shared: FluentTheme = .init() {
        didSet {
            NotificationCenter.default.post(name: .didChangeTheme, object: nil)
        }
    }

    /// Determines if a given `Notification` should cause an update for the given `FluentThemeable`.
    ///
    /// - Parameter notification: A `Notification` object that may be requesting a view update based on a theme change.
    /// - Parameter view: The `FluentThemeable` instance that wants to determine whether to update.
    ///
    /// - Returns: `true` if the view should update, `false` otherwise.
    @objc(isApplicableThemeChangeNotification:forView:)
    public static func isApplicableThemeChange(_ notification: Notification,
                                               for view: FluentThemeable) -> Bool {
        return view.isApplicableThemeChange(notification)
    }

    /// Workaround for a SwiftUI bug on iOS 17. We need to expose the `DynamicColor` for a given
    /// `ColorToken` to initialize our platform-specific colors (`UIColor` and `NSColor`).
    /// Creating directly from SwiftUI color is broken on these platforms.
    public func dynamicColor(_ colorToken: ColorToken) -> DynamicColor {
        return colorTokenSet[colorToken]
    }

    // Token storage
    let colorTokenSet: TokenSet<ColorToken, DynamicColor>
    let shadowTokenSet: TokenSet<ShadowToken, ShadowInfo>
    let typographyTokenSet: TokenSet<TypographyToken, FontInfo>
    let gradientTokenSet: TokenSet<GradientToken, [DynamicColor]>

    private func tokenKey<T: TokenSetKey>(_ tokenSetType: ControlTokenSet<T>.Type) -> String {
        return "\(tokenSetType)"
    }

    private var controlTokenSets: [String: Any] = [:]

    private static var platformThemeProvider: any PlatformThemeProviding.Type {
        // We need slightly different implementations depending on how our package is loaded.
#if SWIFT_PACKAGE || COCOAPODS
        // In this case, the protocol conformance happens in a different module, so we need to
        // convert the type conditionally and fail if something goes wrong.
        guard let platformThemeProvider = self as? PlatformThemeProviding.Type else {
            preconditionFailure("Unable to initialize FluentTheme: does not conform to PlatformThemeProviding")
        }
#else
        // Otherwise, we're all in one module and thus the type conversion is guaranteed.
        let platformThemeProvider = self as PlatformThemeProviding.Type
#endif
        return platformThemeProvider
    }
}

// MARK: - FluentThemeable

/// Public protocol that, when implemented, allows any container to store and yield a `FluentTheme`.
@objc public protocol FluentThemeable {
    var fluentTheme: FluentTheme { get set }
    func isApplicableThemeChange(_ notification: Notification) -> Bool
}

public extension Notification.Name {
    /// The notification that will fire when a new `FluentTheme` is set on a view.
    ///
    /// The `object` for the fired `Notification` will be the `UIView` whose `fluentTheme` has changed.
    /// Listeners will likely only want to redraw if they are a descendent of this view.
    static let didChangeTheme = Notification.Name("FluentUI.stylesheet.theme")
}

// MARK: - Environment

public extension View {
    /// Sets a custom theme for a specific SwiftUI View and its view hierarchy.
    /// - Parameter fluentTheme: Instance of the custom theme.
    /// - Returns: The view with its `fluentTheme` environment value overriden.
    func fluentTheme(_ fluentTheme: FluentTheme) -> some View {
        environment(\.fluentTheme, fluentTheme)
    }
}

public extension EnvironmentValues {
    var fluentTheme: FluentTheme {
        get {
            self[FluentThemeKey.self]
        }
        set {
            self[FluentThemeKey.self] = newValue
        }
    }
}

struct FluentThemeKey: EnvironmentKey {
    static var defaultValue: FluentTheme { .shared }
}
