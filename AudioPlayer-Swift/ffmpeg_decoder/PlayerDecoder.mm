//
//  PlayerDecoder.m
//  AudioPlayer-Swift
//
//  Created by Sean on 2018/8/21.
//  Copyright © 2018年 private. All rights reserved.
//

#import "PlayerDecoder.h"
#import "accompany_decoder_controller.h"

@interface PlayerDecoder () {
    AccompanyDecoderController * _decoderController;
}
@end

@implementation PlayerDecoder
- (id)initWith:(NSString *)path {
    self = [super init];
    if (self) {
        _decoderController = new AccompanyDecoderController();
        _decoderController->init([path cStringUsingEncoding:NSUTF8StringEncoding], 0.2f);
    }
    return self;
}

- (void)stop {
    if (NULL != _decoderController) {
        _decoderController->destroy();
        delete _decoderController;
        _decoderController = NULL;
    }
}

- (NSInteger)channels {
    return _decoderController->getChannels();
}

- (NSInteger)sampleRate {
    return _decoderController->getAudioSampleRate();
}

- (void)readSamples:(short *)samples size:(int)size {
    _decoderController->readSamples(samples, size);
}
@end
