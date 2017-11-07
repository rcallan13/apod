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
class MasterViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, MFMailComposeViewControllerDelegate, AVAudioPlayerDelegate {
    
    let NUMBER_OF_SONGS = 5
    let BUTTON_SIZE: CGFloat = 38
    let MARGIN: CGFloat = 16
    let inc = 2.0
    
    let songLength = ["05:18", "04:09", "05:33", "02:34", "02:01"]
    let pageImages = ["arm_image_white", "leg_image_white", "head_image_white", "top_half_white", "full_body_white2"]
    
    var audioPlayer: AVAudioPlayer!
    var timerUtil: TimerUtil!
    
    var playbackView: UIView?
    var timeRemainingLabel: UILabel?
    var timeExpiredLabel: UILabel?
    var nowPlayingLabel: UILabel?
    var slider: UISlider?
   
    var playButton: UIButton?
    var stopButton: UIButton?
    var lyricsButton: UIButton?
    var moreButton: UIButton?
    
    var currentSong = 0
    var currentPage = 0
    
    var lastVal: Float = 0
    var displayLink: CADisplayLink!
    
    
    var lyricsView: LyricsView?
    
    var imageView: UIImageView?
    var pageViewController: UIPageViewController?
    
    var playbackViewRect: CGRect?
    var w: CGFloat?
    
    var isPaused = false
    var isAutoPlay: Bool = false
    var lyricsViewShowing: Bool = false
    
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
        self.pageViewController?.delegate = self
        
        let startVC = self.viewControllerAtIndex(index: 0) as SongContentViewController
        let viewControllers = NSArray(object: startVC)
        
        self.pageViewController?.setViewControllers(viewControllers as? [UIViewController], direction: .forward, animated: true, completion: nil)
        
        timerUtil = TimerUtil()
    }
    
    override func viewWillLayoutSubviews() {
        
        removeFromPlayback()
        
        if self.view.frame.width > self.view.frame.height {
            layoutPlaybackLandscape()
        } else {
            layoutPlaybackPortrait()
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
        if audioPlayer != nil && (audioPlayer.isPlaying || isPaused) {
            timeExpiredLabel?.isHidden = false
            timeRemainingLabel?.isHidden = false
            nowPlayingLabel?.text = "\((currentSong + 1)). " + SongDescriptor.titles[currentSong]
            nowPlayingLabel?.isHidden = false
        }
        
        if lyricsViewShowing {
            onDismissLyrics(self)
            showLyrics()
        }
    }
    
    @objc func onMore(_ sender: UIButton) {
        displayUrlActionSheet(sender: sender)
    }
    
    @objc func onLyrics(_ sender: Any) {
        if lyricsViewShowing {
            onDismissLyrics(sender as AnyObject)
            return
        }
        showLyrics()
    }
    
    private func showLyrics() {
        let rect = (pageViewController?.view.frame)!
        var width = rect.width
        
        lyricsView = LyricsView(frame: CGRect.make(MARGIN/2, rect.origin.y, width - MARGIN, rect.height - BUTTON_SIZE))
        lyricsView?.songIndex = currentPage
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
        lyricsView?.isHidden = false
        var transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        if self.view.frame.width > self.view.frame.height {
            transform = CGAffineTransform(translationX: (lyricsView?.frame.width)!, y: 0)
        }
        lyricsView?.transform = transform
        lyricsView?.isHidden = false
        self.pageViewController?.view.bringSubview(toFront: self.lyricsView!)
        transform = CGAffineTransform(translationX: 0, y: 0)
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView?.transform = transform
        }, completion: {(finished: Bool) in
            
        })
        lyricsViewShowing = true
    }
    
    @objc func onDismissLyrics(_ sender: AnyObject) {
        guard let _ = lyricsView else {
            return
        }
       
        var transform = CGAffineTransform(translationX: -1 * (lyricsView?.frame.width)!, y: 0)
        if self.view.frame.width > self.view.frame.height {
            transform = CGAffineTransform(translationX: (lyricsView?.frame.width)!, y: 0)
        }
        UIView.animate(withDuration: 0.3, animations: {
            self.lyricsView?.transform = transform
        }, completion: {(finished: Bool) in
            self.lyricsView?.removeFromSuperview()
            self.lyricsView = nil
            self.lyricsViewShowing = false
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
        
        // If we are playing a song, then match it with the page
        currentSong = currentPage
        playSong()
    }
    
    private func playSong() {
        
        if let url = Bundle.main.url(forResource: SongDescriptor.getSongAtIndex(index: currentSong), withExtension: "mp3") {
            do {
                timeRemainingLabel!.isHidden = false
                timeExpiredLabel!.isHidden = false
                timeRemainingLabel!.text = songLength[currentSong]
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
             
                nowPlayingLabel?.text = "\((currentSong + 1)). " + SongDescriptor.titles[currentSong]
                nowPlayingLabel?.isHidden = false
                
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
        let val = sender.value
        if audioPlayer != nil && audioPlayer.isPlaying {
            let delta = lastVal - val
            if delta > 0.0 {
                audioPlayer.currentTime -= inc
            } else {
                audioPlayer.currentTime += inc
            }
            lastVal = val
            updateSliderProgress()
        }
    }
    
    // stop the playback
    @objc func onStop(_ sender: AnyObject) {
        if audioPlayer != nil {
            audioPlayer.currentTime = 0
            audioPlayer.stop()
            slider?.value = 0
            songProgressChanged(sender: slider!)
            timeRemainingLabel?.isHidden = true
            timeExpiredLabel?.isHidden = true
            nowPlayingLabel?.isHidden = true
            isPaused = false
            playButton?.setImage(UIImage(named: "play.png"), for: .normal)
        }
    }
    
    @objc func updateSliderProgress() {
        if timerUtil != nil && audioPlayer != nil {
            let deltaRem = toInt(rem: timerUtil.duration - audioPlayer.currentTime)
            let remTime = timerUtil.getFormattedTime(seconds: deltaRem)
            timeRemainingLabel?.text = remTime
            
            let deltaExp = toInt(rem: audioPlayer.currentTime)
            let expTime = timerUtil.getFormattedTime(seconds: deltaExp)
            timeExpiredLabel!.text = expTime
            
            let progress = timerUtil.getTimeAsFloat(expired: audioPlayer.currentTime)
            slider?.setValue(progress, animated: false)
        }
    }
    
    func playNextSong() {
        if currentSong < (NUMBER_OF_SONGS - 1) {
            currentSong = currentSong + 1;
            isAutoPlay = true
            playSong()
        } else {
            // Played them all so we'll stop
            currentSong = 0
            isAutoPlay = false
        }
    }
    
    func viewControllerAtIndex(index: Int) -> SongContentViewController {
        if let vc: SongContentViewController = self.storyboard?.instantiateViewController(withIdentifier: "ContentViewController") as? SongContentViewController {
            NSLog("viewControllerAtIndex(\(index))")
            vc.pageImage = pageImages[index]
            vc.pageTitle = SongDescriptor.titles[index]
            vc.pageIndex = index
            return vc
        }
        return SongContentViewController()
    }
    
    // MARK: - Page View Controller Data Source
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentViewController = pageViewController.viewControllers![0] as? SongContentViewController {
                currentPage = currentViewController.pageIndex
                NSLog("---- didFinishAnimating(\(currentPage)) ----")
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SongContentViewController
        var index = vc.pageIndex as Int
        if (index == 0 || index == NSNotFound) {
            return nil
        }
        index = index - 1
        NSLog("viewControllerBefore(\(index))")
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        let vc = viewController as! SongContentViewController
        var index = vc.pageIndex as Int
        if (index == NSNotFound) {
            return nil
        }
        index = index + 1
        if (index == SongDescriptor.titles.count) {
            return nil
        }
        NSLog("viewControllerAfter(\(index))")
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return SongDescriptor.titles.count
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
        let delta = Int(rem)
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
    
    private func layoutPlaybackPortrait() {
        
        w = 2 * self.view.frame.width/3
        imageView = UIImageView(frame: CGRect.make(MARGIN, 2 * MARGIN, w!, w!/3))
        self.pageViewController?.view.frame = CGRect.make(0, 30, self.view.frame.width, self.view.frame.size.height - 140)
        
        playbackView = UIView(frame: CGRect.make(0, 3 * self.view.frame.height/4, self.view.frame.width, self.view.frame.height/4))
        layoutPlayback()
    }
    
    private func layoutPlaybackLandscape() {
        w = 2 * self.view.frame.height/3
        imageView = UIImageView(frame: CGRect.make(MARGIN, MARGIN, w!, w!/3))
        self.pageViewController?.view.frame = CGRect.make(self.view.frame.width/2, MARGIN, self.view.frame.width/2, self.view.frame.size.height)
        playbackView = UIView(frame: CGRect.make(0, 2 * MARGIN + w!/3, self.view.frame.width/2, self.view.frame.height - (2 * MARGIN + w!/3)))
        layoutPlayback()
    }
    
    private func layoutPlayback() {
        self.lyricsView?.removeFromSuperview()
        self.lyricsView = nil
        
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
        
        let isPlaying = audioPlayer != nil && audioPlayer.isPlaying
        var image = UIImage(named: "play.png")
        if isPlaying {
            image = UIImage(named: "pause.png")
        }
        
        let isShowing = audioPlayer != nil && (audioPlayer.isPlaying || isPaused)
        playButton?.setImage(image, for: .normal)
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
        
        if isShowing {
            timeRemainingLabel?.isHidden = false
        } else {
            timeRemainingLabel?.isHidden = true
        }
        playbackView?.addSubview(timeRemainingLabel!)
        
        timeExpiredLabel = UILabel(frame: CGRect.make(sliderX + (slider?.frame.width)! + MARGIN/2, sliderY  + MARGIN, sliderX - MARGIN/2, (slider?.frame.height)!))
        timeExpiredLabel?.textAlignment = NSTextAlignment.left
        timeExpiredLabel?.font = UIFont(name: "Arial", size: 11)
        timeExpiredLabel?.textColor = UIColor.white
        if isShowing {
            timeExpiredLabel?.isHidden = false
        } else {
            timeExpiredLabel?.isHidden = true
        }
        
        playbackView?.addSubview(timeExpiredLabel!)
        
        nowPlayingLabel = UILabel(frame: CGRect.make(MARGIN, (slider?.frame.origin.y)! - 2 * MARGIN, (playbackView?.frame.width)! - 2 * MARGIN, MARGIN))
        nowPlayingLabel?.textColor = UIColor.lightGray
        nowPlayingLabel?.font = UIFont(name: "Chalkduster", size: 12)
        playbackView?.addSubview(nowPlayingLabel!)
        nowPlayingLabel?.textAlignment = .left
        if isShowing {
            nowPlayingLabel?.isHidden = false
        } else {
            nowPlayingLabel?.isHidden = true
        }
    }
}

extension CGRect {
    
    static func make(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
}

