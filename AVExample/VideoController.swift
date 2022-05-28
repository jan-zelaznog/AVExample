//
//  VideoController.swift
//  AVExample
//
//  Created by Ángel González on 27/05/22.
//

import UIKit
import AVKit
import AVFoundation

class VideoController: AVPlayerViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Técnica Básica para obtener un recurso:
        if let url = Bundle.main.url(forResource: "rotoplas_cortinilla", withExtension: "mp4") {
            self.player = AVPlayer(url: url)
        }
    }
}
