//
//  SongTapScene.h
//  protogame191
//
//  Created by Ben McK on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "LoopData.h"
#import "Conductor.h"
#import "GraphicsController.h"
#import "MinigameInteractor.h"

@interface SongTapScene : SKScene

- (instancetype)initWithLoopData:(LoopData *)data graphics:(GraphicsController *)graphics conductor:(Conductor *)conductor size:(CGSize)size;

@property GraphicsController *graphics;
@property Conductor *conductor;
@property LoopData *loopData;
@property MinigameInteractor *interactor;
@property double nextBeat;
@property BOOL resetLoopBeat;
@property long resetLoopTime;
@property double lastBeat;
@property int streakCounter;
@property double currentScore;
@property double targetScore;
@property SKLabelNode *streakDisplay;
@property SKLabelNode *highScoreDisplay;
@property BOOL reachedGoal;

- (void)displayDirections;


@end
