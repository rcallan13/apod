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
    var songImage: UIImageView?
    var songTitle: UILabel?
    
    var pageTitle: String!
    var pageImage: String!
    var pageSong: String!
    var pageIndex: Int!
    
    var imageRect: CGRect?
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillLayoutSubviews() {
        songImage?.removeFromSuperview()
        songImage = UIImageView(frame: CGRect.make(20, 100, self.view.frame.width - 40, self.view.frame.height/2))
        self.songImage?.image = UIImage(named: self.pageImage)
        self.songImage?.contentMode = .scaleAspectFit
        self.view.addSubview(songImage!)
        
        songTitle?.removeFromSuperview()
        songTitle = UILabel(frame: CGRect.make(0, (songImage?.frame.origin.y)! + (songImage?.frame.height)! + 20, self.view.frame.width - 32, 20))
        self.view.addSubview(songTitle!)
        self.songTitle?.text = self.pageTitle
        self.songTitle?.textAlignment = .right
        self.songTitle?.textColor = UIColor.white
        self.songTitle?.font = UIFont(name: "Chalkboard SE", size: 16)
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
