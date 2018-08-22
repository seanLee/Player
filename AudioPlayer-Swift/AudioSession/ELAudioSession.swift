//
//  ELAudioSession.swift
//  AudioRecorder-Swift
//
//  Created by Sean on 2018/6/4.
//  Copyright © 2018年 swift. All rights reserved.
//

import Foundation
import AVFoundation

open class ELAudioSession {
    
    open class func shareInstance() -> ELAudioSession {
        return ELAudioSession()
    }
    
    let audioSession: AVAudioSession
    
    var preferredSampleRate: Float64
    
    init() {
        preferredSampleRate = 44100.0
        audioSession = AVAudioSession.sharedInstance()
        
        adjustOnRouteChange()
    }
    
    private var _category: String = String()
    open var category: String {
        get { return _category }
        
        set {
            _category = newValue
            
            do {
                try audioSession.setCategory(newValue)
            }
            catch {
                print("get errors when setCategory")
            }
        }
    }
    
    private var _active: Bool = false
    open var active: Bool {
        get { return _active }
        
        set {
            _active = newValue
            
            do {
                try audioSession.setPreferredSampleRate(preferredSampleRate)
                try audioSession.setActive(newValue)
            }
            catch {
                print("get errors when setActive")
            }
            
            _currentSampleRate = audioSession.sampleRate
        }
    }
    
    private var _preferredLatency: TimeInterval = 0.0
    open var preferredLatency: TimeInterval {
        get { return _preferredLatency}
        
        set {
            _preferredLatency = newValue
            
            do {
                try audioSession.setPreferredIOBufferDuration(newValue)
            }
            catch {
                print("get errors when setPreferredLatency")
            }
        }
    }
    
    private var _currentSampleRate: Float64 = 0
    open var currentSampleRate: Float64 {
        get { return _currentSampleRate}
    }
    
    open func addRouteChangeListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.onNotificationAudioRouteChange(_:)), name: .AVAudioSessionRouteChange, object: nil)
        
        adjustOnRouteChange()
    }
    
    @objc func onNotificationAudioRouteChange(_ sender: Notification) {
        adjustOnRouteChange()
    }
    
    private func adjustOnRouteChange() {
        let _ = AVAudioSession.sharedInstance().currentRoute
        
        if (AVAudioSession.sharedInstance().usingWiredMicrophone()) {
            
        } else {
            if !AVAudioSession.sharedInstance().usingBlueTooth() {
                do {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
                }
                catch {
                    print("some errors happend")
                }
            }
        }
    }
}
