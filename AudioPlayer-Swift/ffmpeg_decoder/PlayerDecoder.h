//
//  PlayerDecoder.h
//  AudioPlayer-Swift
//
//  Created by Sean on 2018/8/21.
//  Copyright © 2018年 private. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlayerDecoder : NSObject
- (id)initWith:(NSString *)path;

- (void)stop;

- (NSInteger)channels;

- (NSInteger)sampleRate;

- (void)readSamples:(short *)samples size:(int)size;
@end
