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
        let blueToothInputRoutes = [AVAudioSessionPortBluetoothHFP]
        
        for description in inputs {
            if blueToothInputRoutes.contains(description.portType) {
                return true
            }
        }
        
        let outputs = currentRoute.outputs
        let blueToothOutputRoutes = [AVAudioSessionPortBluetoothHFP, AVAudioSessionPortBluetoothLE, AVAudioSessionPortBluetoothA2DP]
        for description in outputs {
            if blueToothOutputRoutes.contains(description.portType)  {
                return true
            }
        }
        
        return false
    }
    
    public func usingWiredMicrophone() -> Bool {
        let inputs = currentRoute.inputs
        let headSetInputRoutes = [AVAudioSessionPortHeadsetMic]
        
        for description in inputs {
            if headSetInputRoutes.contains(description.portType) {
                return true
            }
        }
        
        let outputs = currentRoute.outputs
        let headSetOutputRoutes = [AVAudioSessionPortHeadphones, AVAudioSessionPortUSBAudio]
        for description in outputs {
            if headSetOutputRoutes.contains(description.portType) {
                return true
            }
        }
        
        return false
    }
    
    public func shouldShowEarphoneAlert() -> Bool {
        let outputs = currentRoute.outputs
        let headSetOutputRoutes = [AVAudioSessionPortBuiltInReceiver, AVAudioSessionPortBuiltInSpeaker]
        
        for description in outputs {
            if headSetOutputRoutes.contains(description.portType) {
                return true
            }
        }
        
        return false
    }
}
