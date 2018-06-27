//
//  ViewController.swift
//  VideoPlayer_Alan
//
//  Created by ChenAlan on 2018/4/27.
//  Copyright © 2018年 ChenAlan. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class PlayerViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var searchButtonStyle: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    
    @IBAction func setupPlayer(_ sender: UIButton) {
        guard let urlString = textField.text else {
            return
        }
        // AVPlayer
        
        let videoURL = URL(string: urlString)
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        placeHolderLabel.isHidden = true

        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000.0))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { time in
            let progress = CMTimeGetSeconds(self.player.currentTime()) / CMTimeGetSeconds(self.player.currentItem!.duration)
            self.slider.setValue(Float(progress), animated: false)
            // Time Format
            let currentTime = CMTimeGetSeconds(self.player.currentTime())
            let currentMin = String(format: "%.0f", currentTime)
            let currentMinute = Int(currentMin)! / 60
            let currentSec = String(format: "%.0f",  currentTime)
            let currentSecond = Int(currentSec)! % 60
            let total = String(format: "%.0f",  CMTimeGetSeconds(self.player.currentItem!.duration))
            let totalMin = Int(total)! / 60
            let totalSec = Int(total)! % 60
            let totalMinute = totalMin < 10 ? "0\(totalMin)" : "\(totalMin)"
            let totalSecond = totalSec < 10 ? "0\(totalSec)" : "\(totalSec)"
            self.totalDurationLabel.text = totalMinute + ":" + totalSecond
            let minute = currentMinute < 10 ? "0\(currentMinute)" : "\(currentMinute)"
            let second = currentSecond < 10 ? "0\(currentSecond)" : "\(currentSecond)"
            self.currentTimeLabel.text = minute + ":" + second
        }
    }
    
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBAction func fullScreen(_ sender: UIButton) {
        if fullScreenButton.isSelected {
            fullScreenButton.isSelected = false
            let value = UIInterfaceOrientation.portrait.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
        } else {
            playerLayer.goFullscreen()
            let value = UIInterfaceOrientation.landscapeRight.rawValue
            UIDevice.current.setValue(value, forKey: "orientation")
            fullScreenButton.isSelected = true
        }
    }
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    
    @IBAction func playOrPause(_ sender: UIButton) {
        if player.rate > 0.0 {
            player.pause()
            playButton.isSelected = false
        } else {
            player.play()
            playButton.isSelected = true
        }
    }
    let duration = CMTime(seconds: 10.0, preferredTimescale: CMTimeScale(1.0))
    @IBAction func fastForward(_ sender: UIButton) {
        let time = player.currentTime() + duration
        player.seek(to: time)
    }
    @IBAction func fastBackward(_ sender: UIButton) {
        let time = player.currentTime() - duration
        player.seek(to: time)
    }
    @IBAction func mute(_ sender: UIButton) {
        if player.isMuted {
            player.isMuted = false
            muteButton.isSelected = false
        } else {
            player.isMuted = true
            muteButton.isSelected = true
        }
    }
    
    @IBAction func updateTime(_ sender: UISlider) {
        if let duration = player.currentItem?.duration {
            let total = CMTimeGetSeconds(duration)
            let val = Float64(sender.value) * total
            let time = CMTime(value: Int64(val), timescale: 1)
            player.seek(to: time)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Component
        navigationBar.isTranslucent = false
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = navigationBar.barTintColor
        view.addSubview(statusBarView)
        searchButtonStyle.layer.borderColor = UIColor.lightGray.cgColor
        searchButtonStyle.layer.borderWidth = 1.0
        searchButtonStyle.layer.cornerRadius = 4.0
        slider.minimumTrackTintColor = UIColor.purple
        slider.value = 0.0
        playButton.tintColor = .black
        muteButton.tintColor = .black
        backwardButton.tintColor = .black
        forwardButton.tintColor = .black
        fullScreenButton.tintColor = .black
//        placeHolderLabel.textColor = .black
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            print("landscape")
            videoView.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
            videoView.backgroundColor = .black
            playerLayer.frame = CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.height, height: UIScreen.main.bounds.width)
//            videoView.layer.addSublayer(playerLayer)
            playButton.tintColor = .white
            muteButton.tintColor = .white
            backwardButton.tintColor = .white
            forwardButton.tintColor = .white
            fullScreenButton.tintColor = .white
            currentTimeLabel.textColor = .white
            totalDurationLabel.textColor = .white
            fullScreenButton.isSelected = true
        } else {
            print("portarit")
            playButton.tintColor = .black
            muteButton.tintColor = .black
            backwardButton.tintColor = .black
            forwardButton.tintColor = .black
            fullScreenButton.tintColor = .black
            currentTimeLabel.textColor = .black
            totalDurationLabel.textColor = .black
            videoView.backgroundColor = .white
            fullScreenButton.isSelected = false
        }
    }
}

extension AVPlayerLayer {
    func goFullscreen() {
        UIView.animate(withDuration: 0.15) {
//            self.setAffineTransform(CGAffineTransform(rotationAngle: 90.0))
           
            self.frame = UIScreen.main.bounds
//            self.videoGravity = AVLayerVideoGravity(rawValue: kCAGravityResizeAspectFill)
            self.setNeedsDisplay()
        }
    }
}
