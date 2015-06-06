//
//  GameScene.h
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SoundInteractor.h"
#import "Conductor.h"

static const uint32_t edgeCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t borderCategory = 0x1 << 4;

@interface SoundscapeScene : SKScene <UIGestureRecognizerDelegate, SKPhysicsContactDelegate>

// initialization
@property BOOL hasBeenInitialized;

// audio
//@property AEAudioController *audioController;
@property Conductor *conductor;
//@property AEAudioUnitChannel *collisionSound;
//@property NSMutableArray *soundChannels;

// interactors
@property NSMutableArray *soundInteractors;
@property SoundInteractor *draggedInteractor;
@property double baseInteractorSize;

// timers
@property int interactorCount;
@property NSTimer *interactorTimer;

// smooth animation buffers
@property NSMutableArray *averagedAmplitudes;
@property NSMutableArray *smoothedAmplitudes;

// gesture recognizers
@property UIPanGestureRecognizer *panInteractorRecognizer;
@property UITapGestureRecognizer *tapInteractorRecognizer;
@property UILongPressGestureRecognizer *longPressRecognizer;

@end
