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
    _currentScore = 0;
    _targetScore = [[_loopData getBeatMap] count]*2;
    _lastBeat = -1; // this signals we don't know what last beat is.
    _reachedGoal = NO;
    
    [_conductor addObserver:self forKeyPath:@"currentBeat" options:0 context:nil];
    
    //    self.view.frameInterval = 2;
    
    [self addPlayhead];
    [self initStreakDisplay];
//    [self addBackButton];
    [self addInteractor];
}

-(void) addPlayhead
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGRect rect = CGRectMake(0, 0, screenWidth, 3);
    SKShapeNode *playHead = [SKShapeNode shapeNodeWithRect:rect];
    playHead.position = CGPointMake(0, screenHeight/5 + 40); // 40 is ball height
    playHead.name = @"playhead";
    playHead.strokeColor = playHead.fillColor = [_graphics getInteractorOnColor];
    playHead.glowWidth = 2;
    playHead.zPosition = -1;
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

- (void)addInteractor {
    self.interactor = [[MinigameInteractor alloc] initWithTexture:[_graphics getTextureForInteractor:[_loopData getLoopName]]];
    
    _interactor.graphics = _graphics;
    [_interactor setUpInteractor];
    
    _interactor.position = CGPointMake(self.size.width/2, self.size.height*0.75);
    _interactor.zPosition = -2;
    _interactor.name = [_loopData getLoopName];
    _interactor.color = [_graphics getInteractorOnColor];
    
    [_interactor connectToConductor:_conductor];
    
    [self addChild:_interactor];
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
    SKNode *tappedNode = [self nodeAtPoint:location];
    
    if ([tappedNode.name isEqualToString:[_loopData getLoopName]]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnToGameScene" object:self userInfo:@{@"reachedGoal":[NSNumber numberWithBool:_reachedGoal]}];
    } else {
        CGFloat errorAllowed = 40;
        SKNode *playhead = [self childNodeWithName:@"playhead"];
        for (SKShapeNode *node in [self children]){
            if([node.name isEqualToString:@"droppedBall"] && ![node.fillColor isEqual:[_graphics getInteractorOffColor]]){
                if(node.position.y<playhead.position.y + errorAllowed && node.position.y > playhead.position.y - errorAllowed &&
                   location.y < playhead.position.y + errorAllowed && location.y > playhead.position.y - errorAllowed &&
                   node.position.x<location.x + errorAllowed && node.position.x > location.x - errorAllowed){
                    _streakCounter ++;
//                    [node setFillColor:[UIColor greenColor]];
//                    [node setStrokeColor:[UIColor greenColor]];
                    [node runAction:[SKAction scaleTo:5 duration:0.5]];
                    [node runAction:[SKAction fadeAlphaTo:0 duration:0.5]];
                    [self updateStreakCounterDisplay];
                    if (!_reachedGoal) _currentScore++;
                    
                    if (_currentScore < _targetScore) {
                        [_interactor setPercentFull:_currentScore/_targetScore];
                    } else if (_currentScore == _targetScore){
                        _reachedGoal = YES;
                        [_interactor setPercentFull:1];
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
    SKShapeNode *circle = [SKShapeNode shapeNodeWithCircleOfRadius:18];
    CGFloat initialPositionY = screenHeight + circle.frame.size.height/2;
    CGFloat midPositionY = screenHeight/5 + 40;
    CGFloat underPositionY = midPositionY - 10;
    circle.fillColor = [SKColor whiteColor];
    circle.strokeColor = [SKColor whiteColor];
    circle.glowWidth = 3;
    
    [circle setPosition:CGPointMake(column * screenWidth/numVoices + (screenWidth/numVoices)/2, initialPositionY)];
    [self addChild:circle];
    circle.name = @"droppedBall";
    circle.zPosition = -1;
    SKAction *dropBall = [SKAction moveToY:midPositionY duration:animationDuration];
    [circle runAction:dropBall completion:^(void){
        [circle runAction:[SKAction moveToY:underPositionY duration:(animationDuration/midPositionY)*(midPositionY-underPositionY)] completion:^{
            if(circle.xScale == 1){
                [circle setFillColor:[_graphics getInteractorOffColor]];
                [circle setStrokeColor:[_graphics getInteractorOffColor]];
                _streakCounter = 0;
                [self updateStreakCounterDisplay];
                
                if (!_reachedGoal) {
                    _currentScore -= 2;
                    if (_currentScore < 0) _currentScore = 0;
                    [_interactor setPercentFull:_currentScore/_targetScore];
                }
            }
        }];
        
        CGFloat animateOutDuration = circle.position.y/(initialPositionY - midPositionY) * animationDuration;
        [circle runAction:[SKAction moveToY:0 duration:animateOutDuration] completion:^(void){
            [self removeChildrenInArray:@[circle]];
        }];
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
    
    [_interactor updateAppearance];
}

@end
