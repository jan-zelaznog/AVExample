//
//  YTViewController.swift
//  AVExample
//
//  Created by Ángel González on 27/05/22.
//

import UIKit
import YouTubeiOSPlayerHelper

class YTViewController: UIViewController, YTPlayerViewDelegate {
    var videoView = YTPlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.frame = self.view.frame.insetBy(dx: 20, dy: 100)
        self.view.addSubview(videoView)
        videoView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        videoView.load(withVideoId: "7-iqjtskGGw")
    }

    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        self.videoView.playVideo()
    }
}
