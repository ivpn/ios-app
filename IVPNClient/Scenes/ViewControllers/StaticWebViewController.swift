//
//  StaticWebViewController.swift
//  IVPNClient
//
//  Created by Juraj Hilje on 02/04/2019.
//  Copyright © 2019 IVPN. All rights reserved.
//

import UIKit
import WebKit

class StaticWebViewController: UIViewController {
    
    @IBOutlet weak var webView: WKWebView!
    
    var resourceName = ""
    var screenTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = screenTitle
        
        if let data = FileSystemManager.loadDataFromResource(
            resourceName: resourceName,
            resourceType: "html",
            bundle: Bundle.main) {
            
            if let content = String(data: data, encoding: .utf8) {
                webView.loadHTMLString(content, baseURL: nil)
            }
        }
    }
    
}
