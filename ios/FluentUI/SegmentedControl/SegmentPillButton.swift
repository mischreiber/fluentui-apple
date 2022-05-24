//
//  Copyright (c) Microsoft Corporation. All rights reserved.
//  Licensed under the MIT License.
//
import UIKit

class SegmentPillButton: UIButton {
    var isUnreadDotVisible: Bool = false {
        didSet {
            if oldValue != isUnreadDotVisible {
                if isUnreadDotVisible {
                    self.layer.addSublayer(unreadDotLayer)
                } else {
                    unreadDotLayer.removeFromSuperlayer()
                }
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if oldValue != isSelected && isSelected == true {
                item.isUnread = false
                updateUnreadDot()
            }
        }
    }

    unowned var segmentedControl: SegmentedControl

    func updateTokenizedValues() {
        titleLabel?.font = UIFont.fluent(segmentedControl.tokenValue(\.font), shouldScale: false)
        let verticalInset = segmentedControl.tokenValue(\.verticalInset)
        let horizontalInset = segmentedControl.tokenValue(\.horizontalInset)
        contentEdgeInsets = UIEdgeInsets(top: verticalInset,
                                         left: horizontalInset,
                                         bottom: verticalInset,
                                         right: horizontalInset)
    }

    init(withItem item: SegmentItem, segmentedControl: SegmentedControl) {
        self.item = item
        self.segmentedControl = segmentedControl
        super.init(frame: .zero)

        let title = item.title
        self.setTitle(title, for: .normal)
        self.accessibilityLabel = title
        self.largeContentTitle = title
        self.showsLargeContentViewer = true

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(isUnreadValueDidChange),
                                               name: SegmentItem.isUnreadValueDidChangeNotification,
                                               object: item)

        updateTokenizedValues()
    }

    required init?(coder: NSCoder) {
        preconditionFailure("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateUnreadDot()
    }

    private let item: SegmentItem

    private lazy var unreadDotLayer: CALayer = {
        let unreadDotLayer = CALayer()
        let unreadDotSize = segmentedControl.tokenValue(\.unreadDotSize)
        unreadDotLayer.bounds.size = CGSize(width: unreadDotSize, height: unreadDotSize)
        unreadDotLayer.cornerRadius = unreadDotSize / 2
        return unreadDotLayer
    }()

    @objc private func isUnreadValueDidChange() {
        isUnreadDotVisible = item.isUnread
        setNeedsLayout()
    }

    private func updateUnreadDot() {
        isUnreadDotVisible = item.isUnread
        if isUnreadDotVisible {
            let anchor = self.titleLabel?.frame ?? .zero
            let xPos: CGFloat
            if effectiveUserInterfaceLayoutDirection == .leftToRight {
                xPos = anchor.maxX + segmentedControl.tokenValue(\.unreadDotOffsetX)
            } else {
                xPos = anchor.minX - segmentedControl.tokenValue(\.unreadDotOffsetX) - segmentedControl.tokenValue(\.unreadDotSize)
            }
            unreadDotLayer.frame.origin = CGPoint(x: xPos, y: anchor.minY + segmentedControl.tokenValue(\.unreadDotOffsetY))
            let unreadDotColor = isEnabled ? segmentedControl.tokenValue(\.enabledUnreadDotColor) : segmentedControl.tokenValue(\.disabledUnreadDotColor)
            unreadDotLayer.backgroundColor = UIColor(dynamicColor: unreadDotColor).cgColor
        }
    }
}
