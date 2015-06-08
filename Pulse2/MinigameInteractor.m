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
    _outerRing.glowWidth = 4;
    _outerRing.zPosition = -1;
    _outerRing.antialiased = YES;
    [self addChild:_outerRing];
    
    self.completionRing = [SKShapeNode shapeNodeWithPath:[self getRingPath]];
    _completionRing.fillColor = [SKColor clearColor];
    _completionRing.strokeColor = [SKColor whiteColor];
    _completionRing.lineWidth = 2;
    _completionRing.glowWidth = 1;
    _completionRing.alpha = 0.6;
    _completionRing.antialiased = YES;
    _completionRing.zPosition = -1;
    [self addChild:_completionRing];
    
    self.color = [_graphics getInteractorOffColor];
    self.colorBlendFactor = 1.0;
    
    _percent = 0;
    _outerRing.alpha = 0;
    
//    _completionRing.path = [self getRingPath];
}

- (CGPathRef)getRingPath {
    CGFloat arcRadius = 33;
    CGPoint arcCenter = CGPointMake(0, 0);
    CGFloat startAngle = M_PI/2;
    CGFloat endAngle = M_PI/2 + (2*M_PI*_percent);
    
    UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
    
    return bezier.CGPath;
}

- (void)animateRingFromPercent:(double)percentStart toPercent:(double)percentEnd {
    if (percentStart == percentEnd) return;
    if (percentEnd == 0) percentEnd = 0.0001;
    
    double time = fabs(percentStart - percentEnd)*2;
    SKAction *action = [SKAction customActionWithDuration:time actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double f = elapsedTime/time;
        double p = percentStart*(1-f) + percentEnd*f;
        
        CGFloat arcRadius = 33;
        CGPoint arcCenter = CGPointMake(0, 0);
        CGFloat startAngle = M_PI/2;
        CGFloat endAngle = M_PI/2 + (2*M_PI*p);
        
        UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:arcCenter radius:arcRadius startAngle:startAngle endAngle:endAngle clockwise:YES];
        _completionRing.path = bezier.CGPath;
    }];
    [self runAction:action];
}

- (void)updateAppearance {
    double powerLevel = [_conductor getPowerLevelForLoop:self.name];
    [self runAction:[SKAction scaleTo:(1 + (powerLevel * 0.8)*_percent)*2 duration:0.07]];
}

- (double)getScale {
    double powerLevel = [_conductor getPowerLevelForLoop:self.name];
    return 1 + powerLevel;
}

- (void)setPercentFull:(double)percent {
    UIColor *onColor = [_graphics getInteractorOnColor];
    UIColor *offColor = [_graphics getInteractorOffColor];
    UIColor *crossfade = [UIColor colorForFadeBetweenFirstColor:offColor secondColor:onColor atRatio:percent];
    
    [self animateRingFromPercent:_percent toPercent:percent];
    
    self.color = crossfade;
    
    if (percent == 1) {
        [_outerRing runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
    }
    
    _percent = percent;
}

@end
