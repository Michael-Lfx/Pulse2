//
//  LoopData.m
//  Pulse2
//
//  Created by Henry Thiemann on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "LoopData.h"

@interface LoopData ()

@property(nonatomic) NSDictionary *plistData;
@property(nonatomic) NSString *loopName;

@end

@implementation LoopData

- (instancetype)initWithPlist:(NSString *)plistName loop:(NSString *)loopName {
    self = [super init];
    
    if (self) {
        NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:plistName ofType:@"plist"];
        self.plistData = [[NSDictionary alloc] initWithContentsOfFile:pathToPlist];
        
        self.loopName = loopName;
    }
    
    return self;
}

- (NSString *)getLoopName {
    return _loopName;
}

- (int)getBPM {
    return (int)[[_plistData valueForKey:@"bpm"] integerValue];
}

- (int)getNumBeats {
    return (int)[[_plistData valueForKey:@"beats"] integerValue];
}

- (int)getNumVoices {
    return (int)[[[self getLoopData] valueForKey:@"beat values"] count];
}

- (NSArray *)getBeatValuesForVoice:(int)voiceNumber {
    NSArray *beatValues = [[self getLoopData] valueForKey:@"beat values"];
    return beatValues[voiceNumber];
}
- (NSDictionary *)getBeatMap {
    NSMutableDictionary *beatMap = [[NSMutableDictionary alloc] init];
    
    NSArray *beatValues = [[self getLoopData] valueForKey:@"beat values"];
    
    for (int i = 0; i < [beatValues count]; i++) {
        NSArray *voiceValues = beatValues[i];
        for (NSNumber *value in voiceValues) {
            if ([beatMap objectForKey:value] == nil) {
                [beatMap setObject:[NSMutableArray arrayWithObject:[NSNumber numberWithInt:i]] forKey:value];
            } else {
                [[beatMap objectForKey:value] addObject:[NSNumber numberWithInt:i]];
            }
        }
    }
    
    return beatMap;
}

- (NSDictionary *)getLoopData {
    return [[_plistData valueForKey:@"audio files"] valueForKey:_loopName];
}

@end
