//
//  MainMenuScene.m
//  Pulse2
//
//  Created by Henry Thiemann on 5/4/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "MainMenuScene.h"
#import "AppDelegate.h"
#import "UIDoubleTapGestureRecognizer.h"

@interface MainMenuScene ()

@property AEAudioController *audioController;

@property SKSpriteNode *node1;
@property SKSpriteNode *node2;
@property SKSpriteNode *node3;
@property SKSpriteNode *node4;
@property SKSpriteNode *titleNode;

@end

@implementation MainMenuScene

bool _nodesAdded = false;

- (void)didMoveToView:(SKView *)view {
    
    if (!_nodesAdded){
        self.backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
        self.scaleMode = SKSceneScaleModeAspectFit;
        
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.audioController = delegate.audioController;
        [self addNodes];
        [self addGestureRecognizers];
    }
}

- (void)addNodes {
    CGPoint centerPoint = CGPointMake(self.size.width/2, self.size.height/1.7);
    
    self.node1 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_1"];
    [_node1 setPosition:CGPointMake(centerPoint.x - 64.32 + _node1.size.width/2,
                                    self.size.height - (centerPoint.y - 151.5 + _node1.size.height/2))];
    _node1.name = @"1";
    [self addChild:_node1];
    
    self.node2 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_2"];
    [_node2 setPosition:CGPointMake(centerPoint.x - 109.38 + _node2.size.width/2,
                                    self.size.height - (centerPoint.y - 122.84 + _node2.size.height/2))];
    _node2.alpha = 0.3;
    _node2.name = @"2";
    [self addChild:_node2];
    
    self.node3 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_3"];
    [_node3 setPosition:CGPointMake(centerPoint.x + 2.46 + _node3.size.width/2,
                                    self.size.height - (centerPoint.y - 37.49 + _node3.size.height/2))];
    _node3.alpha = 0.3;
    _node3.name = @"3";
    [self addChild:_node3];
    
    self.node4 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_4"];
    [_node4 setPosition:CGPointMake(centerPoint.x - 116.41 + _node4.size.width/2,
                                    self.size.height - (centerPoint.y + 9.44 + _node4.size.height/2))];
    _node4.alpha = 0.3;
    _node4.name = @"4";
    [self addChild:_node4];
    
    self.titleNode = [SKSpriteNode spriteNodeWithImageNamed:@"pulse_logo"];
    [_titleNode setPosition:CGPointMake(self.size.width/2, self.size.height/1.2)];
    [self addChild:_titleNode];
    _nodesAdded = true;
}

- (void)addGestureRecognizers {
    
//    UIDoubleTapGestureRecognizer *doubleTapRecognizer = [[UIDoubleTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
//    doubleTapRecognizer.numberOfTapsRequired = 2;
//    doubleTapRecognizer.delegate = self;
//    [[self view] addGestureRecognizer:doubleTapRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapRecognizer.delegate = self;
//    [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
    [[self view] addGestureRecognizer:tapRecognizer];
    
//    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];
//    panRecognizer.delegate = self;
//    [[self view] addGestureRecognizer:panRecognizer];
//    
//    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(haltCell:)];
//    longPressRecognizer.delegate = self;
//    longPressRecognizer.minimumPressDuration = .2;
//    [[self view] addGestureRecognizer:longPressRecognizer];
    
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
//    SKAction *expand = [SKAction scaleBy:10 duration:1];
//    SKAction *flashIn = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:1 duration:1];
//    SKAction *flashBack = [SKAction colorizeWithColor:[UIColor whiteColor] colorBlendFactor:0 duration:.25];
//    SKAction *flash = [SKAction sequence:@[flashIn]];
    if ([touchedNode isEqualToNode:_node1]) {
//        [_node1 runAction:flashIn];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadSoundscape" object:self userInfo:[NSDictionary dictionaryWithObjects:@[@"relaxation"] forKeys:@[@"name"]]];
    } else if([touchedNode isEqualToNode:_node2]){
        NSLog(@"tapping red");
    }
}

@end
