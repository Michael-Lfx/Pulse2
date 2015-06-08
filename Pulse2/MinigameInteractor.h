//
//  MinigameInteractor.h
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "Conductor.h"
#import "GraphicsController.h"

@interface MinigameInteractor : SKSpriteNode

// set SoundFilePlayer object
- (void)connectToConductor:(Conductor *)conductor;

// update size of interactor according to current sound amplitude
- (void)updateAppearance;

- (void)setUpInteractor;

- (void)setPercentFull:(double)percent;

@property GraphicsController *graphics;

@end
