//
//  ModelController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/11/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

// swiftlint:disable identifier_name
private func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}
// swiftlint:enable identifier_name

// swiftlint:disable identifier_name
private func >= <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l >= r
    default:
        return !(lhs < rhs)
    }
}
// swiftlint:enable identifier_name

class PromotionsDataSource: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var pageData = ["page-main", "page-devices", "page-servers"]
    var indexOfCurrentPage = 0
    
    override init() {
        super.init()
    }
    
    func viewControllerAtIndex(_ index: Int, storyboard: UIStoryboard) -> UIViewController? {
        if self.pageData.count == 0 || index >= self.pageData.count { return nil }
        
        // Create a new view controller and pass suitable data.
        let dataViewController = storyboard.instantiateViewController(withIdentifier: pageData[index])
        return dataViewController
    }
    
    // MARK: - Page View Controller Data Source
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if viewController.restorationIdentifier == nil { return nil }
        
        let pageIndex = pageData.firstIndex(of: viewController.restorationIdentifier!)
        
        if pageIndex == 0 || pageIndex == nil { return nil }
        
        indexOfCurrentPage = pageIndex!
        
        return self.viewControllerAtIndex(pageIndex! - 1, storyboard: viewController.storyboard!)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        if viewController.restorationIdentifier == nil { return nil }
        
        let pageIndex = pageData.firstIndex(of: viewController.restorationIdentifier!)
        
        if pageIndex >= pageData.count - 1 || pageIndex == nil { return nil }
        
        indexOfCurrentPage = pageIndex!
        
        return self.viewControllerAtIndex(pageIndex! + 1, storyboard: viewController.storyboard!)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pageData.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return indexOfCurrentPage
    }
    
}
