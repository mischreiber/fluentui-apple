//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//

import UIKit

// MARK: PillButton

/// A `PillButton` is a button in the shape of a pill that can have two states: on (Selected) and off (not selected)
@objc(MSFPillButton)
open class PillButton: UIButton, TokenizedControlInternal {

    open override func didMoveToWindow() {
        super.didMoveToWindow()

        updateAppearance()
    }

    @objc public init(pillBarItem: PillButtonBarItem, style: PillButtonStyle = .primary) {
        self.pillBarItem = pillBarItem
        self.style = style
        super.init(frame: .zero)
        setupView()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isUnreadValueDidChange),
                                               name: PillButtonBarItem.isUnreadValueDidChangeNotification,
                                               object: pillBarItem)
    }

    public required init?(coder aDecoder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateUnreadDot()
    }

    public func overrideTokens(_ tokens: PillButtonTokens?) -> Self {
        overrideTokens = tokens
        return self
    }

    public override var isSelected: Bool {
        didSet {
            if oldValue != isSelected && isSelected == true {
                pillBarItem.isUnread = false
                updateUnreadDot()
            }
            updateAppearance()
            updateAccessibilityTraits()
        }
    }

    public override var isEnabled: Bool {
        didSet {
            updateAppearance()
            updateAccessibilityTraits()
        }
    }

    public override var isHighlighted: Bool {
        didSet {
            updateAppearance()
        }
    }

    @objc public static let cornerRadius: CGFloat = 16.0

    @objc public let pillBarItem: PillButtonBarItem

    @objc public let style: PillButtonStyle

    let defaultTokens: PillButtonTokens = .init()
    var overrideTokens: PillButtonTokens? {
        didSet {
            updateAppearance()
        }
    }

    var unreadDotColor: UIColor = Colors.gray100

    private func setupView() {
        setTitle(pillBarItem.title, for: .normal)
        titleLabel?.font = UIFont.fluent(tokenValue(\.font), shouldScale: false)
        layer.cornerRadius = PillButton.cornerRadius
        clipsToBounds = true

        layer.cornerCurve = .continuous
        largeContentTitle = titleLabel?.text
        showsLargeContentViewer = true

        contentEdgeInsets = UIEdgeInsets(top: tokenValue(\.topInset),
                                         left: tokenValue(\.horizontalInset),
                                         bottom: tokenValue(\.bottomInset),
                                         right: tokenValue(\.horizontalInset))

    }

    private func updateAccessibilityTraits() {
        if isSelected {
            accessibilityTraits.insert(.selected)
        } else {
            accessibilityTraits.remove(.selected)
        }

        if isEnabled {
            accessibilityTraits.remove(.notEnabled)
        } else {
            accessibilityTraits.insert(.notEnabled)
        }
    }

    private func initUnreadDotLayer() -> CALayer {
        let unreadDotLayer = CALayer()

        unreadDotLayer.bounds.size = CGSize(width: tokenValue(\.unreadDotSize), height: tokenValue(\.unreadDotSize))
        unreadDotLayer.cornerRadius = tokenValue(\.unreadDotSize) / 2

        return unreadDotLayer
    }

    @objc private func isUnreadValueDidChange() {
        isUnreadDotVisible = pillBarItem.isUnread
        setNeedsLayout()
    }

    private func updateUnreadDot() {
        isUnreadDotVisible = pillBarItem.isUnread
        if isUnreadDotVisible {
            let anchor = self.titleLabel?.frame ?? .zero
            let xPos: CGFloat
            if effectiveUserInterfaceLayoutDirection == .leftToRight {
                xPos = round(anchor.maxX + tokenValue(\.unreadDotOffsetX))
            } else {
                xPos = round(anchor.minX - tokenValue(\.unreadDotOffsetX) - tokenValue(\.unreadDotSize))
            }
            unreadDotLayer.frame.origin = CGPoint(x: xPos, y: anchor.minY + tokenValue(\.unreadDotOffsetY))
            unreadDotLayer.backgroundColor = unreadDotColor.cgColor
        }
    }

    private func updateAppearance() {
        if isSelected {
            if isEnabled {
                backgroundColor = UIColor(dynamicColor: tokenValue(\.backgroundColor).selected)
                setTitleColor(UIColor(dynamicColor: tokenValue(\.titleColor).selected), for: .normal)
            } else {
                backgroundColor = UIColor(dynamicColor: tokenValue(\.backgroundColor).selectedDisabled)
                setTitleColor(UIColor(dynamicColor: tokenValue(\.titleColor).selectedDisabled), for: .normal)
            }
        } else {
            backgroundColor = isEnabled
            ? UIColor(dynamicColor: tokenValue(\.backgroundColor).rest)
            : UIColor(dynamicColor: tokenValue(\.backgroundColor).disabled)

            if isEnabled {
                setTitleColor(UIColor(dynamicColor: tokenValue(\.titleColor).rest), for: .normal)
            } else {
                setTitleColor(UIColor(dynamicColor: tokenValue(\.titleColor).disabled), for: .disabled)
            }

            unreadDotColor = isEnabled
            ? UIColor(dynamicColor: tokenValue(\.enabledUnreadDotColor))
            : UIColor(dynamicColor: tokenValue(\.disabledUnreadDotColor))
        }

        titleLabel?.font = UIFont.fluent(tokenValue(\.font), shouldScale: false)
    }

    func configureTokens(_ tokens: PillButtonTokens?) {
        tokens?.style = style
    }

    private lazy var unreadDotLayer: CALayer = initUnreadDotLayer()

    private var isUnreadDotVisible: Bool = false {
        didSet {
            if oldValue != isUnreadDotVisible {
                if isUnreadDotVisible {
                    layer.addSublayer(unreadDotLayer)
                } else {
                    unreadDotLayer.removeFromSuperlayer()
                }
            }
        }
    }
}
