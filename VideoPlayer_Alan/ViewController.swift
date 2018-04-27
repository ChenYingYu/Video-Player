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

class ViewController: UIViewController {

    @IBOutlet weak var navigationBar: UINavigationBar!
    
    @IBOutlet weak var searchButtonStyle: UIButton!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    var player = AVPlayer()
    
    @IBAction func playOrPause(_ sender: UIButton) {
        if player.rate > 0.0 {
            player.pause()
        } else {
            player.play()
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
        } else {
            player.isMuted = true
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
        
        // AVPlayer
        
        let videoURL = URL(string: "https:s3-ap-northeast-1.amazonaws.com/mid-exam/Video/taeyeon.mp4")
        player = AVPlayer(url: videoURL!)
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = videoView.bounds
        videoView.layer.addSublayer(playerLayer)
        
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
}

