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

double _currentAmplitude = 0.0;
bool _state = false;

- (instancetype)initWithAudioController:(AEAudioController *)audioController fileURL:(NSURL *)url {
    self = [super init];
    
    if (self) {
        self.audioController = audioController;
        
        self.looper = [AEAudioFilePlayer audioFilePlayerWithURL:url audioController:audioController error:NULL];
        _looper.loop = YES;
        _looper.volume = 0;
        _looper.channelIsPlaying = NO;
        
        [_audioController addChannels:[NSArray arrayWithObject:_looper]];
        
        self.receiver = [AEBlockAudioReceiver audioReceiverWithBlock:^(void *source, const AudioTimeStamp *time, UInt32 frames, AudioBufferList *audio) {
            
//            if (!_state) return;
            
            float leftVolume = 0.0f, rightVolume = 0.0f;
            
            for (int i = 0; i < audio->mNumberBuffers; i++) {
                AudioBuffer *pBuffer = &audio->mBuffers[i];
                int numSamples = frames * pBuffer->mNumberChannels;
                
                char *pData = (char *)pBuffer->mData;
                
                float rms = 0.0f;
                
                for (int j = 0; j < numSamples; j++) {
                    rms += pData[j] * pData[j];
                }
                
                if (numSamples > 0) {
                    rms = sqrtf(rms / numSamples);
                }
                
                if (i == 0) {
                    leftVolume = rms;
                }
                
                if (i == 1 || (i == 0 && audio->mNumberBuffers == 1)) {
                    rightVolume = rms;
                }
            }
            
            double avgRms = (rightVolume + leftVolume) / 2;
            
            double bias = 0.80;
            _currentAmplitude = _currentAmplitude * bias + avgRms * (1 - bias);
        }];
        
//        AEChannelGroupRef ref = [_audioController createChannelGroup];
        
        [_audioController addOutputReceiver:_receiver forChannel:_looper];
    }
    
    return self;
}

- (double)getCurrentAmplitude {
    return _currentAmplitude;
}

@end
