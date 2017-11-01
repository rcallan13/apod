//
//  SongDescriptor.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-10-26.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import Foundation

let NUMBER_OF_SONGS = 5

class SongDescriptor {
    
    static var songs = ["heaven", "slips", "leave", "life", "coda"]
    static var lyrics = [String]()
    static var titles = ["From Earth To Heaven With A Smile", "It All Slips Away", "As I Must Leave You", "Life Goes On (Without You)", "Coda"]
    static var pageImages = ["arm_image_white", "leg_image_white", "head_image_white", "top_half_white", "full_body_white2"]
    
    static func initLyrics() {
        for count in 0..<NUMBER_OF_SONGS {
            SongDescriptor.lyrics.append(SongDescriptor.readDocs(fileName: "song\(count)"))
        }
    }
    
    // MARK: - song descriptor
    static func getSongAtIndex(index: Int) -> String {
        print("getSongAtIndex INDEX: \(index).txt")
        return SongDescriptor.songs[index]
    }
    
    static func getNumSongs() -> Int {
        return songs.count
    }
    
    static func getLyric(index: Int) -> String {
        if index > -1 && index < NUMBER_OF_SONGS {
            return SongDescriptor.lyrics[index]
        }
        return String()
    }
    
    static func readDocs(fileName: String) -> String {
        let documentsPath = Bundle.main.path(forResource: fileName, ofType: "txt")
        var file:String = ""
        do {
            file = try NSString(contentsOfFile: documentsPath!, usedEncoding: nil) as String
        } catch {
            
        }
        return file
    
    }
    
    static func readFromDocumentsFile(fileName:String) -> String {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
       
        let path = documentsPath.strings(byAppendingPaths: [fileName])
        let checkValidation = FileManager.default
        var file:String = ""
        
        if checkValidation.fileExists(atPath: path[0]) {
            do {
                file = try NSString(contentsOfFile: path[0], usedEncoding: nil) as String
            } catch {
                
            }
        } else {
            file = "*ERROR* \(fileName) does not exist."
        }
        
        return file
    }
}
