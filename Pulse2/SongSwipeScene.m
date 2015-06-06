//
//  SongSwipeScene.m
//  protogame191
//
//  Created by Ben McK on 5/5/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SongSwipeScene.h"

@implementation SongSwipeScene

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
    _hitNodesAtTouch = @[];
    _lastBeat = -1; // this signals we don't know what last beat is.
    
    
    [_conductor addObserver:self forKeyPath:@"currentBeat" options:0 context:nil];
    self.view.frameInterval = 2;
    
    // add nodes
    [self initStreakDisplay];
    [self addSwipeZone];
    [self addHitZone];
    [self addSwipeRecognizers];
    [self addBackButton];
}

-(void)initStreakDisplay
{
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

- (void)addSwipeZone
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    SKSpriteNode *swipeZone = [SKSpriteNode spriteNodeWithColor:[UIColor purpleColor] size:CGSizeMake(screenWidth,screenHeight/3)];
    swipeZone.alpha = .4;
    swipeZone.position = CGPointMake(swipeZone.size.width/2, swipeZone.size.height/2);
    swipeZone.name = @"swipeZone";//how the node is identified later
    [self addChild:swipeZone];
}

- (void)addHitZone
{
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    SKSpriteNode *hitZone = [SKSpriteNode spriteNodeWithColor:[UIColor blueColor] size:CGSizeMake(screenWidth,80)];
    hitZone.alpha = .4;
    hitZone.position = CGPointMake(screenWidth/2, screenHeight/3 + hitZone.size.height/2);
    hitZone.name = @"hitZone";//how the node is identified later
    [self addChild:hitZone];
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

- (void)addSwipeRecognizers
{
    UISwipeGestureRecognizer *leftSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *upSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *rightSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    UISwipeGestureRecognizer *downSwipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    leftSwipeRecognizer.delegate = self;
    upSwipeRecognizer.delegate = self;
    rightSwipeRecognizer.delegate = self;
    downSwipeRecognizer.delegate = self;
    
    leftSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    upSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    rightSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    downSwipeRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    
    [self.view addGestureRecognizer:leftSwipeRecognizer];
    [self.view addGestureRecognizer:upSwipeRecognizer];
    [self.view addGestureRecognizer:rightSwipeRecognizer];
    [self.view addGestureRecognizer:downSwipeRecognizer];
}

- (void)displayDirections
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Swipe Time"
                                                    message:@"Swipe to the rhythm of this loop. 20 successful swipes in a row will unlock this loop!"
                                                   delegate:nil
                                          cancelButtonTitle:@"Okie-dokie"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - GUESTURES

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)handleSwipe:(UISwipeGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateBegan || sender.state == UIGestureRecognizerStateEnded || sender.state == UIGestureRecognizerStateCancelled)
    {
        CGPoint touchLocation = [sender locationInView:sender.view];
        touchLocation = [self convertPointFromView:touchLocation];
        SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:touchLocation];
        if([touchedNode.name isEqualToString:@"swipeZone"]){
            SKSpriteNode *hitZone = (SKSpriteNode *)[self childNodeWithName:@"hitZone"];
            NSArray *arrowNodes = [self nodesAtPoint:hitZone.position];
            if(sender.direction == UISwipeGestureRecognizerDirectionDown){
                [self clearNodes:arrowNodes forSwipeDirection:@"down"];
            } else if(sender.direction == UISwipeGestureRecognizerDirectionLeft){
                [self clearNodes:arrowNodes forSwipeDirection:@"left"];
            } else if(sender.direction == UISwipeGestureRecognizerDirectionUp){
                [self clearNodes:arrowNodes forSwipeDirection:@"up"];
            } else if(sender.direction == UISwipeGestureRecognizerDirectionRight){
                [self clearNodes:arrowNodes forSwipeDirection:@"right"];
            }
        }
    }
}

- (void)clearNodes:(NSArray *)arrowNodes forSwipeDirection:(NSString *)direction
{
    for(SKNode *node in arrowNodes){
        if([node.name isEqualToString:direction] && node.position.y < self.view.frame.size.height/2){
            [node removeAllActions];
            [self removeChildrenInArray:@[node]];
            _streakCounter++;
            [self updateStreakCounterDisplay];
            if (_streakCounter == 20){
                [self flashColoredScreen:[UIColor greenColor]];
                _streakDisplay.colorBlendFactor = .8;
                _streakDisplay.color = [UIColor greenColor];
            }
        }
    }
    for(SKNode *node in _hitNodesAtTouch){
        if([node.name isEqualToString:direction] && ![arrowNodes containsObject:node]){
            [node removeAllActions];
            [self removeChildrenInArray:@[node]];
            _streakCounter++;
            [self updateStreakCounterDisplay];
            if (_streakCounter == 20){
                [self flashColoredScreen:[UIColor greenColor]];
                _streakDisplay.colorBlendFactor = .8;
                _streakDisplay.color = [UIColor greenColor];
            }
        }
    }
    _hitNodesAtTouch = @[];
    NSLog(@"Swiped %@", direction);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKSpriteNode *touchedNode = (SKSpriteNode *)[self nodeAtPoint:location];
    
    if([touchedNode.name isEqualToString:@"swipeZone"]){
        SKSpriteNode *hitZone = (SKSpriteNode *)[self childNodeWithName:@"hitZone"];
        _hitNodesAtTouch = [self nodesAtPoint:hitZone.position];
    } else if ([touchedNode.name isEqualToString:@"backButton"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnToGameScene" object:self userInfo:nil];
    }
}


#pragma mark - GAME PLAY

- (void)dropArrow:(NSNumber *)voiceNumber duration:(double)animationDuration
{
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    SKSpriteNode *arrow = [SKSpriteNode spriteNodeWithImageNamed:@"arrow"];
    [arrow setScale: .15];
    [arrow setPosition:CGPointMake(screenWidth/2, screenHeight + arrow.frame.size.height/2)];
    [self randomlyRotate:arrow];
    [self addChild:arrow];
    arrow.zPosition = -1;
    SKAction *dropArrow = [SKAction moveToY:screenHeight/3 + arrow.frame.size.height/2 duration:animationDuration];
    [arrow runAction:dropArrow completion:^(void){
        CGFloat duration = animationDuration * (screenHeight/3 - screenHeight/4) / (screenHeight - screenHeight/3);
        SKAction *dropArrow2 = [SKAction moveToY:screenHeight/4 + arrow.frame.size.height/2 duration:duration];
        [arrow runAction:dropArrow2 completion:^(void){
            _streakCounter = 0;
            [self flashColoredScreen:[UIColor redColor]];
            [self updateStreakCounterDisplay];
            [self removeChildrenInArray:@[arrow]];
        }];
    }];
}

- (void)randomlyRotate:(SKSpriteNode *)nodeToRotate
{
    float randomNum = ((float)rand() / RAND_MAX)*3.99;
    int randomNumber = (int)randomNum;
    switch (randomNumber){
        case 0:
            [nodeToRotate setName:@"up"];
            break;
        case 1:
            [nodeToRotate setName:@"left"];
            [nodeToRotate setZRotation:(M_PI/2)];
            break;
        case 2:
            [nodeToRotate setName:@"down"];
            [nodeToRotate setZRotation:(M_PI)];
            break;
        case 3:
            [nodeToRotate setName:@"right"];
            [nodeToRotate setZRotation:(3*M_PI/2)];
            break;
        default:
            break;
    }
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

- (double)getNextBeat:(NSDictionary *)beatMap
{
    NSArray *sortedKeys = [self sortedBeats:beatMap];
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

- (void)update:(NSTimeInterval)currentTime{
    double currTime = [_conductor getCurrentBeatForLoop:[_loopData getLoopName]];
    double preBeat = 2;
    double firingTime = currTime + preBeat;
    double animationDuration = preBeat * 60/[_loopData getBPM];
    if(firingTime > [_loopData getNumBeats]){ // now it oscilates from 0 to 16
        firingTime -= [_loopData getNumBeats];
    }
    if(firingTime > _nextBeat && (!_resetLoopBeat ||
                                  (_resetLoopBeat && (_resetLoopTime && (CACurrentMediaTime() - _resetLoopTime > [_loopData getNumBeats]-_lastBeat-preBeat)) && firingTime < .5 + [self getFirstBeat]))){
        _resetLoopBeat = NO;
        NSDictionary *beatMap = [_loopData getBeatMap];
        NSArray *beatsToFire = [beatMap objectForKey:[NSNumber numberWithDouble:_nextBeat]];
        for(NSNumber *voiceNumber in beatsToFire){
            [self dropArrow:voiceNumber duration:animationDuration];
        }
        _nextBeat = [self getNextBeat:beatMap];// update next beat by iterating through keys
    }
}

@end
