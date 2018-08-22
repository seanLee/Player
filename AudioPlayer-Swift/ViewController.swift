//
//  ViewController.swift
//  AudioPlayer-Swift
//
//  Created by Sean on 2018/8/18.
//  Copyright © 2018年 private. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {

    private lazy var player: AudioPlayer = {
        let path = CommonUtil.bundlePath("111.aac")
        print(path)
        return AudioPlayer(path)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func playAction(_ sender: Any) {
        player.start()
    }
    
    @IBAction func stopAction(_ sender: Any) {
        player.stop()
    }
}

