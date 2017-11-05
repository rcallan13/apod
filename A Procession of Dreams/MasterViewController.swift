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
class MasterViewController: UIViewController, UIPageViewControllerDataSource, MFMailComposeViewControllerDelegate, AVAudioPlayerDelegate {
    
    class State {
        var isPlaying: Bool = false
        var isLyricsShowing: Bool = false
        var isAutoPlay: Bool = false
        var isPaused: Bool = false
        var lyricsViewShowing: Bool = false
        var currentSong: Int = 0
        var currentIndex: Int = 0
        var lastVal: Float = 0
    }
    
    static var STATE = State()
    static var pageImages = ["arm_image_white", "leg_image_white", "head_image_white", "top_half_white", "full_body_white2"]
    
    static var songLength = ["05:18", "04:09", "05:33", "02:34", "02:01"]
    
    let BUTTON_SIZE: CGFloat = 38
    let MARGIN: CGFloat = 16
    let inc = 2.0
    
    var audioPlayer: AVAudioPlayer!
    var playbackView: UIView?
    var timeRemainingLabel: UILabel?
    var timeExpiredLabel: UILabel?
    var nowPlayingLabel: UILabel?
    var slider: UISlider?
    var playButton: UIButton?
    var stopButton: UIButton?
    
    var lyricsButton: UIButton?
    var moreButton: UIButton?
    var currentPlaying: Int = 0

    var displayLink: CADisplayLink?
    var timerUtil: TimerUtil?
    
    var lyricsView: LyricsView?
    var imageView: UIImageView?
    var pageViewController: UIPageViewController?
    
    var playbackViewRect: CGRect?
    var w: CGFloat?
    
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
        
        self.pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        self.pageViewController?.dataSource = self
        
        let startVC = self.viewControllerAtIndex(index: 0) as SongContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController?.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        MasterViewController.STATE.currentIndex = 0
        timerUtil = TimerUtil()
        
    }
    
    override func viewWillLayoutSubviews() {
        
        removeFromPlayback()
        lyricsView?.removeFromSuperview()
        
        if self.view.frame.width > self.view.frame.height {
            layoutPlaybackLandscape()
        } else {
            layoutPlayback()
        }
        
        let image = UIImage(named: "corsage_title_on_white.png")
        imageView?.image = image
        imageView?.contentMode = .scaleAspectFit
        self.view.addSubview(imageView!)
        self.view.sendSubview(toBack: imageView!)
        self.addChildViewController(self.pageViewController!)
        self.view.addSubview((self.pageViewController?.view)!)
        self.pageViewController?.didMove(toParentViewController: self)
        self.view.addSubview(playbackView!)
        if let _ = audioPlayer {
            if audioPlayer.isPlaying {
                timeExpiredLabel?.isHidden = false
                timeRemainingLabel?.isHidden = false
                nowPlayingLabel?.text = "\((currentPlaying + 1)). " + SongDescriptor.titles[currentPlaying]
                nowPlayingLabel?.isHidden = false
            }
        }
        
        if MasterViewController.STATE.lyricsViewShowing {
            onLyrics(self)
        }
    }
    
    @objc func onMore(_ sender: UIButton) {
        displayUrlActionSheet(sender: sender)
    }
    
    @objc func onLyrics(_ sender: Any) {
        /*
        if lyricsViewShowing {
            onDismissLyrics(sender as AnyObject)
            return
        }
 */
        onDismissLyrics(sender as AnyObject)
        let rect = (pageViewController?.view.frame)!
        var width = rect.width
        
        lyricsView = LyricsView(frame: CGRect.make(rect.origin.x, rect.origin.y, width, rect.height - BUTTON_SIZE))
        lyricsView?.isHidden = true
        lyricsView?.songIndex = MasterViewController.STATE.currentIndex
        lyricsView?.backgroundColor = UIColor.black
        let dismiss = UIButton(frame: CGRect.make(((lyricsView?.frame.width)!) - 2 * BUTTON_SIZE, 0, 2 * BUTTON_SIZE, BUTTON_SIZE))
        dismiss.setTitle("Dismiss", for: .normal)
        dismiss.setTitleColor(UIColor.white, for: .normal)
        dismiss.titleLabel?.font = UIFont(name: "Chalkduster", size: 14)
        dismiss.addTarget(self, action: #selector(onDismissLyrics(_:)), for: .touchUpInside)
        lyricsView?.addSubview(dismiss)
        pageViewController?.view.addSubview(lyricsView!)
        
        width = self.view.frame.width - 2 * MARGIN
        if self.view.frame.width > self.view.frame.height {
            width = width/2
        }
        lyricsView?.contentSize = CGSize(width: width, height: (lyricsView?.lyricsLabel?.intrinsicContentSize.height)! + 100)
        
        var transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        lyricsView?.transform = transform
        lyricsView?.isHidden = false
        self.pageViewController?.view.bringSubview(toFront: self.lyricsView!)
        
        if self.view.frame.height > self.view.frame.width {
            transform = CGAffineTransform(translationX: 0, y: 0)
            UIView.animate(withDuration: 0.3, animations: {
                self.lyricsView?.transform = transform
            }, completion: {(finished: Bool) in
                
            })
        }
        MasterViewController.STATE.lyricsViewShowing = true
    }
    
    @objc func onDismissLyrics(_ sender: AnyObject) {
        guard let _ = lyricsView else {
            return
        }
        let transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView?.transform = transform
        }, completion: {(finished: Bool) in
            self.lyricsView?.removeFromSuperview()
            self.lyricsView = nil
            MasterViewController.STATE.lyricsViewShowing = false
        })
    }
    
    @objc func onPlay(_ sender: AnyObject) {
        
        if audioPlayer != nil {
            if audioPlayer.isPlaying {
                audioPlayer.pause()
                MasterViewController.STATE.isPaused = true
                playButton?.setImage(UIImage(named: "play.png"), for: .normal)
                return
            }
            
            if  MasterViewController.STATE.isPaused {
                audioPlayer.play()
                displayLink = CADisplayLink(target: self, selector: #selector(self.updateSliderProgress))
                displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                if audioPlayer.isPlaying {
                    MasterViewController.STATE.isPaused = false
                    playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
                }
                return
            }
        }
        // finally, play the song
        playSong(MasterViewController.STATE.currentSong)
    }
    
    private func playSong(_ index: Int) {
        if let url = Bundle.main.url(forResource: SongDescriptor.getSongAtIndex(index: index), withExtension: "mp3") {
            do {
                timeRemainingLabel!.isHidden = false
                timeExpiredLabel!.isHidden = false
                timeRemainingLabel!.text = MasterViewController.songLength[index]
                timeExpiredLabel!.text = "00:00"
                
                let sound = try AVAudioPlayer(contentsOf: url)
                audioPlayer = sound
                audioPlayer.prepareToPlay()
                audioPlayer.delegate = self
                timerUtil?.duration = audioPlayer.duration
                audioPlayer.play()
                displayLink = CADisplayLink(target: self, selector: #selector(updateSliderProgress))
                displayLink?.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
                if audioPlayer.isPlaying {
                    MasterViewController.STATE.isPaused = false
                    playButton?.setImage(UIImage(named: "pause.png"), for: .normal)
                }
            
                nowPlayingLabel?.text = "\((index + 1)). " + SongDescriptor.titles[index]
                nowPlayingLabel?.isHidden = false
                currentPlaying = index
            } catch {
            }
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if flag {
            playNextSong()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }
    
    @objc func songProgressChanged(sender: UISlider) {
        guard let _ = audioPlayer else {
            return
        }
        let val = sender.value
        if audioPlayer.isPlaying {
            let delta = MasterViewController.STATE.lastVal - val
            if delta > 0.0 {
                audioPlayer.currentTime -= inc
            } else {
                audioPlayer.currentTime += inc
            }
            MasterViewController.STATE.lastVal = val
            updateSliderProgress()
        }
    }
    
    // stop the playback
    @objc func onStop(_ sender: AnyObject) {
        guard let _ = audioPlayer else {
            return
        }
        
        audioPlayer.currentTime = 0
        audioPlayer.stop()
        slider?.value = 0
        songProgressChanged(sender: slider!)
        timeRemainingLabel?.isHidden = true
        timeExpiredLabel?.isHidden = true
        nowPlayingLabel?.isHidden = true
        MasterViewController.STATE.isPaused = false
        playButton?.setImage(UIImage(named: "play.png"), for: .normal)
    }
    
    @objc func updateSliderProgress() {
        if timerUtil != nil && audioPlayer != nil {
            let deltaRem = Int((timerUtil?.duration)! - audioPlayer.currentTime)
            let remTime = timerUtil?.getFormattedTime(seconds: deltaRem)
            timeRemainingLabel?.text = remTime
            
            let deltaExp = Int(audioPlayer.currentTime)
            let expTime = timerUtil?.getFormattedTime(seconds: deltaExp)
            timeExpiredLabel!.text = expTime
            
            let progress = timerUtil?.getTimeAsFloat(expired: audioPlayer.currentTime)
            slider?.setValue(progress!, animated: false)
        }
    }
    
    func playNextSong() {
        if MasterViewController.STATE.currentSong < (SongDescriptor.getNumSongs() - 1) {
            MasterViewController.STATE.currentSong = MasterViewController.STATE.currentSong + 1;
            MasterViewController.STATE.isAutoPlay = true
            playSong(MasterViewController.STATE.currentSong)
        } else {
            MasterViewController.STATE.currentSong = 0
            MasterViewController.STATE.isAutoPlay = false
        }
    }
    
    func viewControllerAtIndex(index: Int) -> SongContentViewController {
        if let vc: SongContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as? SongContentViewController {
            vc.pageImage = MasterViewController.pageImages[index]
            vc.pageTitle = SongDescriptor.titles[index]
            vc.pageIndex = index
            return vc
        }
        return SongContentViewController()
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SongContentViewController
        var index = vc.pageIndex as Int
        MasterViewController.STATE.currentIndex = index
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        index = index - 1
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SongContentViewController
        var index = vc.pageIndex as Int
        MasterViewController.STATE.currentIndex = index
        if (index == NSNotFound) {
            return nil
        }
        index = index + 1
        
        if (index == SongDescriptor.titles.count) {
            return nil
        }
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return SongDescriptor.titles.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return MasterViewController.STATE.currentIndex
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
    func displayCredits(sender: AnyObject) {
        displayUrlActionSheet(sender: sender)
    }
    
    private func toInt(rem: Double) -> Int {
        let delta:Int = Int(rem)
        return delta
    }
    
    private func removeFromPlayback() {
        imageView?.removeFromSuperview()
        pageViewController?.removeFromParentViewController()
        playbackView?.removeFromSuperview()
        slider?.removeFromSuperview()
        playButton?.removeFromSuperview()
        moreButton?.removeFromSuperview()
        lyricsButton?.removeFromSuperview()
        stopButton?.removeFromSuperview()
    }
    
    private func layoutPlaybackLandscape() {
        
        w = 2 * self.view.frame.height/3
        imageView = UIImageView(frame: CGRect.make(MARGIN, MARGIN, w!, w!/3))
        self.pageViewController?.view.frame = CGRect.make(self.view.frame.width/2, MARGIN, self.view.frame.width/2, self.view.frame.size.height)
        playbackView = UIView(frame: CGRect.make(0, 2 * MARGIN + w!/3, self.view.frame.width/2, self.view.frame.height - (2 * MARGIN + w!/3)))
        
        let offset = 3 * MARGIN/2
        let playButtonY = (playbackView?.frame.height)! - offset - BUTTON_SIZE
        let sliderYMargin = (playbackView?.frame.width)!/6
        
        slider = UISlider(frame: CGRect.make(sliderYMargin, playButtonY - BUTTON_SIZE, (playbackView?.frame.width)! - 2 * sliderYMargin, BUTTON_SIZE))
        
        slider?.addTarget(self, action: #selector(MasterViewController.songProgressChanged(sender:)), for: .valueChanged)
        slider?.minimumValue = 0
        slider?.maximumValue = 100
        slider?.minimumTrackTintColor = UIColor.darkGray
        let thumbImage = UIImage(named: "thumb_image.png")
        slider?.setThumbImage(thumbImage, for: .normal)
        playbackView?.addSubview(slider!)
        playbackViewRect = playbackView?.bounds
        
        playButton = UIButton(frame: CGRect.make((slider?.frame.midX)! + MARGIN, playButtonY, BUTTON_SIZE, BUTTON_SIZE))

        let image = UIImage(named: "play.png")
        playButton?.setBackgroundImage(image, for: .normal)
        playButton?.addTarget(self, action: #selector(onPlay(_:)), for: .touchUpInside)
        playbackView?.addSubview(playButton!)
        
        let x = (playButton?.frame.origin.x)! + BUTTON_SIZE
        moreButton = UIButton(frame: CGRect.make(x, (playbackView?.frame.height)! - 32, (playbackView?.frame.width)! - x, 24))
        moreButton?.setTitle("More...", for: .normal)
        moreButton?.titleLabel?.font = UIFont(name: "Chalkduster", size: 18)!
        moreButton?.titleLabel?.textColor = UIColor.white
        moreButton?.titleLabel?.textAlignment = .left
        moreButton?.addTarget(self, action: #selector(onMore(_:)), for: .touchUpInside)
        playbackView?.addSubview(moreButton!)
        
        stopButton = UIButton(frame: CGRect.make((slider?.frame.midX)! - MARGIN - BUTTON_SIZE, (playbackView?.frame.height)! - offset - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE))
        let stopImage = UIImage(named: "stop.png")
        stopButton?.setBackgroundImage(stopImage, for: .normal)
        stopButton?.addTarget(self, action: #selector(onStop(_:)), for: .touchUpInside)
        playbackView?.addSubview(stopButton!)
        
        lyricsButton = UIButton(frame: CGRect.make(0, (playbackView?.frame.height)! - 32, (stopButton?.frame.origin.x)!, 24))
        lyricsButton?.setTitle("Lyrics", for: .normal)
        lyricsButton?.titleLabel?.font = UIFont(name: "Chalkduster", size: 18)!
        lyricsButton?.titleLabel?.textColor = UIColor.white
        lyricsButton?.titleLabel?.textAlignment = .left
        lyricsButton?.addTarget(self, action: #selector(onLyrics(_:)), for: .touchUpInside)
        playbackView?.addSubview(lyricsButton!)
        
        let sliderX = (slider?.frame.origin.x)!
        let sliderY = (slider?.frame.origin.y)! - MARGIN
        timeRemainingLabel = UILabel(frame: CGRect.make(0, sliderY + MARGIN, sliderX - MARGIN/2, (slider?.frame.height)!))
        timeRemainingLabel?.textAlignment = NSTextAlignment.right
        timeRemainingLabel?.font = UIFont(name: "Arial", size: 11)
        timeRemainingLabel?.textColor = UIColor.white
        timeRemainingLabel?.isHidden = true
        playbackView?.addSubview(timeRemainingLabel!)
        
        timeExpiredLabel = UILabel(frame: CGRect.make(sliderX + (slider?.frame.width)! + MARGIN/2, sliderY  + MARGIN, sliderX - MARGIN/2, (slider?.frame.height)!))
        timeExpiredLabel?.textAlignment = NSTextAlignment.left
        timeExpiredLabel?.font = UIFont(name: "Arial", size: 11)
        timeExpiredLabel?.textColor = UIColor.white
        timeExpiredLabel?.isHidden = true
        playbackView?.addSubview(timeExpiredLabel!)
        
        nowPlayingLabel = UILabel(frame: CGRect.make(MARGIN, (slider?.frame.origin.y)! - 2 * MARGIN, (playbackView?.frame.width)! - 2 * MARGIN, MARGIN))
        nowPlayingLabel?.textColor = UIColor.lightGray
        nowPlayingLabel?.font = UIFont(name: "Chalkduster", size: 12)
        playbackView?.addSubview(nowPlayingLabel!)
        nowPlayingLabel?.textAlignment = .left
        nowPlayingLabel?.isHidden = true
    }
    
    private func layoutPlayback() {
        
        w = 2 * self.view.frame.width/3
        imageView = UIImageView(frame: CGRect.make(MARGIN, 2 * MARGIN, w!, w!/3))
        self.pageViewController?.view.frame = CGRect.make(0, 30, self.view.frame.width, self.view.frame.size.height - 140)
        
        playbackView = UIView(frame: CGRect.make(0, 3 * self.view.frame.height/4, self.view.frame.width, self.view.frame.height/4))
        
        slider = UISlider(frame: CGRect.make((playbackView?.frame.width)!/6, (playbackView?.frame.height)!/4, 2 * (playbackView?.frame.width)!/3, BUTTON_SIZE))
        
        slider?.addTarget(self, action: #selector(MasterViewController.songProgressChanged(sender:)), for: .valueChanged)
        slider?.minimumValue = 0
        slider?.maximumValue = 100
        slider?.minimumTrackTintColor = UIColor.darkGray
        let thumbImage = UIImage(named: "thumb_image.png")
        slider?.setThumbImage(thumbImage, for: .normal)
        playbackView?.addSubview(slider!)
        playbackViewRect = playbackView?.bounds
        
        let offset = 3 * MARGIN/2
        playButton = UIButton(frame: CGRect.make((slider?.frame.midX)! + MARGIN, (playbackView?.frame.height)! - offset - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE))
        
        let image = UIImage(named: "play.png")
        playButton?.setBackgroundImage(image, for: .normal)
        playButton?.addTarget(self, action: #selector(onPlay(_:)), for: .touchUpInside)
        playbackView?.addSubview(playButton!)
        
        let x = (playButton?.frame.origin.x)! + BUTTON_SIZE
        moreButton = UIButton(frame: CGRect.make(x, (playbackView?.frame.height)! - 32, (playbackView?.frame.width)! - x, 24))
        moreButton?.setTitle("More...", for: .normal)
        moreButton?.titleLabel?.font = UIFont(name: "Chalkduster", size: 18)!
        moreButton?.titleLabel?.textColor = UIColor.white
        moreButton?.titleLabel?.textAlignment = .left
        moreButton?.addTarget(self, action: #selector(onMore(_:)), for: .touchUpInside)
        playbackView?.addSubview(moreButton!)
        
        stopButton = UIButton(frame: CGRect.make((slider?.frame.midX)! - MARGIN - BUTTON_SIZE, (playbackView?.frame.height)! - offset - BUTTON_SIZE, BUTTON_SIZE, BUTTON_SIZE))
        let stopImage = UIImage(named: "stop.png")
        stopButton?.setBackgroundImage(stopImage, for: .normal)
        stopButton?.addTarget(self, action: #selector(onStop(_:)), for: .touchUpInside)
        playbackView?.addSubview(stopButton!)
        
        lyricsButton = UIButton(frame: CGRect.make(0, (playbackView?.frame.height)! - 32, (stopButton?.frame.origin.x)!, 24))
        lyricsButton?.setTitle("Lyrics", for: .normal)
        lyricsButton?.titleLabel?.font = UIFont(name: "Chalkduster", size: 18)!
        lyricsButton?.titleLabel?.textColor = UIColor.white
        lyricsButton?.titleLabel?.textAlignment = .left
        lyricsButton?.addTarget(self, action: #selector(onLyrics(_:)), for: .touchUpInside)
        playbackView?.addSubview(lyricsButton!)
        
        let sliderX = (slider?.frame.origin.x)!
        let sliderY = (slider?.frame.origin.y)! - MARGIN
        timeRemainingLabel = UILabel(frame: CGRect.make(0, sliderY + MARGIN, sliderX - MARGIN/2, (slider?.frame.height)!))
        timeRemainingLabel?.textAlignment = NSTextAlignment.right
        timeRemainingLabel?.font = UIFont(name: "Arial", size: 11)
        timeRemainingLabel?.textColor = UIColor.white
        timeRemainingLabel?.isHidden = true
        playbackView?.addSubview(timeRemainingLabel!)
        
        timeExpiredLabel = UILabel(frame: CGRect.make(sliderX + (slider?.frame.width)! + MARGIN/2, sliderY  + MARGIN, sliderX - MARGIN/2, (slider?.frame.height)!))
        timeExpiredLabel?.textAlignment = NSTextAlignment.left
        timeExpiredLabel?.font = UIFont(name: "Arial", size: 11)
        timeExpiredLabel?.textColor = UIColor.white
        timeExpiredLabel?.isHidden = true
        playbackView?.addSubview(timeExpiredLabel!)
        
        nowPlayingLabel = UILabel(frame: CGRect.make(MARGIN, 0, (playbackView?.frame.width)! - 2 * MARGIN, MARGIN))
        nowPlayingLabel?.textColor = UIColor.lightGray
        nowPlayingLabel?.font = UIFont(name: "Chalkduster", size: 12)
        playbackView?.addSubview(nowPlayingLabel!)
        nowPlayingLabel?.textAlignment = .left
        nowPlayingLabel?.isHidden = true
    }
}

extension CGRect {
    
    static func make(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

