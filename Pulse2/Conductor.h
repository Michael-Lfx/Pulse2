//
//  Conductor.h
//  Pulse2
//
//  Created by Henry Thiemann on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import <UIKit/UIKit.h>

@interface Conductor : NSObject

- (instancetype)initWithAudioController:(AEAudioController *)audioController plist:(NSString *)plist;

- (void)start;
- (void)stop;

- (void)setVolumeForLoop:(NSString *)loopName withVolume:(double)volume;
- (void)fadeVolumeForLoop:(NSString *)loopName withDuration:(double)duration fadeIn:(BOOL)fadeIn;

- (double)getPowerLevelForLoop:(NSString *)loopName;
- (double)getCurrentBeatForLoop:(NSString *)loopName;
- (NSArray *)getFilenames;

@end
