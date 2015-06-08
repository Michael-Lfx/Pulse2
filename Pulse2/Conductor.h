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


- (instancetype)initWithAudioController:(AEAudioController *)audioController;

- (void)loadSoundscapeWithPlistNamed:(NSString *)plist;
- (void)releaseSoundscape;

- (void)start;
- (void)stop;

- (void)setVolumeForLoop:(NSString *)loopName withVolume:(double)volume;
//- (void)fadeVolumeForLoop:(NSString *)loopName withDuration:(double)duration fadeIn:(BOOL)fadeIn;

- (void)setMinigameLoop:(NSString *)loopName;

- (double)getPowerLevelForLoop:(NSString *)loopName;
- (double)getCurrentBeatForLoop:(NSString *)loopName;
- (NSArray *)getFilenames;

@property(nonatomic) AEAudioController *audioController;

@property(nonatomic) NSDictionary *data;

@property(nonatomic) NSMutableDictionary *audioFilePlayers;
@property(nonatomic) NSMutableDictionary *channelGroups;
@property AEAudioFilePlayer *theMinigameLoop;
@property AEChannelGroupRef masterChannel;

@property BOOL shouldCheckLevels;

@end
