//
//  SongSliderScene.m
//  protogame191
//
//  Created by Ben McK on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SongSliderScene.h"

@implementation SongSliderScene

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
    /* Setup your scene here */
    self.backgroundColor = [SKColor colorWithRed:10.0/255 green:55.0/255 blue:70.0/255 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    _nextBeat = [self getNearestHigherBeat];
    _resetLoopTime = 0;
    _resetLoopBeat = NO;
    _streakCounter = 0;
    _lastBeat = -1; // this signals we don't know what last beat is.
    
    [_conductor addObserver:self forKeyPath:@"currentBeat" options:0 context:nil];
    
//    self.view.frameInterval = 2;
    
    [self addSlider:view];
    [self addBallCover];
    [self initStreakDisplay];
    [self addBackButton];
}

-(void) addSlider:(SKView *)view
{
    float screenWidth = [UIScreen mainScreen].bounds.size.width;
    float screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect frame = CGRectMake(0, screenHeight * 3/4, screenWidth, 60);
    _slider = [[UISlider alloc] initWithFrame:frame];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.minimumValue = 0.0;
    _slider.maximumValue = 100.0;
    UIImage *sliderThumb = [UIImage imageNamed: @"Triangle_9"];
    UIImage *sliderThumbScaled = [UIImage imageWithCGImage:sliderThumb.CGImage scale:2 orientation:UIImageOrientationUp];
    [[UISlider appearance] setThumbImage:sliderThumbScaled forState:UIControlStateNormal];
    [[UISlider appearance] setMaximumTrackTintColor:[UIColor colorWithWhite:1 alpha:0]];
    [[UISlider appearance] setMinimumTrackTintColor:[UIColor colorWithWhite:1 alpha:0]];
    _slider.continuous = YES;
    [view addSubview:_slider];
}
     
-(void) addBallCover
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = CGRectMake(0, 0, screenWidth, (screenHeight -_slider.frame.origin.y));
    SKShapeNode *ballCover = [SKShapeNode shapeNodeWithRect:rect];
    ballCover.strokeColor = ballCover.fillColor = self.backgroundColor;
    [self addChild:ballCover];
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

-(void)initStreakDisplay{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    _streakDisplay = [SKLabelNode labelNodeWithText:[NSString stringWithFormat:@"%i", _streakCounter]];
    _streakDisplay.fontSize = 18;
    _streakDisplay.fontColor = [UIColor whiteColor];
    _streakDisplay.fontName = @"Avenir-Medium";
    [_streakDisplay setPosition: CGPointMake(screenWidth - 25, screenHeight - 60)];
    _streakDisplay.alpha = .6;
    _streakDisplay.userInteractionEnabled = NO;
    [self addChild:_streakDisplay];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
    if ([node.name isEqualToString:@"backButton"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnToGameScene" object:self userInfo:nil];
        [_slider removeFromSuperview];
    }
}

- (double)getFirstBeat
{
    NSDictionary *beatMap = [_loopData getBeatMap];
    NSArray *sortedKeys = [self sortedBeats:beatMap];
    return ((NSNumber *)sortedKeys[0]).doubleValue;
}

- (double)getNearestHigherBeat
{
    NSDictionary *beatMap = [_loopData getBeatMap];
    NSArray *sortedKeys = [self sortedBeats:beatMap];
    double currBeat = [_conductor getCurrentBeatForLoop:[_loopData getLoopName]];
    for(int i = 0; i < beatMap.count; i ++){
        if(((NSNumber *)sortedKeys[i]).doubleValue > currBeat)
            return ((NSNumber *)sortedKeys[i]).doubleValue;
    }
    return ((NSNumber *)sortedKeys[0]).doubleValue;
}
- (NSArray *)sortedBeats:(NSDictionary *)beatMap
{
    NSArray *sortedKeys = [[beatMap allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = obj1;
        NSNumber *num2 = obj2;
        if ( num1.doubleValue < num2.doubleValue ) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedDescending;
    }];
    return sortedKeys;
}

- (double)getNextBeat:(NSDictionary *)beatMap
{
    NSArray *sortedKeys = [[beatMap allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *num1 = obj1;
        NSNumber *num2 = obj2;
        if ( num1.doubleValue < num2.doubleValue ) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedDescending;
    }];
    // check if user has hit the beat yet if not, turn on filter/fire mistakes
    int indexOfNextKey = (int)[sortedKeys indexOfObject:[NSNumber numberWithDouble:_nextBeat]] + 1;
    if(indexOfNextKey >= sortedKeys.count){
        indexOfNextKey = 0;
        _resetLoopTime = CACurrentMediaTime();
        _lastBeat = _nextBeat;
        _resetLoopBeat = YES;
    }
    return ((NSNumber *)sortedKeys[indexOfNextKey]).doubleValue;
}

- (void)dropBall:(NSNumber *)voiceNumber duration:(double)animationDuration
{
    int noteNumber = [voiceNumber intValue] + 1;
    int numVoices = [_loopData getNumVoices];
    int column = numVoices - noteNumber;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:20];
    circle.fillColor = [SKColor greenColor];
    [circle setPosition:CGPointMake(column * screenWidth/numVoices + (screenWidth/numVoices)/2, screenHeight + circle.frame.size.height/2)];
    [self addChild:circle];
    circle.zPosition = -1;
    SKAction *dropBall = [SKAction moveToY:screenHeight/5 + circle.frame.size.height/2 duration:animationDuration];
    [circle runAction:dropBall completion:^(void){
        if(_slider.value >= _slider.maximumValue * (column/(double)numVoices) && _slider.value <= _slider.maximumValue * (column+1)/(double)numVoices){
            _streakCounter ++;
        } else {
            _streakCounter = 0;
            [self flashRedScreen];
        }
        [self updateStreakCounterDisplay];
        [self removeChildrenInArray:@[circle]];
    }];
}

- (void)flashRedScreen
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGRect rect = CGRectMake(0, 0, screenWidth, screenHeight);
    SKShapeNode *redCover = [SKShapeNode shapeNodeWithRect:rect];
    redCover.fillColor = [SKColor redColor];
    redCover.userInteractionEnabled = NO;
    [self addChild:redCover];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:.4];
    [redCover runAction:fadeOut completion:^(void){
        [self removeChildrenInArray:@[redCover]];
    }];
}

- (void)updateStreakCounterDisplay
{
    _streakDisplay.text = [NSString stringWithFormat:@"%i", _streakCounter];
}

- (void)update:(NSTimeInterval)currentTime {
    double currTime = [_conductor getCurrentBeatForLoop:[_loopData getLoopName]];
    double preBeat = 2;
    double firingTime = currTime + preBeat;
    double animationDuration = preBeat * 60/[_loopData getBPM];
    if(firingTime > [_loopData getNumBeats]){ // now it oscilates from 0 to 16
        firingTime -= [_loopData getNumBeats];
    }
    if(firingTime > _nextBeat && (!_resetLoopBeat ||
                                  (_resetLoopBeat && (_resetLoopTime && (CACurrentMediaTime() - _resetLoopTime > [_loopData getNumBeats]-_lastBeat-preBeat)) && firingTime < .5 + [self getFirstBeat]))){
        //            double timeWindow = CACurrentMediaTime() - _resetLoopTime;
        _resetLoopBeat = NO;
        NSDictionary *beatMap = [_loopData getBeatMap];
        NSArray *beatsToFire = [beatMap objectForKey:[NSNumber numberWithDouble:_nextBeat]];
        for(NSNumber *voiceNumber in beatsToFire){
            [self dropBall:voiceNumber duration:animationDuration];
        }
        _nextBeat = [self getNextBeat:beatMap];// update next beat by iterating through keys
    }
}

@end
