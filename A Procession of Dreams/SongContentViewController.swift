//
//  SongContentViewController.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-10-26.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class SongContentViewController: UIViewController {
    
    var urlString: String!
    @IBOutlet weak var songImage: UIImageView!
    @IBOutlet weak var songTitle: UILabel!
    
    var pageTitle: String!
    var pageImage: String!
    var pageSong: String!
    var pageIndex: Int!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.songTitle.text = self.pageTitle
        self.songTitle.textAlignment = .right
        self.songImage.image = UIImage(named: self.pageImage)
    }
    
    // MARK: - file and actionsheet
    func displayActionSheet(itemTitle: String, fileContent: String) {
        let alert = UIAlertController(title: itemTitle as String, message: fileContent as String , preferredStyle: UIAlertControllerStyle.actionSheet)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = self.view
        } else {
            alert.modalPresentationStyle = .overFullScreen
        }
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) {
            (action: UIAlertAction) -> Void in
            // do nothing
            }
        )
        present(alert, animated: true, completion: nil)
    }
    
}
