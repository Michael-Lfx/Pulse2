//
//  SongSwipeScene.h
//  protogame191
//
//  Created by Ben McK on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "LoopData.h"
#import "Conductor.h"

@interface SongSwipeScene : SKScene <UIGestureRecognizerDelegate>

- (instancetype)initWithLoopData:(LoopData *)data conductor:(Conductor *)conductor size:(CGSize)size;

@property Conductor *conductor;
@property LoopData *loopData;
@property double nextBeat;
@property BOOL resetLoopBeat;
@property double resetLoopTime;
@property double lastBeat;
@property NSArray* hitNodesAtTouch;
@property int streakCounter;
@property SKLabelNode *streakDisplay;

@end
