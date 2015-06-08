//
//  MinigameInteractor.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "MinigameInteractor.h"
#import "UIColor+CrossFade.h"

@interface MinigameInteractor ()

@property(nonatomic) Conductor *conductor;
@property BOOL state;
@property BOOL ready;
@property BOOL unlocked;

@property double percent;

@property(nonatomic) SKShapeNode *outerRing;
@property(nonatomic) SKShapeNode *completionRing;

@end


@implementation MinigameInteractor

- (void)connectToConductor:(Conductor *)conductor {
    self.conductor = conductor;
}

- (void)setUpInteractor
{
    self.outerRing = [SKShapeNode shapeNodeWithCircleOfRadius:self.size.width/2];
    _outerRing.fillColor = [SKColor whiteColor];
    _outerRing.strokeColor = [SKColor whiteColor];
    _outerRing.glowWidth = 5;
    _outerRing.zPosition = -1;
    [self addChild:_outerRing];
    
    self.color = [_graphics getInteractorOffColor];
    self.colorBlendFactor = 1.0;
    
    _percent = 0;
    _outerRing.alpha = 0;
    
    
    
//    _completionRing = [SKShapeNode shapeNodeWithPath:<#(CGPathRef)#>]
}

- (void)updateAppearance {
    double powerLevel = [_conductor getPowerLevelForLoop:self.name];
    [self runAction:[SKAction scaleTo:(1 + (powerLevel * 0.8)*_percent)*2 duration:0.07]];
}

- (void)setPercentFull:(double)percent {
    _percent = percent;
    UIColor *onColor = [_graphics getInteractorOnColor];
    UIColor *offColor = [_graphics getInteractorOffColor];
    UIColor *crossfade = [UIColor colorForFadeBetweenFirstColor:offColor secondColor:onColor atRatio:_percent];
    
    self.color = crossfade;
    
    if (percent == 1) {
        [_outerRing runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
    }
}

@end
