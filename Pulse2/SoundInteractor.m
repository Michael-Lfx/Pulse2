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
//@property double averagedAmplitude;

@property(nonatomic) SKAction *volumeUpAction;
@property(nonatomic) SKAction *volumeDownAction;

@property(nonatomic) SKShapeNode *outerRing;

@end


@implementation SoundInteractor

// shape and color values
//double _beginningStrokeGray = 0.05;
//double _endingStrokeGray = 0.6;
//double _grayScaleValueOff = 0.2;
//double _grayScaleValueLocked = 0.5;
//double _grayScaleValueOn = 1.0;
//double _alphaValue = 1.0;

// animation timings
double _volumeFadeTime = 1.0;
double _appearAnimationTime = 2.5;
//double _ringFadeInTime = 0.2;

- (void)resetValues {
    self.state = NO;
    self.ready = NO;
    self.unlocked = NO;
//    self.averagedAmplitude = 0.0;
//    self.blendMode = SKBlendModeReplace;
    
    self.xScale = 0;
    self.yScale = 0;
    
    self.alpha = 0;
}

- (void)connectToConductor:(Conductor *)conductor {
    self.conductor = conductor;
    
    self.volumeUpAction = [SKAction customActionWithDuration:_volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / _volumeFadeTime);
//        [self childNodeWithName:@"onMask"].alpha = 1;
//        [self childNodeWithName:@"offMask"].alpha = 0;
//        [self childNodeWithName:@"lockedMask"].alpha = 0;
        
        [_conductor setVolumeForLoop:self.name withVolume:targetValue];
    }];
    
    self.volumeDownAction = [SKAction customActionWithDuration:_volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / _volumeFadeTime);
        double beginValue = 1 - targetValue;
//        [self childNodeWithName:@"lockedMask"].alpha = 0;
//        [self childNodeWithName:@"onMask"].alpha = 0;
//        [self childNodeWithName:@"offMask"].alpha = 1;
        
        [_conductor setVolumeForLoop:self.name withVolume:beginValue];
    }];
}

- (void)appearWithGrowAnimation {
    [self runAction:[SKAction scaleTo:1.0 duration:_appearAnimationTime] completion:^{
        _ready = YES;
    }];
    
    [self runAction:[SKAction fadeAlphaTo:1.0 duration:_appearAnimationTime]];
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
        self.color = [_graphics getInteracterOnColor];
    }
}

- (void)lockNode
{
    _unlocked = NO;
    self.texture = [SKTexture textureWithImageNamed:@"interactor_locked"];
    self.color = [_graphics getInteractorOffColor];
    [self runAction: [SKAction customActionWithDuration:_volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / _volumeFadeTime);
        double beginValue = 1 - targetValue;
//        [self childNodeWithName:@"lockedMask"].alpha = 1;
//        [self childNodeWithName:@"onMask"].alpha = 0;
//        [self childNodeWithName:@"offMask"].alpha = 0;
        
        [_conductor setVolumeForLoop:self.name withVolume:beginValue];
    }]];
}

- (void)turnOn {
    if (_ready) {
        [self removeActionForKey:@"VolumeDown"];
        [self runAction:_volumeUpAction withKey:@"VolumeUp"];
        
        [_outerRing runAction:[SKAction fadeInWithDuration:_volumeFadeTime] completion:^{
            self.texture = [_graphics getTextureForInteractor:self.name];
        }];
        
//        SKSpriteNode *tempNode = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_on"];
//        tempNode.alpha = 0;
//        tempNode.zPosition = 1;
//        [self addChild:tempNode];
//        [tempNode runAction:[SKAction fadeInWithDuration:_volumeFadeTime] completion:^{
//            self.texture = [SKTexture textureWithImageNamed:@"node_unlocked_on"];
//            [tempNode removeFromParent];
//        }];
        
        _state = YES;
    }
}

- (void)turnOnSimple {
    _state = YES;
    self.texture = [_graphics getTextureForInteractor:self.name];
    _outerRing.alpha = 1;
}

- (void)turnOff {
    [self removeActionForKey:@"VolumeUp"];
    [self runAction:_volumeDownAction withKey:@"VolumeDown"];
    
    [_outerRing runAction:[SKAction fadeOutWithDuration:_volumeFadeTime] completion:^{
        self.texture = [_graphics getTextureForInteractor:self.name];
    }];
    
//    SKSpriteNode *tempNode = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_on"];
//    tempNode.zPosition = 1;
//    [self addChild:tempNode];
//    self.texture = [SKTexture textureWithImageNamed:@"node_unlocked_off"];
//    [tempNode runAction:[SKAction fadeOutWithDuration:_volumeFadeTime] completion:^{
//        [tempNode removeFromParent];
//    }];
    
    _state = NO;
}

- (void)setUpInteractor
{
    self.outerRing = [SKShapeNode shapeNodeWithCircleOfRadius:self.size.width/2];
    _outerRing.fillColor = [SKColor whiteColor];
    _outerRing.strokeColor = [SKColor whiteColor];
    _outerRing.glowWidth = 5;
    _outerRing.alpha = 0;
    _outerRing.zPosition = -1;
    [self addChild:_outerRing];
    
    self.color = [_graphics getInteractorOffColor];
    self.colorBlendFactor = 1.0;
//    SKSpriteNode *lockedMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_locked"];
//    lockedMask.name = @"lockedMask";
//    lockedMask.userInteractionEnabled = NO;
//    SKSpriteNode *onMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_on"];
//    onMask.name = @"onMask";
//    onMask.alpha = 0;
//    onMask.userInteractionEnabled = NO;
//    SKSpriteNode *offMask = [SKSpriteNode spriteNodeWithImageNamed:@"node_unlocked_off"];
//    offMask.name = @"offMask";
//    offMask.alpha = 0;
//    offMask.userInteractionEnabled = NO;
//    [self addChild:lockedMask];
//    [self addChild:offMask];
//    [self addChild:onMask];
}

- (void)updateAppearance {
    double powerLevel = [_conductor getPowerLevelForLoop:self.name];
    [self runAction:[SKAction scaleTo:1 + (powerLevel * 0.8) duration:0.07]];
//    for (SKSpriteNode *child in [self children]) {
//        [child runAction:[SKAction scaleTo:1 + powerLevel duration:0.07]];
//    }
 }

@end
