//
//  Conductor.m
//  Pulse2
//
//  Created by Henry Thiemann on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "Conductor.h"

@interface Conductor ()

@property(nonatomic) AEAudioController *audioController;

@property(nonatomic) NSDictionary *data;

@property(nonatomic) NSMutableDictionary *audioFilePlayers;
@property(nonatomic) NSMutableDictionary *channelGroups;

@end

@implementation Conductor

double _bpm;
double _beats;

- (instancetype)initWithAudioController:(AEAudioController *)audioController plist:(NSString *)plist {
    self = [super init];
    
    if (self) {
        
        self.audioController = audioController;
        
        NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
        self.data = [[NSDictionary alloc] initWithContentsOfFile:pathToPlist];
        
        NSString *extension = [_data objectForKey:@"extension"];
        _bpm = [[_data objectForKey:@"bpm"] doubleValue];
        _beats = [[_data objectForKey:@"beats"] doubleValue];
        
        NSDictionary *audioFileData = [_data objectForKey:@"audio files"];
        
        self.audioFilePlayers = [[NSMutableDictionary alloc] init];
        self.channelGroups = [[NSMutableDictionary alloc] init];
        
        for (NSString *filename in [audioFileData allKeys]) {
            NSURL *url = [[NSBundle mainBundle] URLForResource:filename withExtension:extension];
            
            AEAudioFilePlayer *player = [AEAudioFilePlayer audioFilePlayerWithURL:url audioController:_audioController error:NULL];
            player.loop = YES;
            player.channelIsPlaying = NO;
            player.volume = 0;
            
            AEChannelGroupRef group = [_audioController createChannelGroup];
            [_audioController addChannels:[NSArray arrayWithObject:player] toChannelGroup:group];
            
            [_audioFilePlayers setObject:player forKey:filename];
            [_channelGroups setObject:[NSValue valueWithPointer:group] forKey:filename];
        }
    }
    
    return self;
}

- (void)start {
    for (NSString *filename in _audioFilePlayers) {
        AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:filename];
        player.channelIsPlaying = YES;
    }
}

- (void)stop {
    for (NSString *filename in _audioFilePlayers) {
        AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:filename];
        player.channelIsPlaying = NO;
    }
}

- (void)setVolumeForLoop:(NSString *)loopName withVolume:(double)volume {
    AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:loopName];
    player.volume = volume;
}

- (void)fadeVolumeForLoop:(NSString *)loopName withDuration:(double)duration fadeIn:(BOOL)fadeIn{ //doesn't fade yet
    AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:loopName];
    [UIView animateWithDuration:duration animations:^(void){
       if(fadeIn)
           player.volume = 1;
       else
           player.volume = 0;
    }];
}

- (double)getPowerLevelForLoop:(NSString *)loopName {
    AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:loopName];
    AEChannelGroupRef group = [[_channelGroups objectForKey:loopName] pointerValue];
    
    Float32 powerLevel, peakLevel;
    [_audioController averagePowerLevel:&powerLevel peakHoldLevel:&peakLevel forGroup:group];
    
    return pow(10, powerLevel / 40) * player.volume;
}

- (double)getCurrentBeatForLoop:(NSString *)loopName {
    AEAudioFilePlayer *player = [_audioFilePlayers objectForKey:loopName];
    return _beats * (player.currentTime / player.duration);
}

- (NSArray *)getFilenames {
    return [[_data objectForKey:@"audio files"] allKeys];
}

@end
