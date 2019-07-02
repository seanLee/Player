//
//  AudioOutput.swift
//  AudioPlayer-Swift
//
//  Created by Sean on 2018/8/18.
//  Copyright © 2018年 private. All rights reserved.
//

import Foundation
import CoreAudio
import AudioToolbox
import CoreFoundation
import AVFoundation

protocol FillDataDelegate {
    
    @discardableResult
    func fillAudioData(_ data: UnsafeMutablePointer<AudioBufferList>?, _ frameNum: Int, _ channels: Int) -> Int
}

public class AudioOutput {
    var sampleRate: Float64
    var channels: Float64
    var outData: UnsafeMutablePointer<AudioBufferList>?
    
    var fillDataDelegate: FillDataDelegate?
    
    private let SMAudioIOBufferDurationSmall: TimeInterval = 0.0058
    
    private var auGraph: AUGraph?
    private var ioNode: AUNode = 0
    private var ioUnit: AudioUnit?
    private var convertNode: AUNode = 0
    private var convertUnit: AudioUnit?
    
    init(_ channels: Int, _ sampleRate: Int) {
        ELAudioSession.shareInstance().category = convertFromAVAudioSessionCategory(AVAudioSession.Category.playback)
        ELAudioSession.shareInstance().preferredSampleRate = Float64(sampleRate)
        ELAudioSession.shareInstance().active = true
        ELAudioSession.shareInstance().preferredLatency = SMAudioIOBufferDurationSmall * 4.0
        ELAudioSession.shareInstance().addRouteChangeListener()
        
        self.sampleRate = Float64(sampleRate)
        self.channels = Float64(channels)
        self.outData = calloc(8192, MemoryLayout<Int16>.size).assumingMemoryBound(to: AudioBufferList.self)
        
        
        addAudioSessionInterruptedObserver()
        
        createAudioUnitGraph()
    }
    
    private func createAudioUnitGraph() {
        checkStatus(NewAUGraph(&auGraph), "Could not create a new AUGraph", true)
        
        addAudioUnitNodes()
        
        checkStatus(AUGraphOpen(auGraph!), "Could not open AUGraph", true)
        
        getUnitsFromNodes()
        
        setAudioUnitProperties()
        
        makeNodeConnections()
        
        CAShow(UnsafeMutableRawPointer(auGraph!))
        
        checkStatus(AUGraphInitialize(auGraph!), "Could not initialize AUGraph", true)
    }
    
    private func addAudioUnitNodes() {
        var ioDescription = AudioComponentDescription()
        ioDescription.componentManufacturer = kAudioUnitManufacturer_Apple
        ioDescription.componentType = kAudioUnitType_Output
        ioDescription.componentSubType = kAudioUnitSubType_RemoteIO
        
        checkStatus(AUGraphAddNode(auGraph!, &ioDescription, &ioNode), "Could not add I/O node to AUGraph", true)
        
//        var convertDescription = AudioComponentDescription()
        ioDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
        ioDescription.componentType = kAudioUnitType_FormatConverter;
        ioDescription.componentSubType = kAudioUnitSubType_AUConverter;
        
        checkStatus(AUGraphAddNode(auGraph!, &ioDescription, &convertNode), "Could not add Convert node to AUGraph", true)
    }
    
    private func getUnitsFromNodes() {
        checkStatus(AUGraphNodeInfo(auGraph!, ioNode, nil, &ioUnit), "Could not retrieve node info for I/O node", true)
        
        checkStatus(AUGraphNodeInfo(auGraph!, convertNode, nil, &convertUnit), "Could not retrieve node info for Convert node", true)
    }
    
    private let inputElement: AudioUnitElement = 1
    
    private func setAudioUnitProperties() {
        var streamFormat = noninterleavedPCMFormatWithChannels(UInt32(channels))
        
        checkStatus(AudioUnitSetProperty(ioUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, inputElement, &streamFormat, UInt32(MemoryLayout.size(ofValue: streamFormat))), "Could not set stream format on I/O unit output scope", true)
        
        let bytesPerSample = UInt32(MemoryLayout<Int16>.size)
        
        var _clientFormat16int = AudioStreamBasicDescription()
        _clientFormat16int.mFormatID = kAudioFormatLinearPCM
        _clientFormat16int.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kLinearPCMFormatFlagIsPacked;
        _clientFormat16int.mBytesPerPacket = bytesPerSample * UInt32(channels)
        _clientFormat16int.mFramesPerPacket = 1
        _clientFormat16int.mBytesPerFrame = bytesPerSample * UInt32(channels)
        _clientFormat16int.mChannelsPerFrame = UInt32(channels)
        _clientFormat16int.mBitsPerChannel = 8 * bytesPerSample
        _clientFormat16int.mSampleRate = sampleRate
        
        checkStatus(AudioUnitSetProperty(convertUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 0, &streamFormat, UInt32(MemoryLayout.size(ofValue: streamFormat))), "augraph recorder normal unit set client format error", true)
        
        checkStatus(AudioUnitSetProperty(convertUnit!, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Input, 0, &_clientFormat16int, UInt32(MemoryLayout.size(ofValue: _clientFormat16int))), "augraph recorder normal unit set client format error", true)
    }
    
    private let renderCallback: AURenderCallback = {
        
        (inRefCon: UnsafeMutableRawPointer,
        ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
        inTimeStamp: UnsafePointer<AudioTimeStamp>,
        inBusNumber: UInt32, _ inNumberFrames: UInt32,
        ioData: UnsafeMutablePointer<AudioBufferList>?) in
        
        let player = Unmanaged<AudioOutput>.fromOpaque(inRefCon).takeUnretainedValue()
        let bufferList = UnsafeMutableAudioBufferListPointer(ioData)!

        for buffer in bufferList {
            memset(buffer.mData, 0, Int(buffer.mDataByteSize))
        }

        if let delegate = player.fillDataDelegate {
            delegate.fillAudioData(player.outData, Int(inNumberFrames), Int(player.channels))
            for buffer in bufferList {
                memcpy(buffer.mData, player.outData, Int(buffer.mDataByteSize));
            }
        }
        
        return noErr
    }
    
    private func makeNodeConnections() {
        checkStatus(AUGraphConnectNodeInput(auGraph!, convertNode, 0, ioNode, 0), "Could not connect I/O node input to mixer node input", true)

        var callback = AURenderCallbackStruct()
        callback.inputProc = renderCallback
        callback.inputProcRefCon = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        
        checkStatus(AudioUnitSetProperty(convertUnit!, kAudioUnitProperty_SetRenderCallback, kAudioUnitScope_Input, 0, &callback, UInt32(MemoryLayout.size(ofValue: callback))), "Could not set InputCallback For IONode", true)
        
        AudioOutputUnitStart(convertUnit!)
    }
    
    private func noninterleavedPCMFormatWithChannels(_ channels: UInt32) -> AudioStreamBasicDescription {
        let bytesPerSample = UInt32(MemoryLayout<Float32>.size)
        
        var asbd = AudioStreamBasicDescription()
        asbd.mSampleRate = sampleRate
        asbd.mFormatID = kAudioFormatLinearPCM
        asbd.mFormatFlags = kAudioFormatFlagsNativeFloatPacked | kAudioFormatFlagIsNonInterleaved
        asbd.mBitsPerChannel = 8 * bytesPerSample
        asbd.mBytesPerFrame = bytesPerSample
        asbd.mBytesPerPacket = bytesPerSample
        asbd.mFramesPerPacket = 1
        asbd.mChannelsPerFrame = channels
        
        return asbd
    }
    
    private func addAudioSessionInterruptedObserver() {
        removeAudioSessionInterruptedObserver()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.onNotificationAudioInterrupted(sender:)),
                                               name: AVAudioSession.interruptionNotification,
                                               object: AVAudioSession.sharedInstance())
    }
    
    private func removeAudioSessionInterruptedObserver() {
        NotificationCenter.default.removeObserver(self, name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    @objc private func onNotificationAudioInterrupted(sender: Notification) {
        if let type = sender.userInfo?[AVAudioSessionInterruptionTypeKey] as? AVAudioSession.InterruptionType {
            switch type {
            case .began:
                stop()
            case .ended:
                play()
            }
        }
    }
    
    deinit {
        if outData != nil {
            free(outData)
            outData = nil
        }
        
        destroyAudioUnitGraph()
        removeAudioSessionInterruptedObserver()
    }
    
    private func destroyAudioUnitGraph() {
        AUGraphStop(auGraph!);
        AUGraphUninitialize(auGraph!);
        AUGraphClose(auGraph!);
        AUGraphRemoveNode(auGraph!,ioNode);
        DisposeAUGraph(auGraph!);
        ioUnit = nil;
        ioNode = 0;
        auGraph = nil;
    }
    
    @discardableResult
    public func play() -> Bool {
        checkStatus(AUGraphStart(auGraph!), "Could not start AUGraph", true);

        return true
    }
    
    public func stop() {
        
    }
    
    private func checkStatus(_ status: OSStatus, _ message: String, _ fatal: Bool) {
        guard status != noErr else {
            return
        }
        
        let count = 5
        let stride = MemoryLayout<OSStatus>.stride
        let byteCount = stride * count
        
        var error = CFSwapInt32HostToBig(UInt32(status))
        var cc: [CChar] = [CChar](repeating: 0, count: byteCount)
        withUnsafeBytes(of: &error) { buffer in
            for (index, byte) in buffer.enumerated() {
                cc[index + 1] = CChar(byte)
            }
        }
        
        if (isprint(Int32(cc[1])) > 0 && isprint(Int32(cc[2])) > 0 && isprint(Int32(cc[3])) > 0 && isprint(Int32(cc[4])) > 0) {
            cc[0] = "\'".utf8CString[0]
            cc[5] = "\'".utf8CString[0]
            let errStr = NSString(bytes: &cc, length: cc.count, encoding: String.Encoding.ascii.rawValue)
            print("Error: \(message) (\(errStr!))")
        } else {
            print("Error: \(error)")
        }
        
        exit(1)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVAudioSessionCategory(_ input: AVAudioSession.Category) -> String {
	return input.rawValue
}
