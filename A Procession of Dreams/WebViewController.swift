//
//  WebViewController.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-12-13.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {

    var urlString: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    @IBAction func onDismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: urlString!)!
        webView.loadRequest(URLRequest(url: url as URL))
    }
}
