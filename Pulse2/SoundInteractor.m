//
//  SoundInteractor.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundInteractor.h"

@interface SoundInteractor ()

@property(nonatomic) LoopManager *loopManager;
@property BOOL state;
@property BOOL ready;
@property double averagedAmplitude;

@property(nonatomic) SKAction *volumeUpAction;
@property(nonatomic) SKAction *volumeDownAction;

@end


@implementation SoundInteractor

// shape and color values
double beginningStrokeGray = 0.05;
double endingStrokeGray = 0.6;
double grayScaleValueOff = 0.2;
double grayScaleValueOn = 1.0;
double alphaValue = 0.4;

// animation timings
double volumeFadeTime = 1.0;
double appearAnimationTime = 2.5;
double ringFadeInTime = 0.2;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.lineWidth = 3;
        self.blendMode = SKBlendModeAdd;
        self.glowWidth = 5;
    }
    
    return self;
}

- (void)resetValues {
    self.state = NO;
    self.ready = NO;
    self.averagedAmplitude = 0.0;
    
    self.xScale = 0;
    self.yScale = 0;
    
    self.alpha = 0;
    self.fillColor = [SKColor colorWithWhite:grayScaleValueOff alpha:1.0];
    self.strokeColor = [SKColor colorWithWhite:beginningStrokeGray alpha:1.0];
}

- (void)connectToLoopManager:(LoopManager *)loopManager {
    self.loopManager = loopManager;
    
    self.volumeUpAction = [SKAction customActionWithDuration:volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / volumeFadeTime);
        double beginValue = 1 - targetValue;
        
        double grayValue = beginValue * grayScaleValueOff + targetValue * grayScaleValueOn;
        self.fillColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        
        loopManager.looper.volume = targetValue;
    }];
    
    self.volumeDownAction = [SKAction customActionWithDuration:volumeFadeTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
        double targetValue = (elapsedTime / volumeFadeTime);
        double beginValue = 1 - targetValue;
        
        double grayValue = beginValue * grayScaleValueOn + targetValue * grayScaleValueOff;
        self.fillColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        
        loopManager.looper.volume = beginValue;
    }];
}

- (void)appearWithGrowAnimation {
    [self runAction:[SKAction scaleTo:1.0 duration:appearAnimationTime] completion:^{
        _ready = YES;
    }];
    
    // fade alpha in, then fade outer ring in
    [self runAction:[SKAction fadeAlphaTo:alphaValue duration:appearAnimationTime - ringFadeInTime] completion:^{
        [self runAction:[SKAction customActionWithDuration:ringFadeInTime actionBlock:^(SKNode *node, CGFloat elapsedTime) {
            double grayValue = beginningStrokeGray * ((ringFadeInTime - elapsedTime) / ringFadeInTime) + endingStrokeGray * (elapsedTime / ringFadeInTime);
            self.strokeColor = [SKColor colorWithWhite:grayValue alpha:1.0];
        }]];
    }];
}

- (BOOL)isReady {
    return _ready;
}

- (BOOL)getState {
    return _state;
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

- (void)updateAppearance {
    self.xScale = 1 + [_loopManager getCurrentAmplitude] / 50.0;
    self.yScale = 1 + [_loopManager getCurrentAmplitude] / 50.0;
}

@end
