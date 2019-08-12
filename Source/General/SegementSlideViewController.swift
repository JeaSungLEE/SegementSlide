//
//  SegementSlideViewController.swift
//  SegementSlide
//
//  Created by Jiar on 2018/12/7.
//  Copyright © 2018 Jiar. All rights reserved.
//

import UIKit

public enum BouncesType {
    case parent
    case child
}

struct SegementSlideViewControllerAssociatedKeys {
    static var innerBouncesType: BouncesType = .parent
    static var canParentViewScroll: Bool = true
    static var canChildViewScroll: Bool = false
    static var lastChildBouncesTranslationY: CGFloat = 0
    static var waitTobeResetContentOffsetY: Set<Int> = Set()
}

protocol SegementSlideViewController: UIViewController {

    var segementSlideScrollView: SegementSlideScrollView! { get set }
    var segementSlideHeaderView: SegementSlideHeaderView! { get set }
    var segementSlideContentView: SegementSlideContentView! { get set }
    var segementSlideSwitcherView: SegementSlideSwitcherView! { get set }
    var innerHeaderHeight: CGFloat? { get set }
    var innerHeaderView: UIView? { get set }
    
    var safeAreaTopConstraint: NSLayoutConstraint? { get set }
    var parentKeyValueObservation: NSKeyValueObservation? { get set }
    var childKeyValueObservation: NSKeyValueObservation? { get set }

    
    var slideScrollView: UIScrollView { get }
    var slideSwitcherView: UIView { get }
    var slideContentView: UIView { get }
    var contentViewHeight: CGFloat { get }
    var currentIndex: Int? { get }
    var currentSegementSlideContentViewController: SegementSlideContentScrollViewDelegate? { get }
    var headerStickyHeight: CGFloat { get }
    var bouncesType: BouncesType { get }
    var headerHeight: CGFloat? { get }
    var headerView: UIView? { get }
    var switcherHeight: CGFloat { get }
    var switcherConfig: SegementSlideSwitcherConfig { get }
    var titlesInSwitcher: [String] { get }

    func showBadgeInSwitcher(at index: Int) -> BadgeType
    func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate?
    func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool)
    func didSelectContentViewController(at index: Int, viewController: SegementSlideContentScrollViewDelegate?)
    func reloadData()
    func reloadHeader()
    func reloadSwitcher()
    func reloadBadgeInSwitcher()
    func reloadContent()
    func scrollToSlide(at index: Int, animated: Bool)
    func dequeueReusableViewController(at index: Int) -> SegementSlideContentScrollViewDelegate?
}

extension SegementSlideViewController {
    var innerBouncesType: BouncesType {
        get {
            guard let value = objc_getAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.innerBouncesType) as? BouncesType else {
                return .parent
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.innerBouncesType, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var canParentViewScroll: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.canParentViewScroll) as? Bool else {
                return true
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.canParentViewScroll, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var canChildViewScroll: Bool {
        get {
            guard let value = objc_getAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.canChildViewScroll) as? Bool else {
                return false
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.canChildViewScroll, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var lastChildBouncesTranslationY: CGFloat {
        get {
            guard let value = objc_getAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.lastChildBouncesTranslationY) as? CGFloat else {
                return 0
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.lastChildBouncesTranslationY, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var waitTobeResetContentOffsetY: Set<Int> {
        get {
            guard let value = objc_getAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.waitTobeResetContentOffsetY) as? Set<Int> else {
                return Set()
            }
            return value
        }
        set(newValue) {
            objc_setAssociatedObject(self, &SegementSlideViewControllerAssociatedKeys.waitTobeResetContentOffsetY, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    var slideScrollView: UIScrollView {
        return segementSlideScrollView
    }
    var slideSwitcherView: UIView {
        return segementSlideSwitcherView
    }
    var slideContentView: UIView {
        return segementSlideContentView
    }
    var currentIndex: Int? {
        return segementSlideSwitcherView.selectedIndex
    }
    var currentSegementSlideContentViewController: SegementSlideContentScrollViewDelegate? {
        guard let currentIndex = currentIndex else { return nil }
        return segementSlideContentView.dequeueReusableViewController(at: currentIndex)
    }
    var bouncesType: BouncesType {
        return .parent
    }
    var switcherHeight: CGFloat {
        return 44
    }

    var switcherConfig: SegementSlideSwitcherConfig {
        return SegementSlideSwitcherConfig.shared
    }

    var titlesInSwitcher: [String] {
        #if DEBUG
        assert(false, "must override this variable")
        #endif
        return []
    }

    func showBadgeInSwitcher(at index: Int) -> BadgeType {
        return .none
    }

    func segementSlideContentViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        #if DEBUG
        assert(false, "must override this function")
        #endif
        return nil
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView, isParent: Bool) {

    }

    func didSelectContentViewController(at index: Int, viewController: SegementSlideContentScrollViewDelegate?) {

    }

    /// reload headerView, SwitcherView and ContentView
    ///
    /// you should call `scrollToSlide(at index: Int, animated: Bool)` after call the method.
    /// otherwise, none of them will be selected.
    /// However, if an item was previously selected, it will be reSelected.
    func reloadData() {
        setupBounces()
        setupHeader()
        setupSwitcher()
        waitTobeResetContentOffsetY.removeAll()
        segementSlideContentView.reloadData()
        segementSlideSwitcherView.reloadData()
        layoutSegementSlideScrollView()
    }

    /// reload headerView
    func reloadHeader() {
        setupHeader()
        layoutSegementSlideScrollView()
    }

    /// reload SwitcherView
    func reloadSwitcher() {
        setupSwitcher()
        segementSlideSwitcherView.reloadData()
        layoutSegementSlideScrollView()
    }

    /// reload badges in SwitcherView
    func reloadBadgeInSwitcher() {
        segementSlideSwitcherView.reloadBadges()
    }

    /// reload ContentView
    func reloadContent() {
        waitTobeResetContentOffsetY.removeAll()
        segementSlideContentView.reloadData()
    }

    /// select one item by index
    func scrollToSlide(at index: Int, animated: Bool) {
        segementSlideSwitcherView.selectSwitcher(at: index, animated: animated)
    }

    /// reuse the `SegementSlideContentScrollViewDelegate`
    func dequeueReusableViewController(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return segementSlideContentView.dequeueReusableViewController(at: index)
    }
}
