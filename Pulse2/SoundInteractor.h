//
//  SoundInteractor.h
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <TheAmazingAudioEngine/TheAmazingAudioEngine.h>
#import "Conductor.h"
#import "GraphicsController.h"

@interface SoundInteractor : SKSpriteNode

- (void)resetValues;
// set SoundFilePlayer object
- (void)connectToConductor:(Conductor *)conductor;
// fade in and grow interactor
- (void)appearWithGrowAnimation;
// returns true if appear animation has completed
- (BOOL)isReady;
// get on/off state
- (BOOL)getState;
// get unlockedState
- (BOOL)isUnlocked;

// change lockState and relevant appearance
- (void)unlockNode;
- (void)lockNode;

// turn on with volume and color fade in
- (void)turnOn;
// turn on without fades
- (void)turnOnSimple;
// turn off with volume and color fade out
- (void)turnOff;
// update size of interactor according to current sound amplitude
- (void)updateAppearance;

- (void)setUpInteractor;

@property GraphicsController *graphics;

@end
