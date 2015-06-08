//
//  SongTapScene.m
//  protogame191
//
//  Created by Ben McK on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SongTapScene.h"

@implementation SongTapScene

- (instancetype)initWithLoopData:(LoopData *)data graphics:(GraphicsController *)graphics conductor:(Conductor *)conductor size:(CGSize)size {
    self = [super initWithSize:size];
    if (self) {
        self.loopData = data;
        self.conductor = conductor;
        self.graphics = graphics;
    }
    
    return self;
}

- (void) didMoveToView:(SKView *)view
{
    /* Setup your scene here */
    self.backgroundColor = [_graphics getBackgroundColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    _nextBeat = [self getNearestHigherBeat];
    _resetLoopTime = 0;
    _resetLoopBeat = NO;
    _streakCounter = 0;
    _lastBeat = -1; // this signals we don't know what last beat is.
    _reachedGoal = NO;
    
    [_conductor addObserver:self forKeyPath:@"currentBeat" options:0 context:nil];
    
    //    self.view.frameInterval = 2;
    
    [self addPlayhead];
    [self initStreakDisplay];
    [self addBackButton];
}

-(void) addPlayhead
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = CGRectMake(0, 0, screenWidth, 3);
    SKShapeNode *playHead = [SKShapeNode shapeNodeWithRect:rect];
    playHead.position = CGPointMake(0, screenHeight/5 + 40); // 40 is ball height
    playHead.name = @"playhead";
    playHead.strokeColor = playHead.fillColor = [UIColor greenColor];
    [self addChild:playHead];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnToGameScene" object:self userInfo:@{@"reachedGoal":[NSNumber numberWithBool:_reachedGoal]}];
    } else {
        CGFloat errorAllowed = 25;
        SKNode *playhead = [self childNodeWithName:@"playhead"];
        for (SKShapeNode *node in [self children]){
            if([node.name isEqualToString:@"droppedBall"]){
                if(node.position.y<playhead.position.y + errorAllowed && node.position.y > playhead.position.y - errorAllowed &&
                   location.y < playhead.position.y + errorAllowed && location.y > playhead.position.y - errorAllowed &&
                   node.position.x<location.x + errorAllowed && node.position.x > location.x - errorAllowed){
                    _streakCounter ++;
                    [node setFillColor:[UIColor greenColor]];
                    [self updateStreakCounterDisplay];
                    if(_streakCounter == 1){
                        _reachedGoal = YES;
                        [self flashColoredScreen:[UIColor greenColor]];
                        _streakDisplay.color = [UIColor greenColor];
                        _streakDisplay.colorBlendFactor = .8;
                    }
                }
            }
        }
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
    CGFloat initialPositionY = screenHeight + circle.frame.size.height/2;
    CGFloat midPositionY = screenHeight/5 + circle.frame.size.height/2;
    circle.fillColor = [SKColor purpleColor];
    [circle setPosition:CGPointMake(column * screenWidth/numVoices + (screenWidth/numVoices)/2, initialPositionY)];
    [self addChild:circle];
    circle.name = @"droppedBall";
    circle.zPosition = -1;
    SKAction *dropBall = [SKAction moveToY:midPositionY duration:animationDuration];
    [circle runAction:dropBall completion:^(void){
        if(![circle.fillColor isEqual:[UIColor greenColor]]){
            _streakCounter = 0;
            [circle setFillColor:[UIColor redColor]];
            [self flashColoredScreen:[UIColor redColor]];
            [self updateStreakCounterDisplay];
        }
        CGFloat animateOutDuration = circle.position.y/(initialPositionY - midPositionY) * animationDuration;
        [circle runAction:[SKAction moveToY:0 duration:animateOutDuration] completion:^(void){
            [self removeChildrenInArray:@[circle]];
        }];
    }];
}

- (void)flashColoredScreen:(UIColor *)colorToFlash
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGRect rect = CGRectMake(0, 0, screenWidth, screenHeight);
    SKShapeNode *coloredCover = [SKShapeNode shapeNodeWithRect:rect];
    coloredCover.fillColor = colorToFlash;
    coloredCover.userInteractionEnabled = NO;
    [self addChild:coloredCover];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:.4];
    [coloredCover runAction:fadeOut completion:^(void){
        [self removeChildrenInArray:@[coloredCover]];
    }];
}

- (void)updateStreakCounterDisplay
{
    _streakDisplay.text = [NSString stringWithFormat:@"%i", _streakCounter];
}


- (void)displayDirections
{
    // TODO FOR HENRY - CHANGE FILENAME ON NEXT LINE TO BE APPROPRIATE
    SKSpriteNode *directions = [SKSpriteNode spriteNodeWithImageNamed:@"train2"];
    directions.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    directions.userInteractionEnabled = NO;
    directions.name = @"directions";
    directions.userInteractionEnabled = NO;
    [self addChild:directions];
    [self performSelector:@selector(fadeOutDirections) withObject:nil afterDelay:4];   // ADJUST DELAY TO BE APPROPRIATE
    
}
- (void)fadeOutDirections
{
    SKSpriteNode *directions = (SKSpriteNode *)[self childNodeWithName:@"directions"];
    SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:1.5];
    [directions runAction:fadeOut completion:^(void){
        [self removeChildrenInArray:@[directions]];
    }];
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
