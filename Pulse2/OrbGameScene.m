//
//  SongTrainScene.m
//  protogame191
//
//  Created by Ben McK on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "OrbGameScene.h"

@implementation OrbGameScene

#pragma mark - INITIALIZATION

- (instancetype)initWithLoopData:(LoopData *)data conductor:(Conductor *)conductor size:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.loopData = data;
        self.conductor = conductor;
    }
    
    return self;
}

- (void) didMoveToView:(SKView *)view
{
    // setup scene
    self.backgroundColor = [SKColor colorWithRed:10.0/255 green:55.0/255 blue:70.0/255 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    // setup global variables
    _nextBeat = [self getNearestHigherBeat];
    _resetLoopTime = 0;
    _resetLoopBeat = NO;
    _streakCounter = 0;
    _lastBeat = -1; // this signals we don't know what last beat is.
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    _leftTrackCenter = screenWidth/3;
    _rightTrackCenter = screenWidth*2/3;
    
    
    [_conductor addObserver:self forKeyPath:@"currentBeat" options:0 context:nil];
    self.view.frameInterval = 2;
    
    // add nodes
    [self addBackButton];
}

- (void)addBackButton
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    SKSpriteNode *backButton = [SKSpriteNode spriteNodeWithImageNamed:@"blurGlow2"];
    backButton.position = CGPointMake(screenWidth/2, screenHeight);
    backButton.name = @"backButton";//how the node is identified later
    backButton.color = [SKColor greenColor];
    backButton.colorBlendFactor = .9;
    [self addChild:backButton];
}

- (void)update:(NSTimeInterval)currentTime {
    double currTime = [_conductor getCurrentBeatForLoop:[_loopData getLoopName]];
    double preBeat = 2;
    double firingTime = currTime + preBeat;
    double animationDuration = preBeat * 60/[_loopData getBPM];
    if(firingTime > [_loopData getNumBeats]){ // now it oscilates from 0 to 16
        firingTime -= [_loopData getNumBeats];
    }
    if(firingTime > _nextBeat && (!_resetLoopBeat || (_resetLoopBeat && firingTime < .5 + [self getFirstBeat]
                                                      && (_resetLoopTime && (CACurrentMediaTime() - _resetLoopTime > [_loopData getNumBeats]-_lastBeat-preBeat))))){
        _resetLoopBeat = NO;
        NSDictionary *beatMap = [_loopData getBeatMap];
        NSArray *beatsToFire = [beatMap objectForKey:[NSNumber numberWithDouble:_nextBeat]];
        double beatAfter = [self getNextBeat:beatMap];
        for(NSNumber *voiceNumber in beatsToFire){
            float beatLength = beatAfter - _nextBeat;
            if(_resetLoopBeat)
                beatLength += [_loopData getNumBeats];
            [self drawTrack:voiceNumber beatLength:beatLength duration:animationDuration];
        }
        _nextBeat = beatAfter;// update next beat by iterating through keys
    }
}

@end
