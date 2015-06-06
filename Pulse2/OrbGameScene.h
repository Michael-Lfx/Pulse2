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

@end
