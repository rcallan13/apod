//
//  MasterViewController.swift
//  A Procession of Dreams
//
//  Created by Ron Allan on 2015-10-26.
//  Copyright © 2015 Ron Allan. All rights reserved.
//

import UIKit
import MessageUI
import AVFoundation
import AVKit

@available(iOS 8.0, *)
class MasterViewController: UIViewController, MFMailComposeViewControllerDelegate, AVAudioPlayerDelegate {
    
    let BUTTON_SIZE: CGFloat = 38
    let MARGIN: CGFloat = 16
    
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var playbackView: UIView!
    
    @IBOutlet weak var timeExpiredLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    
    @IBOutlet weak var playButton: UIButton!
    
    
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var nowPlayingLabel: UILabel!
    
    let inc = 2.0
    var isPaused = false
    var audioPlayer: AVAudioPlayer!
    var moreBarButton: UIBarButtonItem?
    var lyricsButton: UIButton?
    var creditsButton: UIButton?
    
    var pageImages: NSArray!
    static var currentSong: Int = 0
    static var currentSongLocation: Int = 0
    var isAutoPlay: Bool = false
    var currentIndex: Int = 0
    var displayLink: CADisplayLink!
    var timerUtil: TimerUtil!
    var lastVal: Float = 0
    var lyricsView: LyricsView?
    var songLength: NSArray!
 
    // MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        SongDescriptor.initLyrics()
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "apod_bg.png")!)
        case .pad:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "apod_bg_trans.png")!)
        default:
            self.view.backgroundColor = UIColor(patternImage: UIImage(named: "apod_bg.png")!)
        }
        
        self.songLength = NSArray(objects: "05:18", "04:09", "05:33", "02:34", "02:01")
        
        currentIndex = 0
        timerUtil = TimerUtil()
    }
    
    @IBAction func onPhotos(_ sender: UIButton) {
        displayUrlActionSheet(sender: sender)
    }
    
    @IBAction func onLyrics(_ sender: Any) {
        if lyricsView != nil {
            onDismissLyrics(sender as AnyObject)
            return
        }
        /*
        let rect = (pageViewController?.view.frame)!
        lyricsView = LyricsView(frame: CGRect.make(rect.origin.x + MARGIN, rect.origin.y, rect.width - 2 * MARGIN, rect.height - 2 * BUTTON_SIZE))
        lyricsView?.isHidden = true
        lyricsView?.songIndex = currentIndex
        lyricsView?.backgroundColor = UIColor.black
        let dismiss = UIButton(frame: CGRect.make(((lyricsView?.frame.width)!) - BUTTON_SIZE, 0, BUTTON_SIZE, BUTTON_SIZE))
        dismiss.setTitle("X", for: .normal)
        dismiss.setTitleColor(UIColor.white, for: .normal)
        dismiss.addTarget(self, action: #selector(onDismissLyrics(_:)), for: .touchUpInside)
        lyricsView?.addSubview(dismiss)
        self.view.addSubview(lyricsView!)
        lyricsView?.contentSize = CGSize(width: self.view.frame.width - 32, height: (lyricsView?.lyricsLabel?.intrinsicContentSize.height)! + 70)
        
        var transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        lyricsView?.transform = transform
        lyricsView?.isHidden = false
        transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView?.transform = transform
        }, completion: {(finished: Bool) in
            
        })
     */
    }
    
    @objc func onDismissLyrics(_ sender: AnyObject) {
        let transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView?.transform = transform
        }, completion: {(finished: Bool) in
            self.lyricsView?.removeFromSuperview()
            self.lyricsView = nil
        })
    }
    
    @objc func onPlay(_ sender: AnyObject) {
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                isPaused = true
                playButton?.setImage(UIImage(named: "play.png"), for: .normal)
                return
            }
            if  isPaused {
                audioPlayer.play()
                displayLink = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
                displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                if audioPlayer.isPlaying {
                    isPaused = false
                    playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
                }
                return
            }
        }
        playSong(getIndexForPage())
    }
    
    private func toInt(rem: Double) -> Int {
        let delta:Int = Int(rem)
        return delta
    }
    
    @objc func updateSliderProgress() {
        if timerUtil != nil && audioPlayer != nil {
            let deltaRem = toInt(rem: timerUtil.duration - audioPlayer.currentTime)
            let remTime = timerUtil.getFormattedTime(seconds: deltaRem)
            timeRemainingLabel!.text = remTime
            
            let deltaExp = toInt(rem: audioPlayer.currentTime)
            let expTime = timerUtil.getFormattedTime(seconds: deltaExp)
            timeExpiredLabel!.text = expTime
            
            let progress = timerUtil.getTimeAsFloat(expired: audioPlayer.currentTime)
            slider.setValue(progress, animated: false)
        }
    }

    
    private func getIndexForPage() -> Int {
        return currentIndex
    }

    private func playSong(_ index: Int) {
        if let url = Bundle.main.url(forResource: SongDescriptor.getSongAtIndex(index: index), withExtension: "mp3") {
            do {
                timeRemainingLabel!.isHidden = false
                timeExpiredLabel!.isHidden = false
                timeRemainingLabel!.text = songLength[index] as? String
                timeExpiredLabel!.text = "00:00"
                
                let sound = try AVAudioPlayer(contentsOf: url)
                audioPlayer = sound
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                timerUtil.duration = audioPlayer.duration
                audioPlayer.play()
                displayLink = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
                displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                if audioPlayer.isPlaying {
                    isPaused = false
                    playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
                }
                nowPlayingLabel.text = SongDescriptor.titles[index]
                nowPlayingLabel.isHidden = false
            } catch {
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    func openPage(action: UIAlertAction!, urlString: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if urlString.isEmpty {
            let gvc = storyboard.instantiateViewController(withIdentifier: "imageViewController") as? CarouselViewController
            self.present(gvc!, animated: true, completion: nil)
        } else if urlString == CONTACT_CORSAGE {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                switch UIDevice.current.userInterfaceIdiom {
                case .pad:
                    mailComposeViewController.modalPresentationStyle = .pageSheet
                default: break
                    // do nothing
                }
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        } else {
            let wvc = storyboard.instantiateViewController(withIdentifier: "webViewController") as! WebViewController
            wvc.urlString = urlString
            self.present(wvc, animated: true, completion: nil)
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["smithcorsage@hotmail.com"])
        mailComposerVC.setSubject("Contact Corsage")
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func runContactViewController() {
        let mvc = storyboard!.instantiateViewController(withIdentifier: "contactViewController")
        mvc.view.frame.size = CGSize(width: self.view.frame.width - (self.view.frame.width/6), height: self.view.frame.height/2)
        mvc.view.frame.insetBy(dx: 1.0, dy: 30.0)
        self.present(mvc, animated: true, completion: nil)
    }
    
    func displayUrlActionSheet(sender: AnyObject) {
        
        let moreAlert = UIAlertController(title: "More Information", message: "" , preferredStyle: UIAlertControllerStyle.actionSheet)
        
        if let popoverController = moreAlert.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
        } else {
            moreAlert.modalPresentationStyle = .overFullScreen
        }
        
        let linksDescriptor = UrlLinksDescriptor()
        for index in 0..<linksDescriptor.getNumberOfLinks() {
            moreAlert.addAction(UIAlertAction(title: linksDescriptor.getTitleForIndex(index: index), style: .default) {
                (action: UIAlertAction) -> Void in
                self.openPage(action: action, urlString: linksDescriptor.getUrlForIndex(index: index))
            })
        }
        
        moreAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel) {
            (action: UIAlertAction) -> Void in
            // do nothing
        })
        present(moreAlert, animated: true, completion: nil)
    }
    // MARK: - Callbacks
    // Display the credits in an action sheet
}

extension CGRect {
    
    static func make(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

