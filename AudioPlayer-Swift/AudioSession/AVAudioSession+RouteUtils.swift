//
//  AVAudioSession+RouteUtils.swift
//  AudioRecorder-Swift
//
//  Created by Sean on 2018/6/12.
//  Copyright © 2018年 swift. All rights reserved.
//

import AVFoundation

extension AVAudioSession {
    public func usingBlueTooth() -> Bool {
        let inputs = currentRoute.inputs
        let blueToothInputRoutes = [convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP)]
        
        for description in inputs {
            if blueToothInputRoutes.contains(convertFromAVAudioSessionPort(description.portType)) {
                return true
            }
        }
        
        let outputs = currentRoute.outputs
        let blueToothOutputRoutes = [convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothHFP), convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothLE), convertFromAVAudioSessionPort(AVAudioSession.Port.bluetoothA2DP)]
        for description in outputs {
            if blueToothOutputRoutes.contains(convertFromAVAudioSessionPort(description.portType))  {
                return true
            }
        }
        
        return false
    }
    
    public func usingWiredMicrophone() -> Bool {
        let inputs = currentRoute.inputs
        let headSetInputRoutes = [convertFromAVAudioSessionPort(AVAudioSession.Port.headsetMic)]
        
        for description in inputs {
            if headSetInputRoutes.contains(convertFromAVAudioSessionPort(description.portType)) {
                return true
            }
        }
        
        let outputs = currentRoute.outputs
        let headSetOutputRoutes = [convertFromAVAudioSessionPort(AVAudioSession.Port.headphones), convertFromAVAudioSessionPort(AVAudioSession.Port.usbAudio)]
        for description in outputs {
            if headSetOutputRoutes.contains(convertFromAVAudioSessionPort(description.portType)) {
                return true
            }
        }
        
        return false
    }
    
    public func shouldShowEarphoneAlert() -> Bool {
        let outputs = currentRoute.outputs
        let headSetOutputRoutes = [convertFromAVAudioSessionPort(AVAudioSession.Port.builtInReceiver), convertFromAVAudioSessionPort(AVAudioSession.Port.builtInSpeaker)]
        
        for description in outputs {
            if headSetOutputRoutes.contains(convertFromAVAudioSessionPort(description.portType)) {
                return true
            }
        }
        
        return false
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionPort(_ input: AVAudioSession.Port) -> String {
	return input.rawValue
}
