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
#import "GraphicsController.h"
#import "MinigameInteractor.h"

@interface OrbGameScene : SKScene

- (instancetype)initWithLoopData:(LoopData *)data graphics:(GraphicsController *)graphics conductor:(Conductor *)conductor size:(CGSize)size;

@property GraphicsController *graphics;
@property Conductor *conductor;
@property LoopData *loopData;

@property NSArray *beatValues;
@property double prevBeat;
@property double nextBeat;

@property SKSpriteNode *orb;
@property NSMutableArray *targets;
@property MinigameInteractor *interactor;

@property NSArray *targetPositions;
@property CGPoint prevPosition;
@property CGPoint nextPosition;
@property int prevNum;
@property int nextNum;

@property int streakCounter;
@property SKLabelNode *streakDisplay;
@property SKLabelNode *highScoreDisplay;

@property BOOL beatChecked;
@property BOOL notePlayed;
@property BOOL noteMissed;
@property BOOL ready;

@property double targetScore;
@property double currentScore;
@property BOOL reachedGoal;

@end
