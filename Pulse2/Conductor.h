//
//  Conductor.h
//  Pulse2
//
//  Created by Henry Thiemann on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>

@interface Conductor : NSObject

- (instancetype)initWithAudioController:(AEAudioController *)audioController plist:(NSString *)plist;

- (void)start;
- (void)stop;

- (void)setVolumeForLoop:(NSString *)filename withVolume:(double)volume;

- (double)getPowerLevelForLoop:(NSString *)filename;
- (double)getCurrentBeatForLoop:(NSString *)filename;
- (NSArray *)getFilenames;

@end
