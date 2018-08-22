//
//  AudioPlayer.swift
//  AudioPlayer-Swift
//
//  Created by Sean on 2018/8/18.
//  Copyright © 2018年 private. All rights reserved.
//

import Foundation
import AudioToolbox

public class AudioPlayer {
    
    private var filePath: String
    
    private var player_decoder: PlayerDecoder?
    
    private var audioOutput: AudioOutput? 
    
    init(_ path: String) {
        filePath = path
    }
    
    public func start() {
        if (player_decoder == nil) {
            player_decoder =  PlayerDecoder.init(filePath)
        }
        
        if (audioOutput == nil) {
            audioOutput = AudioOutput.init(player_decoder!.channels(), player_decoder!.sampleRate())
            audioOutput!.fillDataDelegate = self
        }
        
        audioOutput!.play()
    }
    
    public func stop() {
        audioOutput?.stop()
        audioOutput = nil
        
        player_decoder!.stop()
        player_decoder = nil;
    }
}

extension AudioPlayer: FillDataDelegate {
    func fillAudioData(_ data: UnsafeMutablePointer<AudioBufferList>?, _ frameNum: Int, _ channels: Int) -> Int {

        memset(data, 0, frameNum * channels * MemoryLayout<Int16>.size);
        if let decoder = player_decoder {
            decoder.readSamples(UnsafeMutablePointer<Int16>(OpaquePointer(data)), size: Int32(frameNum * channels))
        }
        
        return 1
    }
}
