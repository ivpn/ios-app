//
//  PromotionsDataSource.swift
//  IVPN iOS app
//  https://github.com/ivpn/ios-app
//
//  Created by Fedir Nepyyvoda on 2016-07-11.
//  Copyright (c) 2020 Privatus Limited.
//
//  This file is part of the IVPN iOS app.
//
//  The IVPN iOS app is free software: you can redistribute it and/or
//  modify it under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option) any later version.
//
//  The IVPN iOS app is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
//  or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
//  details.
//
//  You should have received a copy of the GNU General Public License
//  along with the IVPN iOS app. If not, see <https://www.gnu.org/licenses/>.
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
