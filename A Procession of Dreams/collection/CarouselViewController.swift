//
//  CarouselViewController.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-12-16.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import UIKit



class CarouselViewController: UICollectionViewController {
    
    let reuseIdentifier = "carouCell"
    let headerIdentifier = "headerView"
    let footerIdentifier = "footerView"
    var images: ImageDescriptor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        images = ImageDescriptor()
        collectionView?.backgroundColor = UIColor(white: 1, alpha: 0.75)
    }

    @IBAction func onDismiss(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.getNumberOfImages()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
                                 viewForSupplementaryElementOfKind kind: String,
                                 at indexPath: IndexPath) -> UICollectionReusableView {
        //1
        switch kind {
        //2
        case UICollectionElementKindSectionHeader:
            //3
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "headerView",
                                                                             for: indexPath) as! CollectionViewHeader
            headerView.dismissButton.addTarget(self, action: #selector(onHeaderDismissTapped(_:)), for: .touchUpInside)
            return headerView
        case UICollectionElementKindSectionFooter:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: "footerView",
                                                                             for: indexPath) as! CollectionViewHeader
            headerView.dismissButton.addTarget(self, action: #selector(onFooterDismissTapped(_:)), for: .touchUpInside)
            return headerView
        default:
            //4
            assert(false, "Unexpected element kind")
        }
        return UICollectionReusableView()
    }
    
    @objc func onHeaderDismissTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onFooterDismissTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)  as! MyCell
        let image = UIImage(named: images.getImageForIndex(index: indexPath.row))
        cell.cellImage.image = image
        return cell
    }

    // MARK: UICollectionViewDelegate

    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let image = UIImage(named: images.getImageForIndex(index: indexPath.row))
        //.withAlignmentRectInsets(UIEdgeInsets(top: 2, left: 0, bottom: 0, right: 0))
        let w = self.view.frame.width - 80
        let y = self.view.center.y - w/2
        let overlayImageView = UIButton(frame: CGRect.make(40, y, w, w))
        overlayImageView.frame = CGRect.make(30, y, w, w)
        overlayImageView.layer.borderColor = UIColor.white.cgColor
        overlayImageView.layer.borderWidth = 4
        overlayImageView.layer.shadowRadius = 10.0
        overlayImageView.layer.masksToBounds = false
        overlayImageView.layer.shadowOffset = CGSize(width: 10, height: 10)
        overlayImageView.layer.shadowColor = UIColor.darkGray.cgColor
        overlayImageView.setBackgroundImage(image, for: .normal)
        
        self.view.addSubview(overlayImageView)
        self.view.bringSubview(toFront: overlayImageView)
        overlayImageView.addTarget(self, action: #selector(onImageTapped(_:)), for: .touchUpInside)
        
        
        overlayImageView.isHidden = true
        var scale = CGAffineTransform(scaleX: 0, y: 0)
        overlayImageView.transform = scale
        overlayImageView.isHidden = false
        scale = CGAffineTransform(scaleX: 1, y: 1)
        UIView.animate(withDuration: 0.3, animations: {
            collectionView.alpha = 0.85
            overlayImageView.transform = scale
        })
    }
    
    @objc func onImageTapped(_ sender: UIImageView) {
        let scale = CGAffineTransform(scaleX: 0, y: 0)
        UIView.animate(withDuration: 0.8, animations: {
            self.collectionView?.alpha = 1
            sender.transform = scale
        }, completion: {(finished: Bool) in
            
        })
    }
   
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Uncomment this method to specify if the specified item should be selected
    /*
    
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(collectionView: UICollectionView, shouldShowMenuForItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, canPerformAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) -> Bool {
        return false
    }

    override func collectionView(collectionView: UICollectionView, performAction action: Selector, forItemAtIndexPath indexPath: NSIndexPath, withSender sender: AnyObject?) {
    
        
    }
*/


}
