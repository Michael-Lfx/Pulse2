//
//  LoopManager.h
//  Pulse2
//
//  Created by Henry Thiemann on 4/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AEAudioFilePlayer.h"
#import "AEBlockAudioReceiver.h"

@interface LoopManager : NSObject

- (instancetype)initWithAudioController:(AEAudioController *)audioController fileURL:(NSURL *)url;
- (double)getCurrentAmplitude;

@property AEAudioController *audioController;
@property AEAudioFilePlayer *looper;
@property AEChannelGroupRef channelGroup;

@end
