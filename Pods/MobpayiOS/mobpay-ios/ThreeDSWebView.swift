//
//  ThreeDSWebView.swift
//  mobpay-ios
//
//  Created by Allan Mageto on 13/08/2019.
//  Copyright © 2019 Allan Mageto. All rights reserved.
//

import UIKit
import WebKit


class ThreeDSWebView: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    var webCardinalURL: URL!
    
    convenience init(webCardinalURL:URL){
        self.init()
        self.webCardinalURL = webCardinalURL
    }
    
    override func loadView() {
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: webCardinalURL))
    }
}
