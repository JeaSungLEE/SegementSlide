//
//  SegementSlideSwitcherView.swift
//  SegementSlide
//
//  Created by Jiar on 2018/12/7.
//  Copyright © 2018 Jiar. All rights reserved.
//

import UIKit

public enum SwitcherType {
    case tab
    case segement
}

public enum UnderlineType {
    case normal
    case corner
}

public enum SeperatelineType {
    case none
    case full
}

public protocol SegementSlideSwitcherViewDelegate: class {
    var titlesInSegementSlideSwitcherView: [String] { get }

    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideSwitcherView, didSelectAtIndex index: Int, animated: Bool)
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideSwitcherView, showBadgeAtIndex index: Int) -> BadgeType
}

public protocol SegementSlideSwitcherViewSelectDelegate: class {
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideSwitcherView, didSelectAtIndex index: Int)
}

private class SegementSlideIndicatorView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return false
    }
    
}

open class SegementSlideSwitcherView: UIView {
    public let scrollView = UIScrollView()
    public let seperatelineView = UIView()
    public var titleButtons: [UIButton] = []
    public var initSelectedIndex: Int?
    public var innerConfig: SegementSlideSwitcherConfig = SegementSlideSwitcherConfig.shared
    public var indicatorView: UIView = SegementSlideIndicatorView()
    
    internal var gestureRecognizersInScrollView: [UIGestureRecognizer]? {
        return scrollView.gestureRecognizers
    }

    public var selectedIndex: Int?
    public weak var delegate: SegementSlideSwitcherViewDelegate?
    public weak var selectDelegate: SegementSlideSwitcherViewSelectDelegate?

    /// you must call `reloadData()` to make it work, after the assignment.
    public var config: SegementSlideSwitcherConfig = SegementSlideSwitcherConfig.shared

    public override var intrinsicContentSize: CGSize {
        return scrollView.contentSize
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        clipsToBounds = false
        backgroundColor = .white
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.backgroundColor = .clear
        addSubview(scrollView)
        
        scrollView.constraintToSuperview()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        
        layoutTitleButtons()
        reloadBadges()
        recoverInitSelectedIndex()
        updateSelectedIndex()
    }

    /// relayout subViews
    ///
    /// you should call `selectSwitcher(at index: Int, animated: Bool)` after call the method.
    /// otherwise, none of them will be selected.
    /// However, if an item was previously selected, it will be reSelected.
    open func reloadData() {
        for titleButton in titleButtons {
            titleButton.removeFromSuperview()
            titleButton.frame = .zero
        }
        titleButtons.removeAll()
        indicatorView.removeFromSuperview()
        seperatelineView.removeFromSuperview()
        indicatorView.frame = .zero
        scrollView.isScrollEnabled = innerConfig.type == .segement
        innerConfig = config
        guard let titles = delegate?.titlesInSegementSlideSwitcherView else { return }
        guard !titles.isEmpty else { return }
        for (index, title) in titles.enumerated() {
            let button = UIButton(type: .custom)
            button.clipsToBounds = false
            button.titleLabel?.font = innerConfig.normalTitleFont
            button.backgroundColor = .clear
            button.setTitle(title, for: .normal)
            button.tag = index
            button.setTitleColor(innerConfig.normalTitleColor, for: .normal)
            button.titleLabel?.lineBreakMode = .byTruncatingTail
            button.addTarget(self, action: #selector(didClickTitleButton), for: .touchUpInside)
            scrollView.addSubview(button)
            titleButtons.append(button)
        }
        guard !titleButtons.isEmpty else { return }

        if innerConfig.seperatelineType == .full {
            scrollView.addSubview(seperatelineView)
            seperatelineView.backgroundColor = innerConfig.seperatelineColor
        }

        scrollView.addSubview(indicatorView)

        if innerConfig.underlineType == .corner {
            indicatorView.layer.masksToBounds = true
            indicatorView.layer.cornerRadius = innerConfig.indicatorHeight/2
        }

        indicatorView.backgroundColor = innerConfig.indicatorColor
        layoutTitleButtons()
        reloadBadges()
        updateSelectedIndex()
    }

    /// reload all badges in `SegementSlideSwitcherView`
    open func reloadBadges() {
        for (index, titleButton) in titleButtons.enumerated() {
            guard let type = delegate?.segementSwitcherView(self, showBadgeAtIndex: index) else {
                titleButton.insideBadge.type = .none
                continue
            }
            titleButton.insideBadge.type = type
            if case .none = type {
                continue
            }
            let titleLabelText = titleButton.titleLabel?.text ?? ""
            let width: CGFloat
            if selectedIndex == index {
                width = titleLabelText.boundingWidth(with: innerConfig.selectedTitleFont)
            } else {
                width = titleLabelText.boundingWidth(with: innerConfig.normalTitleFont)
            }
            let height = titleButton.titleLabel?.font.lineHeight ?? titleButton.bounds.height
            switch type {
            case .none:
                break
            case .point:
                titleButton.insideBadge.height = innerConfig.badgeHeightForPointType
                titleButton.insideBadge.offset = CGPoint(x: width/2+titleButton.insideBadge.height/2, y: -height/2)
            case .count:
                titleButton.insideBadge.font = innerConfig.badgeFontForCountType
                titleButton.insideBadge.height = innerConfig.badgeHeightForCountType
                titleButton.insideBadge.offset = CGPoint(x: width/2+titleButton.insideBadge.height/2, y: -height/2)
            case .custom:
                titleButton.insideBadge.height = innerConfig.badgeHeightForCustomType
                titleButton.insideBadge.offset = CGPoint(x: width/2+titleButton.insideBadge.height/2, y: -height/2)
            }
        }
    }
    
    open func layoutTitleButtons() {
        guard scrollView.frame != .zero else { return }
        guard !titleButtons.isEmpty else {
            scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height)
            return
        }
        var offsetX = innerConfig.horizontalMargin
        for titleButton in titleButtons {
            let buttonWidth: CGFloat
            switch innerConfig.type {
            case .tab:
                buttonWidth = (bounds.width-innerConfig.horizontalMargin*2)/CGFloat(titleButtons.count)
            case .segement:
                let title = titleButton.title(for: .normal) ?? ""
                let normalButtonWidth = title.boundingWidth(with: innerConfig.normalTitleFont)
                let selectedButtonWidth = title.boundingWidth(with: innerConfig.selectedTitleFont)
                buttonWidth = selectedButtonWidth > normalButtonWidth ? min(innerConfig.buttonMaxSize, selectedButtonWidth) : min(innerConfig.buttonMaxSize, normalButtonWidth)
            }
            titleButton.frame = CGRect(x: offsetX, y: 0, width: buttonWidth, height: scrollView.bounds.height)
            switch innerConfig.type {
            case .tab:
                offsetX += buttonWidth
            case .segement:
                offsetX += buttonWidth+innerConfig.horizontalSpace
            }
        }
        switch innerConfig.type {
        case .tab:
            scrollView.contentSize = CGSize(width: bounds.width, height: bounds.height)
        case .segement:
            scrollView.contentSize = CGSize(width: offsetX-innerConfig.horizontalSpace+innerConfig.horizontalMargin, height: bounds.height)
        }
        
        seperatelineView.frame = CGRect(x: 0, y: bounds.height, width: bounds.width, height: 1)
    }
    
    open func updateSelectedButton(at index: Int, animated: Bool) {
        guard scrollView.frame != .zero else {
            initSelectedIndex = index
            return
        }
        guard titleButtons.count != 0 else { return }
        if let selectedIndex = selectedIndex, selectedIndex >= 0, selectedIndex < titleButtons.count {
            let titleButton = titleButtons[selectedIndex]
            titleButton.setTitleColor(innerConfig.normalTitleColor, for: .normal)
            titleButton.titleLabel?.font = innerConfig.normalTitleFont
        }
        guard index >= 0, index < titleButtons.count else { return }
        let titleButton = titleButtons[index]
        titleButton.setTitleColor(innerConfig.selectedTitleColor, for: .normal)
        titleButton.titleLabel?.font = innerConfig.selectedTitleFont
        if let indicatorWidth = innerConfig.indicatorWidth {
            if animated, indicatorView.frame != .zero {
                UIView.animate(withDuration: 0.1) {
                    self.indicatorView.frame = CGRect(x: titleButton.frame.origin.x+(titleButton.bounds.width-indicatorWidth)/2, y: self.frame.height-self.innerConfig.indicatorHeight + 1, width: indicatorWidth, height: self.innerConfig.indicatorHeight)
                }
            } else {
                indicatorView.frame = CGRect(x: titleButton.frame.origin.x+(titleButton.bounds.width-indicatorWidth)/2, y: frame.height-innerConfig.indicatorHeight + 1, width: indicatorWidth, height: innerConfig.indicatorHeight)
            }
        } else {
            indicatorView.frame = CGRect(x: titleButton.frame.origin.x, y: frame.height-innerConfig.indicatorHeight + 1, width: titleButton.frame.size.width, height: innerConfig.indicatorHeight)
        }
        if case .segement = innerConfig.type {
            var offsetX = titleButton.frame.origin.x-(scrollView.bounds.width-titleButton.bounds.width)/2
            if offsetX < 0 {
                offsetX = 0
            } else if (offsetX+scrollView.bounds.width) > scrollView.contentSize.width {
                offsetX = scrollView.contentSize.width-scrollView.bounds.width
            }
            if scrollView.contentSize.width > scrollView.bounds.width {
                scrollView.setContentOffset(CGPoint(x: offsetX, y: scrollView.contentOffset.y), animated: animated)
            }
        }
        
        guard index != selectedIndex else { return }
        selectedIndex = index
        delegate?.segementSwitcherView(self, didSelectAtIndex: index, animated: animated)
    }

    /// select one item by index
    public func selectSwitcher(at index: Int, animated: Bool) {
        updateSelectedButton(at: index, animated: animated)
    }
    
    public func setSeperatelineView(alpha: CGFloat) {
        seperatelineView.alpha = alpha
    }

}

extension SegementSlideSwitcherView {

    private func recoverInitSelectedIndex() {
        guard let initSelectedIndex = initSelectedIndex else { return }
        self.initSelectedIndex = nil
        updateSelectedButton(at: initSelectedIndex, animated: false)
    }
    
    public func updateSelectedIndex() {
        guard let selectedIndex = selectedIndex else { return }
        updateSelectedButton(at: selectedIndex, animated: false)
    }

    @objc public func didClickTitleButton(_ button: UIButton) {
        
        let index = button.tag
        if selectedIndex == index {
            selectDelegate?.segementSwitcherView(self, didSelectAtIndex: index)
        } else {
            selectSwitcher(at: index, animated: true)
        }
    }

}
