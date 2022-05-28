//
//  AudioPlayerViewController.swift
//  MyApp
//
//  Created by Jan Zelaznog on 14/10/21.
//

import UIKit
import AVKit
import AVFoundation
import MediaPlayer

class AudioPlayerViewController: UIViewController, AVAudioPlayerDelegate {
    var audioPlayer = AVAudioPlayer()
    var archivoAudio = "Mar_De_La_Tranquilidad"
    let s1 = UISlider ()
    var timer:Timer?
    
    // Reproducir
    // Se utiliza una referencia débil o "sin dueño" para evitar un retain cycle
    // Garbage-Collector != ARC (automatic reference counting)
    // [weak self]
    // [unowned self]
    func conectarControlCenter () {
        let controlCenter = MPRemoteCommandCenter.shared()
        controlCenter.playCommand.addTarget { [unowned self] event in
            
            if self.audioPlayer.isPlaying {
                return .commandFailed
            }
            self.audioPlayer.play()
            return .success
        }
        // Detener
        controlCenter.pauseCommand.addTarget { event in
            if self.audioPlayer.isPlaying {
                self.audioPlayer.stop()
                return .success
            }
            return .commandFailed
        }
    }
    
    func inicializarCCInfo() {
        let titulo = archivoAudio.replacingOccurrences(of: "_", with: " ")
        var infoDict = [String : Any]()
        infoDict[MPMediaItemPropertyTitle] = titulo
        infoDict[MPMediaItemPropertyPlaybackDuration] = audioPlayer.duration
        infoDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
        MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDict
    }
    
    func actualizaCCInfo() {
        if var infoDict = MPNowPlayingInfoCenter.default().nowPlayingInfo {
            infoDict[MPNowPlayingInfoPropertyElapsedPlaybackTime] = audioPlayer.currentTime
            var pausado = 0
            if audioPlayer.isPlaying {
                pausado = 1
            }
            infoDict[MPNowPlayingInfoPropertyPlaybackRate] = pausado
            MPNowPlayingInfoCenter.default().nowPlayingInfo = infoDict
        }
    }
    
    @objc func manejaInterrupcion(_ notif : Notification) {
        guard let info = notif.userInfo,
              let valor = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let tipo = AVAudioSession.InterruptionType(rawValue: valor)
        else {
            return
        }
        if tipo == .began {
            // que hago cuando inicia la interrupción?
            self.stop()
        }
        else if tipo == .ended {
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                self.play()
            }
            catch {
                
            }
        }
    }
    
    func activarNotificacion () {
        NotificationCenter.default.addObserver(self, selector:#selector(manejaInterrupcion(_ :)), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        // si la reproducción ya se acabó, anulamos el timer
        timer?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    func cargarAudio() {
        // obtener la URL del audio
        guard let url = Bundle.main.url(forResource: archivoAudio, withExtension: "mp3")
        else { return }
        do {
            // Obtenemos la sesión de audio compartida (audio del dispositivo en general)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode:.default)
            try AVAudioSession.sharedInstance().setActive(true)
            ///******//
            try audioPlayer = AVAudioPlayer(contentsOf: url)
            audioPlayer.prepareToPlay()
            audioPlayer.delegate = self
            audioPlayer.volume = 0.5
            s1.maximumValue = Float(audioPlayer.duration)
            timer = Timer.scheduledTimer(timeInterval:1.0, target:self, selector:#selector(actualizaSlider), userInfo:nil, repeats:true)
            conectarControlCenter()
            inicializarCCInfo()
            activarNotificacion()
        }
        catch {
            print ("ocurrió un error con el audio \(error.localizedDescription)")
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        cargarAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let l1=UILabel()
        l1.text="AudioPlayer"
        l1.font=UIFont.systemFont(ofSize: 24)
        l1.autoresizingMask = .flexibleWidth
        l1.translatesAutoresizingMaskIntoConstraints=true
        l1.frame=CGRect(x: 0, y: 50, width: self.view.frame.width, height: 50)
        l1.textAlignment = .center
        self.view.addSubview(l1)
        
        let b1=UIButton(type: .system)
        b1.setTitle("Play", for: .normal)
        b1.autoresizingMask = .flexibleWidth
        b1.translatesAutoresizingMaskIntoConstraints=true
        b1.frame=CGRect(x: 20, y: 100, width: 100, height: 40)
        self.view.addSubview(b1)
        b1.addTarget(self, action: #selector(self.botonPlayTouch(_:)), for: .touchUpInside)
        
        let b2=UIButton(type: .system)
        b2.setTitle("Stop", for: .normal)
        b2.autoresizingMask = .flexibleWidth
        b2.translatesAutoresizingMaskIntoConstraints=true
        b2.frame=CGRect(x: self.view.frame.width-100, y: 100, width: 100, height: 40)
        self.view.addSubview(b2)
        b2.addTarget(self, action: #selector(self.botonStopTouch(_:)), for: .touchUpInside)
        
        // se tiene que hacer property
        //let s1=UISlider ()
        s1.autoresizingMask = .flexibleWidth
        s1.translatesAutoresizingMaskIntoConstraints=true
        s1.frame=CGRect(x: 20, y:150, width: self.view.frame.width-40, height: 50)
        self.view.addSubview(s1)
        s1.addTarget(self, action: #selector(self.slider1Touch(_:)), for: .valueChanged)
        
        let l2=UILabel()
        l2.text="Volumen"
        l2.autoresizingMask = .flexibleWidth
        l2.translatesAutoresizingMaskIntoConstraints=true
        l2.frame=CGRect(x: 20, y: 200, width: 100, height: 40)
        self.view.addSubview(l2)

        let s2=UISlider()
        s2.autoresizingMask = .flexibleWidth
        s2.translatesAutoresizingMaskIntoConstraints=true
        s2.frame=CGRect(x: 20, y: 250, width: self.view.frame.width/2, height: 50)
        self.view.addSubview(s2)
        s2.addTarget(self, action: #selector(self.slider2Touch(_:)), for: .valueChanged)
        s2.value = 0.5
        
        if let laURL = Bundle.main.url(forResource: "song", withExtension: "gif") {
            let elGIF = UIImage.animatedImage(withAnimatedGIFURL: laURL)
            let imgContainer = UIImageView(image: elGIF)
            imgContainer.translatesAutoresizingMaskIntoConstraints=true
            imgContainer.frame=CGRect(x: 0, y: 400, width: 200, height: 200)
            imgContainer.center.x = self.view.center.x
            self.view.addSubview(imgContainer)
        }
    }
    
    @objc func actualizaSlider() {
        let posicion = audioPlayer.currentTime
        s1.value = Float(posicion)
        actualizaCCInfo()
    }
    
    @objc func botonPlayTouch(_ sender:UIButton!) {
        play()
    }
    
    func play () {
        print("tocaste el botón Play")
        audioPlayer.play()
        actualizaCCInfo()
    }
    
    @objc func botonStopTouch(_ sender:UIButton!) {
        stop()
    }
    
    func stop() {
        print("tocaste el botón Stop")
        audioPlayer.stop()
        actualizaCCInfo()
    }
    
    @objc func slider1Touch(_ sender:UISlider!) {
        print("slider reproducción se ajustó en \(sender.value)")
        audioPlayer.currentTime = Double(sender.value)
        actualizaCCInfo()
    }
    
    @objc func slider2Touch(_ sender:UISlider!) {
        print("slider volumen se ajustó en \(sender.value)")
        audioPlayer.volume = sender.value
    }

}
