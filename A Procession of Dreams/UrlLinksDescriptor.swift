//
//  MoreDescriptor.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-12-13.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import Foundation

let CONTACT_CORSAGE = "Contact Corsage"

class UrlLinksDescriptor {
    
    var titles: NSArray!
    var urls: NSArray!
    
    init() {
        self.titles = NSArray(objects:
            "Home Page",
            CONTACT_CORSAGE,
            "Image Gallery",
            "Review - 2014",
            "'It All Slips Away' - 2014",
            "'The Comeuppance' - 2010",
            "Live: Summer of Love - 2009",
            "'Jackson' - 1998",
            "Live: Soundproof - 1993",
            "'The Shame I Feel' - 1983",
            "'Western Roll'",
            "Review - 2002")
        
        self.urls = NSArray(objects:
            "https://www.bandmine.com/smithcorsage",
            CONTACT_CORSAGE,
            "",
            "https://www.citr.ca/discorder/jancember-2014-2015/corsage/",
            "https://www.youtube.com/watch?v=cNpHStLkUmQcorsage/",
            "https://www.youtube.com/watch?v=ev6w1eMByio&list=PL17BE4629C6398852&index=6",
            "https://www.youtube.com/watch?v=bZCXUoBAPiU&list=PL17BE4629C6398852&index=19",
            "https://www.youtube.com/watch?v=M_dPcjqKeFI&list=PL17BE4629C6398852&index=11",
            "https://www.youtube.com/watch?v=45e-3CvM6kQ&list=PL17BE4629C6398852&index=16",
            "https://www.youtube.com/watch?v=kqSugPLlU7E",
            "http://www.cdbaby.com/cd/corsage",
            "http://www.johncodyonline.com/home/music/SmithPhil.html")
        
        assert(titles.count == urls.count)
    }
    
    func getNumberOfLinks() -> Int {
        return titles.count
    }

    func getTitleForIndex(index: Int) -> String {
        return self.titles[index] as! String
    }
    
    func getUrlForIndex(index: Int) -> String {
        return self.urls[index] as! String
    }

}
