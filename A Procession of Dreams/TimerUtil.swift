//
//  TimeUpdater.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-11-30.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import Foundation

class TimerUtil {
    
    var duration: Double! 
    
    func getFormattedTime(seconds: Int) -> String {
        if seconds <= 0 {
            return "00:00"
        }
        var formattedTime: String!
        
        let hours = getHours(seconds: seconds)
        //print("Hours: \(hours)")
        let strMins = getFormattedMinutes(seconds: seconds)
        //print("Minutes: " + strMins)
        let strSecs = getFormattedSeconds(seconds: seconds)
        //print("Seconds: " + strSecs)
        if hours > 0 {
            var strHours = "\(hours)"
            if hours < 10 {
                strHours = "0\(hours)"
            }
            formattedTime = String(strHours + ":" + strMins + ":" + strSecs)
        } else {
            formattedTime = String(strMins + ":" + strSecs)
        }
        return formattedTime
    }
    
    func getHours(seconds: Int) -> Int {
        let hours = seconds/3600
        //print("hours \(hours)")
        return hours
    }
    
    func getFormattedMinutes(seconds: Int) -> String {
        let h = seconds/3600
        var m = seconds/60
        if m == 0 {
            return "00"
        }
        if h > 0 {
            m = m - (h * 60)
        }
        var strMins = "\(m)"
        if m < 10 {
            strMins = "0\(m)"
        }
        return strMins
    }
    
    func getFormattedSeconds(seconds: Int) -> String {
        let m = seconds/60
        let s = seconds - (m * 60)
        if s == 0 {
            return "00"
        }
        var strSecs = "\(s)"
        if s < 10 {
            strSecs = "0\(s)"
        }
        return strSecs
    }
    
    func getTimeAsFloat(expired: Double) -> Float {
        let denominator = duration/100.0
        let timeAsFloat = (expired/denominator)
        return Float(timeAsFloat)
    }
    
}
