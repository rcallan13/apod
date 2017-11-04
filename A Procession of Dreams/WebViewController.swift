//
//  WebViewController.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-12-13.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import UIKit

class WebViewController: UIViewController, UIWebViewDelegate {

    var urlString: String?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webView: CallbackWebView!
    
    @IBAction func onDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = false
        self.view.bringSubview(toFront: activityIndicator)
        activityIndicator.startAnimating()
        webView.delegate = self
        let url = NSURL(string: urlString!)!
        webView.loadRequest(URLRequest(url: url as URL))
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
