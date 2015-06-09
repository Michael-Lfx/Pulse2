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

@interface SongTrainScene : SKScene

- (instancetype)initWithLoopData:(LoopData *)data graphics:(GraphicsController *)graphics conductor:(Conductor *)conductor size:(CGSize)size;

@property GraphicsController *graphics;
@property Conductor *conductor;
@property LoopData *loopData;
@property double nextBeat;
@property BOOL resetLoopBeat;
@property BOOL trainIsJumping;
@property BOOL reachedGoal;
@property double resetLoopTime;
@property double lastBeat;
@property SKSpriteNode *train;
@property int streakCounter;
@property SKLabelNode *streakDisplay;
@property SKLabelNode *highScoreDisplay;
@property CGFloat leftTrackCenter;
@property CGFloat rightTrackCenter;
@property SystemSoundID hihatSound;

- (void)displayDirections;

@end
