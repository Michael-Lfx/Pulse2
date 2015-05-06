//
//  GameScene.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/27/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GameScene.h"
#import "AppDelegate.h"

@interface GameScene ()

@property AEAudioController *audioController;
@property Conductor *conductor;
@property AEAudioUnitChannel *collisionSound;

@end

@implementation GameScene

double interactorTimerDuration = 1.0;
float collisionFrequencies[6] = {51, 55, 56, 58, 62, 63};

- (void)didMoveToView:(SKView *)view {
    
    self.backgroundColor = [SKColor colorWithRed:10.0/255 green:55.0/255 blue:70.0/255 alpha:1.0];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.audioController = delegate.audioController;
    
    self.conductor = [[Conductor alloc] initWithAudioController:_audioController plist:@"relaxation"];
    
    [self createSoundInteractors];
    [self addGestureRecognizers];
    [self startScene];
}

- (void)createSoundInteractors {
    CGFloat windowWidth = self.size.width;
    CGFloat windowHeight = self.size.height;
    
    self.baseInteractorSize = windowWidth * 0.1313;
    self.interactorCount = 0;
    
    self.soundInteractors = [[NSMutableArray alloc] init];
    
    NSArray *filenames = [_conductor getFilenames];
    
    for (NSString *filename in filenames) {
        
        // random position within bounds of screen
        CGFloat x = (random()/(CGFloat)RAND_MAX) * windowWidth;
        CGFloat y = (random()/(CGFloat)RAND_MAX) * windowHeight;
        if(x > windowWidth - _baseInteractorSize/2) x -= _baseInteractorSize/2;
        if(x <  _baseInteractorSize/2) x += _baseInteractorSize/2;
        if(y > windowHeight - _baseInteractorSize/2) y -= _baseInteractorSize/2;
        if(y < _baseInteractorSize/2) y += _baseInteractorSize/2;
        
        // create interactor, attach to audio file player
        SoundInteractor *interactor = [SoundInteractor shapeNodeWithCircleOfRadius:_baseInteractorSize/2];
        interactor.position = CGPointMake(x, y);
        interactor.name = filename;
        [interactor connectToConductor:_conductor];
//        [interactor connectToLoopManager:loopManager];
        
        // set physics properties
        [interactor setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:interactor.frame.size.width/2]];
        interactor.physicsBody.affectedByGravity = NO;
        interactor.physicsBody.allowsRotation = NO;
        interactor.physicsBody.dynamic = YES;
        interactor.physicsBody.friction = 0.0f;
        interactor.physicsBody.restitution = 0.0f;
        interactor.physicsBody.linearDamping = 0.1f;
        interactor.physicsBody.angularDamping = 0.0f;
        interactor.physicsBody.categoryBitMask = ballCategory;
        interactor.physicsBody.collisionBitMask = ballCategory | edgeCategory;
        interactor.physicsBody.contactTestBitMask = edgeCategory | ballCategory;
        
        [interactor resetValues];
        [_soundInteractors addObject:interactor];
    }
    
    self.draggedInteractor = nil;
    
    AudioComponentDescription component = AEAudioComponentDescriptionMake(kAudioUnitManufacturer_Apple,
                                                                          kAudioUnitType_MusicDevice,
                                                                          kAudioUnitSubType_Sampler);
    NSError *error = NULL;
    self.collisionSound = [[AEAudioUnitChannel alloc] initWithComponentDescription:component audioController:_audioController error:&error];
    if (!_collisionSound) {
        // report error
    } else {
        
        NSURL *presetURL = [[NSBundle mainBundle] URLForResource:@"piano" withExtension:@"aupreset"];
        
        OSStatus result = noErr;
        AUSamplerInstrumentData auPreset = {0};
        auPreset.fileURL = (__bridge CFURLRef)presetURL;
        auPreset.instrumentType = kInstrumentType_AUPreset;
        result = AudioUnitSetProperty(_collisionSound.audioUnit,
                             kAUSamplerProperty_LoadInstrument,
                             kAudioUnitScope_Global,
                             0,
                             &auPreset,
                             sizeof(auPreset));
    }
    
    [_audioController addChannels:[NSArray arrayWithObject:_collisionSound]];
}

- (void)addGestureRecognizers {
//    self.swipeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(goHome)];
//    _swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
//    [self.view addGestureRecognizer:_swipeRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(haltCell:)];
    panRecognizer.delegate = self;
    tapRecognizer.delegate = self;
    longPressRecognizer.delegate = self;
    longPressRecognizer.minimumPressDuration = .2;
    [[self view] addGestureRecognizer:panRecognizer];
    [[self view] addGestureRecognizer:tapRecognizer];
    [[self view] addGestureRecognizer:longPressRecognizer];
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

- (void)bringInNewLoop {
    if (_interactorCount == 0) {
        for(int i = 0; i <= 3; i++){
            [self addNextInteractor];
        }
    } else {
        [self addNextInteractor];
    }
}

-(void)addNextInteractor
{
    if (_interactorCount >= _soundInteractors.count) {
        [_interactorTimer invalidate];
        return;
    }
    SoundInteractor *interactor = _soundInteractors[_interactorCount];
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
        int r = arc4random_uniform(6);
        float vel = pow(10, 1/(-contactImpulse));
        int intVel = roundf(vel * 50);
        MusicDeviceMIDIEvent(_collisionSound.audioUnit, 0x90, collisionFrequencies[r], intVel, 0);
    }
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
        SoundInteractor *interactor = (SoundInteractor *)touchedNode;
        if ([interactor getState] == NO) {
            [interactor turnOn];
//            MusicDeviceMIDIEvent(_collisionSound.audioUnit, 0x90, 60, 127, 0);
        } else {
            [interactor turnOff];
        }
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
    
    if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    int value = 0;
    for (SoundInteractor *interactor in _soundInteractors) {
        if ([interactor isReady]) {
            [interactor updateAppearance];
        }
        if (value == 0) {
            value = 1;
            double beat = [_conductor getCurrentBeatForLoop:interactor.name];
        }
    }
}

-(void)willMoveFromView:(SKView *)view{
    [self.view removeGestureRecognizer:_swipeRecognizer];
}

@end
