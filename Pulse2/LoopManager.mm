//
//  LoopManager.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "LoopManager.h"

#include <iostream>
using namespace std;

@implementation LoopManager

bool _state = false;

- (instancetype)initWithAudioController:(AEAudioController *)audioController fileURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.audioController = audioController;
        
        self.looper = [AEAudioFilePlayer audioFilePlayerWithURL:url audioController:_audioController error:NULL];
        _looper.loop = YES;
        _looper.volume = 0;
        _looper.channelIsPlaying = NO;
        
        
        self.channelGroup = [_audioController createChannelGroup];
        [_audioController addChannels:[NSArray arrayWithObject:_looper] toChannelGroup:_channelGroup];
    }
    
    return self;
}

- (double)getCurrentAmplitude {
    Float32 powerLevel, peakLevel;
    [_audioController averagePowerLevel:&powerLevel peakHoldLevel:&peakLevel forGroup:_channelGroup];
    double amplitude = pow(10, powerLevel / 40);
    return amplitude;
}

@end
