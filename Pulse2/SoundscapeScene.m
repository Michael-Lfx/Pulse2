//
//  GameScene.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundscapeScene.h"
//#import "AppDelegate.h"
#import "LoopData.h"
#import "UIDoubleTapGestureRecognizer.h"

//@interface GameScene ()

//@end

@implementation SoundscapeScene

double interactorTimerDuration = 3.0;

- (void)didMoveToView:(SKView *)view {
    if(_hasBeenInitialized)
        return;
    
    self.backgroundColor = [_graphics getBackgroundColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    //    self.soundChannels = [NSMutableArray new];
    
    //    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //    self.audioController = delegate.audioController;
    
    //    self.conductor = [[Conductor alloc] initWithAudioController:_audioController plist:@"relaxation"];
    
    [self createSoundInteractors];
    [self addGestureRecognizers];
    [self addMenuNode];
    [self startScene];
    _hasBeenInitialized = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromGameScene:) name:@"ReturnFromGameScene" object:nil];
}

- (void)displayMessage1
{
    SKSpriteNode *message = [SKSpriteNode spriteNodeWithImageNamed:@"soundscape_message_1"];
    message.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    message.userInteractionEnabled = NO;
    message.name = @"message";
    message.userInteractionEnabled = NO;
    message.zPosition = 2;
    [self addChild:message];
    
}

- (void)displayMessage2
{
    SKSpriteNode *message = [SKSpriteNode spriteNodeWithImageNamed:@"soundscape_message_2"];
    message.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    message.userInteractionEnabled = NO;
    message.name = @"message";
    message.userInteractionEnabled = NO;
    message.zPosition = 2;
    [self addChild:message];
    
}

- (void)displayMessage3
{
    SKSpriteNode *message = [SKSpriteNode spriteNodeWithImageNamed:@"soundscape_message_3"];
    message.position = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    message.userInteractionEnabled = NO;
    message.name = @"message";
    message.userInteractionEnabled = NO;
    message.zPosition = 2;
    [self addChild:message];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ReturnFromGameScene" object:nil];
}

- (void)createSoundInteractors {
    CGFloat windowWidth = self.size.width;
    CGFloat windowHeight = self.size.height;
    
    self.baseInteractorSize = windowWidth * 0.1313;
    self.interactorCount = 0;
    
    self.soundInteractors = [[NSMutableArray alloc] init];
    
    NSArray *filenames = [_conductor getFilenames];
    
    _unlockedNodesDictName = [NSString stringWithFormat:@"%@UnlockedNodes", [_conductor getSoundscapeName]];
    if(![[NSUserDefaults standardUserDefaults] objectForKey:_unlockedNodesDictName]){
        NSMutableDictionary *unlockedDict = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:unlockedDict forKey:_unlockedNodesDictName];
    }

    NSDictionary *unlockedNodesDict = [[NSUserDefaults standardUserDefaults] objectForKey:_unlockedNodesDictName];
    
    for (NSString *filename in filenames) {
        // random position within bounds of screen
        CGFloat x = (random()/(CGFloat)RAND_MAX) * windowWidth;
        CGFloat y = (random()/(CGFloat)RAND_MAX) * windowHeight;
        if(x > windowWidth - _baseInteractorSize/2) x -= _baseInteractorSize/2;
        if(x <  _baseInteractorSize/2) x += _baseInteractorSize/2;
        if(y > windowHeight - _baseInteractorSize/2) y -= _baseInteractorSize/2;
        if(y < _baseInteractorSize/2) y += _baseInteractorSize/2;
        
        // create interactor, attach to audio file player
        SoundInteractor *interactor = [[ SoundInteractor alloc] initWithTexture:[_graphics getTextureForInteractor:filename]];
        interactor.graphics = _graphics;
        [interactor setUpInteractor];
        
        interactor.position = CGPointMake(x, y);
        interactor.name = filename;
        [interactor connectToConductor:_conductor];
        
        // set physics properties
        [interactor setPhysicsBody:[SKPhysicsBody bodyWithTexture:interactor.texture alphaThreshold:0 size:interactor.size]];
        interactor.physicsBody.affectedByGravity = NO;
        interactor.physicsBody.allowsRotation = YES;
        interactor.physicsBody.dynamic = YES;
        interactor.physicsBody.friction = 0.0f;
        interactor.physicsBody.restitution = 0.0f;
        interactor.physicsBody.linearDamping = 0.1f;
        interactor.physicsBody.angularDamping = 0.2f;
        interactor.physicsBody.categoryBitMask = ballCategory;
        interactor.physicsBody.collisionBitMask = ballCategory | edgeCategory;
        interactor.physicsBody.contactTestBitMask = edgeCategory | ballCategory;
        
        [interactor resetValues];
        
        if([unlockedNodesDict objectForKey:filename]){
            [self addChild:interactor];
            [interactor unlockNode];
            [interactor appearWithGrowAnimation];
            [self applyImpulseToInteractor:interactor];
        }
        [_soundInteractors addObject:interactor];
    }
    
    self.draggedInteractor = nil;
}

- (void)addMenuNode {
    CGFloat windowWidth = self.size.width;
    CGFloat windowHeight = self.size.height;
    
    SKSpriteNode *homeNode = [SKSpriteNode spriteNodeWithImageNamed:@"interactor_home"];
    homeNode.position = CGPointMake(windowWidth/2, windowHeight/2);
    homeNode.name = @"homeNode";
    homeNode.color = [_graphics getInteractorOffColor];
    homeNode.colorBlendFactor = 1.0;
    SKSpriteNode *homeIcon = [SKSpriteNode spriteNodeWithImageNamed:@"home_icon"];
    [homeNode addChild:homeIcon];
    
    [homeNode setPhysicsBody:[SKPhysicsBody bodyWithTexture:homeNode.texture alphaThreshold:0 size:homeNode.size]];
    homeNode.physicsBody.affectedByGravity = NO;
    homeNode.physicsBody.allowsRotation = YES;
    homeNode.physicsBody.dynamic = YES;
    homeNode.physicsBody.friction = 0.0f;
    homeNode.physicsBody.restitution = 0.0f;
    homeNode.physicsBody.linearDamping = 0.1f;
    homeNode.physicsBody.angularDamping = 0.2f;
    homeNode.physicsBody.categoryBitMask = ballCategory;
    homeNode.physicsBody.collisionBitMask = ballCategory | edgeCategory;
    homeNode.physicsBody.contactTestBitMask = edgeCategory | ballCategory;
    
    [self addChild:homeNode];
}

- (void)startScene {
    [_conductor start];
    
    // randomize order of interactors
    NSUInteger count = [_soundInteractors count];
    for (int i = 0; i < count; ++i) {
        NSUInteger nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [_soundInteractors exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
    
    self.interactorTimer = [NSTimer scheduledTimerWithTimeInterval:interactorTimerDuration target:self selector:@selector(addNextInteractor) userInfo:nil repeats:YES];
    [_interactorTimer fire];
}

-(void)addNextInteractor
{
    if (_interactorCount >= _soundInteractors.count) {
        [_interactorTimer invalidate];
        return;
    }
    NSDictionary *unlockedNodesDict = [[NSUserDefaults standardUserDefaults] objectForKey:_unlockedNodesDictName];
    SoundInteractor *interactor = _soundInteractors[_interactorCount];
    
    if([unlockedNodesDict objectForKey:interactor.name]){
        _interactorCount++;
        [self addNextInteractor];
        return;
    }
    
    [self addChild:interactor];
    [interactor appearWithGrowAnimation];
    [self applyImpulseToInteractor:interactor];
    
    _interactorCount++;
}

-(void)applyImpulseToInteractor:(SoundInteractor *)interactor
{
    CGVector velocityVector = CGVectorMake((CGFloat) random()/(CGFloat) RAND_MAX * 50,
                                           (CGFloat) random()/(CGFloat) RAND_MAX * 50);
    if(rand() > RAND_MAX/2) velocityVector.dx = -velocityVector.dx;
    if(rand() > RAND_MAX/2) velocityVector.dy = -velocityVector.dy;
    [interactor.physicsBody setVelocity:velocityVector];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // THIS IS NECESSARY TO DEAL WITH LAME BUG IN APPLE CODE THAT IGNORES IMPULSES LESS THAN 20 OR SOME BS LIKE THAT
    SKPhysicsBody *bodyA = contact.bodyA;
    SKPhysicsBody *bodyB = contact.bodyB;
    CGVector contactNormal = contact.contactNormal;
    CGFloat contactImpulse = contact.collisionImpulse;
    
    if((bodyA.categoryBitMask == edgeCategory && bodyB.categoryBitMask == ballCategory)){
        // wall collision
        if(contactImpulse < 15 && contactImpulse > 0){
            if(contactNormal.dx == -1 && contactNormal.dy == 0){
                // right wall
                [bodyB applyImpulse:CGVectorMake(-contactImpulse, 0)];
            } else if(contactNormal.dx == 1 && contactNormal.dy == 0){
                // left wall
                [bodyB applyImpulse:CGVectorMake(contactImpulse, 0)];
            } else if(contactNormal.dx == 0 && contactNormal.dy == -1){
                // top wall
                [bodyB applyImpulse:CGVectorMake(0, -contactImpulse)];
            } else if(contactNormal.dx == 0 && contactNormal.dy == 1){
                // bottom wall
                [bodyB applyImpulse:CGVectorMake(0, contactImpulse)];
            }
        }
        
    } else if((bodyA.categoryBitMask == ballCategory && bodyB.categoryBitMask == ballCategory)){
        if((SoundInteractor *)bodyA.node == _draggedInteractor){
            bodyA.velocity = CGVectorMake(0, 0);
        } else if((SoundInteractor *)bodyB.node == _draggedInteractor){
            bodyB.velocity = CGVectorMake(0, 0);
        }
        if(contactImpulse < 15){
            bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 1.02, bodyB.velocity.dy * 1.02);
            bodyA.velocity = CGVectorMake(bodyA.velocity.dx * 1.02, bodyA.velocity.dy * 1.02);
        }
        
        
    }
    
        if (contactImpulse > 1) {
            float vel = pow(10, 1/(-contactImpulse));
            int intVel = roundf(vel * 50);
            [_conductor playCollisionSoundWithVelocity:intVel];
        }
}



- (void)addGestureRecognizers {
    
    UIDoubleTapGestureRecognizer *doubleTapRecognizer = [[UIDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    doubleTapRecognizer.numberOfTapsRequired = 2;
    doubleTapRecognizer.delegate = self;
    [[self view] addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapRecognizer.delegate = self;
    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [[self view] addGestureRecognizer:tapRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    panRecognizer.delegate = self;
    [[self view] addGestureRecognizer:panRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(haltCell:)];
    longPressRecognizer.delegate = self;
    longPressRecognizer.minimumPressDuration = .15;
    [[self view] addGestureRecognizer:longPressRecognizer];
    
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]] && ((SoundInteractor *)touchedNode).isReady) {
        
        SoundInteractor *interactor = (SoundInteractor *)touchedNode;
        
        if (![interactor isUnlocked] || recognizer.numberOfTapsRequired == 2) {
            
            if (![interactor isUnlocked]) {
                interactor.texture = [_graphics getTextureForInteractor:interactor.name];
            }
            
            CGPoint pointToZoomTo = touchedNode.position;
            pointToZoomTo.x += touchedNode.frame.size.width/7;
            pointToZoomTo.y += touchedNode.frame.size.height/4;
            
            _tappedInteractor = interactor;
            [_interactorTimer invalidate];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadMinigame" object:self userInfo:[NSDictionary dictionaryWithObjects:@[interactor.name, [NSValue valueWithCGPoint:pointToZoomTo], [NSValue valueWithCGSize:touchedNode.frame.size]] forKeys:@[@"loopName", @"nodeCoordinates", @"nodeSize"]]];
            
//            [interactor turnOn];
            
        } else if (![interactor getState]) { // single tap on unlocked node
            [interactor turnOn];
        } else {
            [interactor turnOff];
        }
    } else if ([touchedNode.name isEqualToString:@"homeNode"] || [touchedNode.parent.name isEqualToString:@"homeNode"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ReturnToMainMenu" object:self userInfo:nil];
    } else if ([touchedNode.name isEqualToString:@"message"]) {
        SKAction *fadeOut = [SKAction fadeAlphaTo:0 duration:0.5];
        [touchedNode runAction:fadeOut completion:^(void){
            [touchedNode removeFromParent];
        }];
    }
}

- (void)handlePanFrom:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        if(_draggedInteractor) return;
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self setPanNodeForTouch:touchLocation];
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        [self panForLocation:touchLocation];
        [recognizer setTranslation:CGPointZero inView:recognizer.view];
        
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (_draggedInteractor) {
            CGPoint velocity = [recognizer velocityInView:recognizer.view];
            _draggedInteractor.physicsBody.velocity = CGVectorMake(velocity.x, -velocity.y);
            double totalVelocity = sqrt((velocity.x * velocity.x) + (velocity.y * velocity.y));
            if(totalVelocity > 200){
                //                double scale = [self chooseScale:totalVelocity];
                double scale = 1;
                [UIView animateWithDuration:1 animations:^{
                    _draggedInteractor.physicsBody.velocity = CGVectorMake(velocity.x/scale, -velocity.y/scale);
                }];
            }
            _draggedInteractor = nil;
        }
        
    }
}

- (void)setPanNodeForTouch:(CGPoint)location
{
    SKNode *touchedNode = [self nodeAtPoint:location];
    if ([touchedNode.parent.name isEqualToString:@"homeNode"]) {
        touchedNode = touchedNode.parent;
    }
    if([touchedNode.parent isKindOfClass:[SoundInteractor class]])
        touchedNode = touchedNode.parent;
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]] || [touchedNode.name isEqualToString:@"homeNode"]) {
        SoundInteractor *interactor = (SoundInteractor *)touchedNode;
        _draggedInteractor = interactor;
        _draggedInteractor.physicsBody.velocity = CGVectorMake(0, 0);
    }
}

- (void)panForLocation:(CGPoint)location{
    if(!_draggedInteractor) return;
    [_draggedInteractor setPosition:location];
}

- (double)chooseScale:(double)totalVelocity{
    if(totalVelocity < 150)
        return 1.6;
    else if(totalVelocity < 300)
        return 1.9;
    else if(totalVelocity < 500)
        return 3;
    else if(totalVelocity < 1000)
        return 5;
    else if(totalVelocity < 2000)
        return 9;
    return 20;
}

- (void)haltCell:(UILongPressGestureRecognizer *)recognizer
{
    if(recognizer.state == UIGestureRecognizerStateBegan){
        CGPoint touchLocation = [recognizer locationInView:recognizer.view];
        touchLocation = [self convertPointFromView:touchLocation];
        SKNode *touchedNode = [self nodeAtPoint:touchLocation];
        
        if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
            SoundInteractor *interactor = (SoundInteractor *)touchedNode;
            interactor.physicsBody.velocity = CGVectorMake(0, 0);
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
       [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    
    else if([otherGestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] &&
            [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return YES;
    
    return NO;
}

- (void)returnFromGameScene:(NSNotification *)notification
{
    BOOL wasSuccessful = [(NSNumber *)notification.userInfo[@"reachedGoal"] boolValue];
    if(!wasSuccessful && !_tappedInteractor.isUnlocked){
        [_tappedInteractor lockNode];
    } else if (_tappedInteractor.isUnlocked) {
        [_tappedInteractor turnOnSimple];
    } else {
        NSMutableDictionary *unlockedNodesDict = [NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey:_unlockedNodesDictName]];
        [unlockedNodesDict setValue: [NSNumber numberWithBool:YES] forKey:_tappedInteractor.name];
        [[NSUserDefaults standardUserDefaults] setValue:unlockedNodesDict forKey:_unlockedNodesDictName];
        if(unlockedNodesDict.count == [_soundInteractors count]){
            int unlockedScenes = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"soundscapesCompleted"];
            [[NSUserDefaults standardUserDefaults] setInteger:unlockedScenes + 1 forKey:@"soundscapesCompleted"];
            
            if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenMessage3"]) {
                [self displayMessage3];
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenMessage3"];
            }
        }
        [_tappedInteractor unlockNode];
        [_tappedInteractor turnOnSimple];
        
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenMessage2"]) {
            [self displayMessage2];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenMessage2"];
        }
    }
    _tappedInteractor = nil;
    self.interactorTimer = [NSTimer scheduledTimerWithTimeInterval:interactorTimerDuration target:self selector:@selector(addNextInteractor) userInfo:nil repeats:YES];
    [_interactorTimer fire];
}

-(void)update:(CFTimeInterval)currentTime {
    for (SoundInteractor *interactor in _soundInteractors) {
        if ([interactor isReady]) {
            [interactor updateAppearance];
        }
    }
}

@end
