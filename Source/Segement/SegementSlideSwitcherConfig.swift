//
//  SegementSlideSwitcherConfig.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

public struct SegementSlideSwitcherConfig {

    public static let shared = SegementSlideSwitcherConfig()

    public var type: SwitcherType
    public var underlineType: UnderlineType
    public var seperatelineType: SeperatelineType
    public var horizontalMargin: CGFloat
    public var horizontalSpace: CGFloat
    public var normalTitleFont: UIFont
    public var selectedTitleFont: UIFont
    public var normalTitleColor: UIColor
    public var selectedTitleColor: UIColor
    public var indicatorWidth: CGFloat?
    public var indicatorHeight: CGFloat
    public var indicatorColor: UIColor
    public var badgeHeightForPointType: CGFloat
    public var badgeHeightForCountType: CGFloat
    public var badgeHeightForCustomType: CGFloat
    public var badgeFontForCountType: UIFont
    public var isVerticalScrollable: Bool
    public var isScrollEnabled: Bool
    public var buttonMaxSize: CGFloat

    public init(type: SwitcherType = .segement,
                underlineType: UnderlineType = .corner,
                seperatelineType: SeperatelineType = .none,
                horizontalMargin: CGFloat = 16,
                horizontalSpace: CGFloat = 32,
                normalTitleFont: UIFont = UIFont.systemFont(ofSize: 15),
                selectedTitleFont: UIFont = UIFont.systemFont(ofSize: 15, weight: .medium),
                normalTitleColor: UIColor = UIColor.gray,
                selectedTitleColor: UIColor = UIColor.darkGray,
                indicatorWidth: CGFloat? = nil,
                indicatorHeight: CGFloat = 2,
                indicatorColor: UIColor = UIColor.darkGray,
                badgeHeightForPointType: CGFloat = 9,
                badgeHeightForCountType: CGFloat = 15,
                badgeHeightForCustomType: CGFloat = 14,
                badgeFontForCountType: UIFont = UIFont.systemFont(ofSize: 10, weight: .regular),
                isVerticalScrollable: Bool = true,
                isScrollEnabled: Bool = true,
                buttonMaxSize: CGFloat = 1000) {
        self.type = type
        self.underlineType = underlineType
        self.seperatelineType = seperatelineType
        self.horizontalMargin = horizontalMargin
        self.horizontalSpace = horizontalSpace
        self.normalTitleFont = normalTitleFont
        self.selectedTitleFont = selectedTitleFont
        self.normalTitleColor = normalTitleColor
        self.selectedTitleColor = selectedTitleColor
        self.indicatorWidth = indicatorWidth
        self.indicatorHeight = indicatorHeight
        self.indicatorColor = indicatorColor
        self.badgeHeightForPointType = badgeHeightForPointType
        self.badgeHeightForCountType = badgeHeightForCountType
        self.badgeHeightForCustomType = badgeHeightForCustomType
        self.badgeFontForCountType = badgeFontForCountType
        self.isVerticalScrollable = isVerticalScrollable
        self.isScrollEnabled = isScrollEnabled
        self.buttonMaxSize = buttonMaxSize
    }

}
