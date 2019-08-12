//
//  SegementSlideViewController+ex.swift
//  SegementSlide
//
//  Created by Jiar on 2019/1/16.
//  Copyright © 2019 Jiar. All rights reserved.
//

import UIKit

extension SegementSlideViewController where Self: UIViewController {
    var contentViewHeight: CGFloat {
        return view.bounds.height-topLayoutLength-switcherHeight
    }
    var headerStickyHeight: CGFloat {
        guard let innerHeaderHeight = innerHeaderHeight else {
            return 0
        }
        if edgesForExtendedLayout.contains(.top) {
            return innerHeaderHeight-topLayoutLength
        } else {
            return innerHeaderHeight
        }
    }
    /// the value should contains topLayoutGuide's length(safeAreaInsets.top in iOS 11), if the edgesForExtendedLayout in viewController contains `.top`
    var headerHeight: CGFloat? {
        if edgesForExtendedLayout.contains(.top) {
            #if DEBUG
            assert(false, "must override this variable")
            #endif
            return nil
        } else {
            return nil
        }
    }
    var headerView: UIView? {
        if edgesForExtendedLayout.contains(.top) {
            #if DEBUG
            assert(false, "must override this variable")
            #endif
            return nil
        } else {
            return nil
        }
    }
    
    var topLayoutLength: CGFloat {
        let topLayoutLength: CGFloat
        if #available(iOS 11, *) {
            topLayoutLength = view.safeAreaInsets.top
        } else {
            topLayoutLength = topLayoutGuide.length
        }
        return topLayoutLength
    }
    
    var bottomLayoutLength: CGFloat {
        let bottomLayoutLength: CGFloat
        if #available(iOS 11, *) {
            bottomLayoutLength = view.safeAreaInsets.bottom
        } else {
            bottomLayoutLength = bottomLayoutGuide.length
        }
        return bottomLayoutLength
    }
    
}
