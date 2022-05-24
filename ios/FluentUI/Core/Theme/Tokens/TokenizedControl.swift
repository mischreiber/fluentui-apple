//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import SwiftUI

/// Defines a control with customizable design tokens.
public protocol TokenizedControl {
    associatedtype TokenType: ControlTokens

    /// Modifier function that updates the design tokens for a given control.
    ///
    /// - Parameter tokens: The tokens to apply to this control.
    ///
    /// - Returns: A version of this control with these overridden tokens applied.
    func overrideTokens(_ tokens: TokenType?) -> Self
}

/// Internal extension to `TokenizedControl` that adds the ability to modify the active tokens.
protocol TokenizedControlInternal: TokenizedControl {
    /// The current `FluentTheme` applied to this control. Usually acquired via the environment.
    var fluentTheme: FluentTheme { get }

    /// Default token set.
    var defaultTokens: TokenType { get }

    /// Fetches the current token override.
    var overrideTokens: TokenType? { get }

    /// Configures token sets with any additional information needed to render (e.g. `style`, `size`).
    func configureTokens(_ tokens: TokenType?)
}

// MARK: - Extensions

extension TokenizedControlInternal {

    /// Theme-provided class-wide override tokens.
    var themeTokens: TokenType? { fluentTheme.tokens(for: self) }

    /// Configures token sets with any additional information needed to render (e.g. `style`, `size`).
    ///
    /// Individual TokenizedControlInternal classes should provide alternate implementations of this method to configure tokens as needed.
    func configureTokens(_ tokens: TokenType?) {
        // No-op by default
    }

    /// Returns the appropriate token value for a given key path on this control's token set.
    ///
    /// This method looks for the first value that does not match the default value provided by `defaultTokens`.
    /// Priority order for tokens are `overrideTokens`, `themeTokens`, then finally `defaultTokens`.
    func tokenValue<ValueType: Equatable>(_ keyPath: KeyPath<TokenType, ValueType>) -> ValueType {
        // Begin by ensuring that all tokens are properly configured with the current fluentTheme.
        prepareTokens()

        let defaultValue = defaultTokens[keyPath: keyPath]
        if let overrideValue = overrideTokens?[keyPath: keyPath], overrideValue != defaultValue {
            return overrideValue
        } else if let themeValue = themeTokens?[keyPath: keyPath], themeValue != defaultValue {
            return themeValue
        } else {
            return defaultValue
        }
    }

    private func prepareTokens() {
        let tokenSets: [TokenType?] = [overrideTokens, themeTokens, defaultTokens]
        tokenSets.forEach { tokens in
            tokens?.fluentTheme = fluentTheme
            configureTokens(tokens)
        }
    }

}
