//
//  InitViewController.swift
//  IVPN Client
//
//  Created by Fedir Nepyyvoda on 7/13/16.
//  Copyright © 2016 IVPN. All rights reserved.
//

import UIKit

class InitViewController: UIViewController {
    
    // MARK: - @IBOutlets -
    
    @IBOutlet weak var startFreeTrialButton: UIButton!
    @IBOutlet weak var promotionsView: UIView!
    
    // MARK: - Properties -
    
    private var pageViewController: UIPageViewController!
    private var promotionsDataSrouce: PromotionsDataSource!
    private var segueIdentifier = ""
    
    // MARK: - @IBActions -
    
    @IBAction func close(_ sender: Any) {
        navigationController?.dismiss(animated: true, completion: {
            NotificationCenter.default.post(name: Notification.Name.AuthenticationDismissed, object: nil)
        })
    }
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.accessibilityIdentifier = "initScreen"
        
        promotionsDataSrouce = PromotionsDataSource()
        createPageViewController()
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if modalPresentationStyle == .fullScreen {
            navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if modalPresentationStyle == .fullScreen {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    deinit {
        removeObservers()
    }
    
    // MARK: - Segues -
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        guard UserDefaults.shared.hasUserConsent else {
            segueIdentifier = identifier
            present(NavigationManager.getTermsOfServiceViewController(), animated: true, completion: nil)
            return false
        }
        
        return true
    }
    
    // MARK: - Observers -
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(termsOfServiceAgreed), name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLogin), name: Notification.Name.ShowLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showCreateAccount), name: Notification.Name.ShowCreateAccount, object: nil)
    }
    
    func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.TermsOfServiceAgreed, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ShowLogin, object: nil)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.ShowCreateAccount, object: nil)
    }
    
    @objc func termsOfServiceAgreed() {
        performSegue(withIdentifier: segueIdentifier, sender: self)
    }
    
    @objc func showLogin() {
        performSegue(withIdentifier: "LogIn", sender: self)
    }
    
    @objc func showCreateAccount() {
        performSegue(withIdentifier: "CreateAccount", sender: self)
    }
    
    // MARK: - Private functions -
    
    fileprivate func findPageControl(_ view: UIView) -> UIPageControl? {
        for subview in view.subviews {
            
            if let subview = subview as? UIPageControl {
                return subview
            }
        }
        
        return nil
    }
    
    fileprivate func createPageViewController() {
        let startingViewController: UIViewController = promotionsDataSrouce.viewControllerAtIndex(0, storyboard: storyboard!)!
        let viewControllers = [startingViewController]
        
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.delegate = promotionsDataSrouce
        pageViewController.setViewControllers(viewControllers, direction: .forward, animated: false, completion: nil)
        pageViewController.dataSource = promotionsDataSrouce
        addChild(pageViewController)
        
        if let pageControl = findPageControl(pageViewController.view) {
            if #available(iOS 13.0, *) {
                pageControl.pageIndicatorTintColor = UIColor.tertiaryLabel
            } else {
                pageControl.pageIndicatorTintColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            }
            pageControl.currentPageIndicatorTintColor = UIColor(named: Theme.Key.ivpnBlue)
        }
        
        promotionsView.addSubview(pageViewController.view)
        
        let pageViewRect = self.promotionsView.bounds
        pageViewController.view.frame = pageViewRect
        pageViewController.didMove(toParent: self)
    }
    
}
