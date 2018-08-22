//
//  CommentUtil.swift
//  AudioRecorder-Swift
//
//  Created by Sean on 2018/6/4.
//  Copyright © 2018年 swift. All rights reserved.
//

import Foundation

class CommonUtil {
    class func bundlePath(_ fileName: String) -> String {
        let bundlePath = Bundle.main.bundlePath as NSString
        
        return bundlePath.appendingPathComponent(fileName)
    }
    
    class func documentsPath(_ documentsPath: String) -> String {
        let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
        
        guard let rootPath = documentDirectory else {
            return ""
        }
        
        return (rootPath as NSString).appendingPathComponent(documentsPath)
    }
}
