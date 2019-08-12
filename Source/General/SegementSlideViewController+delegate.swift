//
//  SegementSlideViewController+delegate.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

extension SegementSlideViewController where Self: UIScrollViewDelegate {

    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        guard let contentViewController = currentSegementSlideContentViewController else {
            return true
        }
        guard let scrollView = contentViewController.scrollView else {
            return true
        }
        scrollView.contentOffset.y = 0
        return true
    }
    
}

extension SegementSlideViewController where Self: SegementSlideSwitcherViewDelegate {
    
    var titlesInSegementSlideSwitcherView: [String] {
        return titlesInSwitcher
    }
    
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideSwitcherView, didSelectAtIndex index: Int, animated: Bool) {
        if segementSlideContentView.selectedIndex != index {
            segementSlideContentView.scrollToSlide(at: index, animated: animated)
        }
    }
    
    func segementSwitcherView(_ segementSlideSwitcherView: SegementSlideSwitcherView, showBadgeAtIndex index: Int) -> BadgeType {
        return showBadgeInSwitcher(at: index)
    }
    
}

extension SegementSlideViewController where Self: SegementSlideContentDelegate {
    
    var segementSlideContentScrollViewCount: Int {
        return titlesInSwitcher.count
    }
    
    func segementSlideContentScrollView(at index: Int) -> SegementSlideContentScrollViewDelegate? {
        return segementSlideContentViewController(at: index)
    }
    
    func segementSlideContentView(_ segementSlideContentView: SegementSlideContentView, didSelectAtIndex index: Int, animated: Bool) {
        waitTobeResetContentOffsetY.insert(index)
        if segementSlideSwitcherView.selectedIndex != index {
            segementSlideSwitcherView.selectSwitcher(at: index, animated: animated)
        }
        childKeyValueObservation?.invalidate()
        guard let childViewController = segementSlideContentView.dequeueReusableViewController(at: index) else { return }
        defer {
            didSelectContentViewController(at: index, viewController: childViewController)
        }
        guard let scrollView = childViewController.scrollView else { return }
        let keyValueObservation = scrollView.observe(\.contentOffset, options: [.new, .old], changeHandler: { [weak self] (scrollView, change) in
            guard let self = self else { return }
            guard change.newValue != change.oldValue else { return }
            self.childScrollViewDidScroll(scrollView)
        })
        childKeyValueObservation = keyValueObservation
    }
    
}
