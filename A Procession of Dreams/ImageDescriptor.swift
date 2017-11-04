//
//  ImageDescriptor.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-12-19.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import Foundation

class ImageDescriptor {
    
    var imageArray: [String]!
    var titleArray: [String]!
    
    init() {
        imageArray = [String]()
        
        imageArray.append("band_sol1_med.jpg")
        imageArray.append("coliseum_backstage_med.jpg")
        imageArray.append("waldorf_med.jpg")
        imageArray.append("phil_townpump1988_med.png")
        imageArray.append("band_sol2_med.jpg")
        imageArray.append("bill_summeroflove2009_med.jpg")
        imageArray.append("phil_summeroflove2009_med.jpg")
        imageArray.append("john_townpump1988_med.jpg")
        imageArray.append("ron_townpump1988_med.jpg")
        imageArray.append("band_sol3_med.jpg")
        imageArray.append("ron_summeroflove2009_med.jpg")
        imageArray.append("phil_and_clown_med.jpg")
        imageArray.append("ubc_sub_med.jpg")
        imageArray.append("bill_townpump1988_med.jpg")
        imageArray.append("band_sol4_med.jpg")
        imageArray.append("summeroflove_poster_med.jpg")
        imageArray.append("gord_summeroflove2009_med.jpg")
        imageArray.append("john_summeroflove2009_med.jpg")
        
        titleArray = [String]()
    }
    
    func getNumberOfImages() -> Int {
        return imageArray.count
    }
    
    func getImageForIndex(index: Int) -> String {
        return self.imageArray[index]
    }
    
    func getTitleForIndex(index: Int) -> String {
        return ""
    }
}
