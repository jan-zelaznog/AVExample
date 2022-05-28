//
//  ViewController.swift
//  AVExample
//
//  Created by Ángel González on 27/05/22.
//

import UIKit
import AVKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Si el recurso es local:
        // if let url = Bundle.main.url(forResource: "rotoplas_cortinilla", withExtension: "mp4") {
        if let url = URL(string: "http://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4") {
            //Utilizando el objeto PlayerViewController NO necesitamos implementar nada de los controles de reproducción
            do {
                try AVAudioSession.sharedInstance().setCategory(.playback, mode:.moviePlayback)
                try AVAudioSession.sharedInstance().setActive(true)
                let apvc = AVPlayerViewController()
                apvc.player = AVPlayer(url: url)
                apvc.view.frame = self.view.frame.insetBy(dx: 20, dy: 100)
                apvc.view.frame.origin = CGPoint.zero
                self.view.addSubview(apvc.view)
                self.addChild(apvc)
            }
            catch {
                
            }
            /*/
            // Presentar un video SIN controles de reproducción
            let player = AVPlayer(url: url)
            let videoLayer = AVPlayerLayer(player: player)
            videoLayer.frame = self.view.frame.insetBy(dx: 20, dy: 100)
            self.view.layer.addSublayer(videoLayer)
            player.play()
             */
        }
    }
    
}

