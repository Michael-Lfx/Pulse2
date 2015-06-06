//
//  SoundInteractor.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundInteractor.h"

@interface SoundInteractor ()

@property(nonatomic) Conductor *conductor;
@property BOOL state;
@property BOOL ready;
@property BOOL unlocked;
@property double averagedAmplitude;

@property(nonatomic) SKAction *volumeUpAction;
@property(nonatomic) SKAction *volumeDownAction;

@end


@implementation SoundInteractor

// shape and color values
double _beginningStrokeGray = 0.05;
double _endingStrokeGray = 0.6;
double _grayScaleValueOff = 0.2;
double _grayScaleValueLocked = 0.5;
double _grayScaleValueOn = 1.0;
double _alphaValue = 0.4;

// animation timings
double _volumeFadeTime = 1.0;
double _appearAnimationTime = 2.5;
double _ringFadeInTime = 0.2;

- (void)resetValues {
    self.state = NO;
    self.ready = NO;
    self.unlocked = NO;
    self.averagedAmplitude = 0.0;
    
    self.xScale = 0;
    self.yScale = 0;
    
    self.alpha = 0;
}

- (void)connectToConductor:(Conductor *)conductor {
    self.conductor = conductor;
    
    self.volumeUpAction = [SKAction customActionWithDuration:_volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / _volumeFadeTime);
        [self childNodeWithName:@"onMask"].alpha = 1;
        [self childNodeWithName:@"offMask"].alpha = 0;
        
        [_conductor setVolumeForLoop:self.name withVolume:targetValue];
    }];
    
    self.volumeDownAction = [SKAction customActionWithDuration:_volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / _volumeFadeTime);
        double beginValue = 1 - targetValue;
        [self childNodeWithName:@"onMask"].alpha = 0;
        [self childNodeWithName:@"offMask"].alpha = 1;
        
        [_conductor setVolumeForLoop:self.name withVolume:beginValue];
    }];
}

- (void)appearWithGrowAnimation {
    [self runAction:[SKAction scaleTo:1.0 duration:_appearAnimationTime] completion:^{
        _ready = YES;
    }];
    
    // fade alpha in, then fade outer ring in
    [self runAction:[SKAction fadeAlphaTo:_alphaValue duration:_appearAnimationTime - _ringFadeInTime]];
}

- (BOOL)isReady {
    return _ready;
}

- (BOOL)getState {
    return _state;
}

- (BOOL)isUnlocked {
    return _unlocked;
}

- (void)unlockNode {
    if (_ready) {
        _unlocked = YES;
    }
}

- (void)turnOn {
    if (_ready) {
        [self removeActionForKey:@"VolumeDown"];
        [self runAction:_volumeUpAction withKey:@"VolumeUp"];
        _state = YES;
    }
}

- (void)turnOff {
    [self removeActionForKey:@"VolumeUp"];
    [self runAction:_volumeDownAction withKey:@"VolumeDown"];
    _state = NO;
}

- (void)setUpInteractor
{
    SKSpriteNode *lockedMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_locked"];
    lockedMask.name = @"onMask";
    lockedMask.userInteractionEnabled = NO;
    SKSpriteNode *onMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_on"];
    onMask.name = @"onMask";
    onMask.alpha = 0;
    onMask.userInteractionEnabled = NO;
    SKSpriteNode *offMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_off"];
    offMask.name = @"offMask";
    offMask.alpha = 0;
    offMask.userInteractionEnabled = NO;
    [self addChild:lockedMask];
    [self addChild:offMask];
    [self addChild:onMask];
    
    [self connectToConductor:_conductor];
}

- (void)updateAppearance {
    double powerLevel = [_conductor getPowerLevelForLoop:self.name];
    [self runAction:[SKAction scaleTo:1 + powerLevel duration:0.07]];
 }

@end
