//
//  LoopData.h
//  Pulse2
//
//  Created by Henry Thiemann on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoopData : NSObject

- (instancetype)initWithPlist:(NSString *)plistName loop:(NSString *)loopName;
- (NSString *)getLoopName;
- (NSString *)getMinigameName;
- (int)getBPM;
- (int)getNumBeats;
- (int)getNumVoices;
- (NSArray *)getBeatValuesForVoice:(int)voiceNumber;
- (NSDictionary *)getBeatMap;

@end
