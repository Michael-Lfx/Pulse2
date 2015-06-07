//
//  SongTrainScene.h
//  protogame191
//
//  Created by Ben McK on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "LoopData.h"
#import "Conductor.h"

@interface OrbGameScene : SKScene

- (instancetype)initWithLoopData:(LoopData *)data conductor:(Conductor *)conductor size:(CGSize)size;

@property Conductor *conductor;
@property LoopData *loopData;

@property NSArray *beatValues;
@property double prevBeat;
@property double nextBeat;

@property SKSpriteNode *orb;
@property NSMutableArray *targets;

@property NSArray *targetPositions;
@property CGPoint prevPosition;
@property CGPoint nextPosition;
@property int prevNum;
@property int nextNum;

@property BOOL beatChecked;
@property BOOL notePlayed;
@property BOOL ready;

@end
