//
//  SongSliderScene.h
//  protogame191
//
//  Created by Ben McK on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "LoopData.h"
#import "Conductor.h"

@interface SongSliderScene : SKScene

- (instancetype)initWithLoopData:(LoopData *)data conductor:(Conductor *)conductor size:(CGSize)size;

@property Conductor *conductor;
@property LoopData *loopData;
@property double nextBeat;
@property BOOL resetLoopBeat;
@property double resetLoopTime;
@property double lastBeat;
@property UISlider *slider;
@property int streakCounter;
@property SKLabelNode *streakDisplay;

- (void)displayDirections;


@end
