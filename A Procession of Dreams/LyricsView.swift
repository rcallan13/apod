//
//  LyricsView.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2017-10-29.
//  Copyright © 2017 Ron Allan. All rights reserved.
//

import UIKit

class LyricsView: UIScrollView {

    let MARGIN_X: CGFloat = 8
    let MARGIN_Y: CGFloat = 8
    var titleLabel: UILabel?
    var lyricsLabel: UILabel?
    var creditsLabel: UILabel?

    var songIndex: Int? {
        didSet {
            let lightGray = UIColor(red: 0xDF, green: 0xDF, blue: 0xDF, alpha: 0.7)
            let title = SongDescriptor.titles[songIndex!]
            titleLabel = UILabel(frame: CGRect.make(2 * MARGIN_X, 3 * MARGIN_Y, self.frame.width - MARGIN_X, 20))
            titleLabel?.text = title
            titleLabel?.font = UIFont(name: "Arial", size: 18)
            titleLabel?.textColor = lightGray
            self.addSubview(titleLabel!)
            
            let lyric = SongDescriptor.lyrics[songIndex!]
            
            lyricsLabel = UILabel(frame: CGRect.make(2 * MARGIN_X, 4 * MARGIN_Y + (titleLabel?.frame.height)!, self.frame.width - MARGIN_X, self.frame.height/2))
            lyricsLabel?.numberOfLines = 0
            lyricsLabel?.font = UIFont(name: "Arial-Bold", size: 15)
            lyricsLabel?.textColor = UIColor.white
            lyricsLabel?.text = lyric
            lyricsLabel?.sizeToFit()
            addSubview(lyricsLabel!)
            
            self.layer.borderWidth = 1
            self.layer.borderColor = lightGray.cgColor
        }
    }
}
