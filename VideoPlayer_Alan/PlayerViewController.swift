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
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var backwardButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var placeHolderLabel: UILabel!
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        setUpPlayer()
    }
    
    @IBAction func fullScreenButtonPressed(_ sender: UIButton) {
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
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        if player.rate > 0.0 {
            player.pause()
            playButton.isSelected = false
        } else {
            player.play()
            playButton.isSelected = true
        }
    }
    
    @IBAction func fastForwardButtonPressed(_ sender: UIButton) {
        let time = player.currentTime() + duration
        player.seek(to: time)
    }
    
    @IBAction func fastBackwardButtonPressed(_ sender: UIButton) {
        let time = player.currentTime() - duration
        player.seek(to: time)
    }
    
    @IBAction func muteButtonPressed(_ sender: UIButton) {
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
    
    var player = AVPlayer()
    var playerLayer = AVPlayerLayer()
    let duration = CMTime(seconds: 10.0, preferredTimescale: CMTimeScale(1.0))
    
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
    
    func setUpPlayer() {
        
        guard let urlString = textField.text, let videoURL = URL(string: urlString) else {
            return
        }
        player = AVPlayer(url: videoURL)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        placeHolderLabel.isHidden = true
        
        let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(1000.0))
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
            guard let currentItem = self?.player.currentItem else {
                return
            }
            guard let currentTime = self?.player.currentTime() else {
                return
            }
            let progress = CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(currentItem.duration)
            self?.slider.setValue(Float(progress), animated: false)
            // Time Format
            let currentTimeFloat = CMTimeGetSeconds(currentTime)
            
            guard let currentTimeIntValue = Int(String(format: "%.0f", currentTimeFloat)) else {
                return
            }
            guard let totalTimeIntValue = Int(String(format: "%.0f",  CMTimeGetSeconds(currentItem.duration))) else {
                return
            }
            
            let currentMinuteString = currentTimeIntValue.minute().twoDigitString()
            let currentSecondString = currentTimeIntValue.second().twoDigitString()
            let totalMinuteString = totalTimeIntValue.minute().twoDigitString()
            let totalSecondString = totalTimeIntValue.second().twoDigitString()
            self?.currentTimeLabel.text = currentMinuteString + ":" + currentSecondString
            self?.totalDurationLabel.text = totalMinuteString + ":" + totalSecondString
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
