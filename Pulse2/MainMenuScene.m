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
@property SKSpriteNode *loadingNode;

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
    } else {
        _loadingNode.alpha = 0;
    }
    
    [self unlockRelevantScapes];
}

- (void)addNodes {
    CGPoint centerPoint = CGPointMake(self.size.width/2, self.size.height/1.7);
    
    self.node1 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_1"];
    [_node1 setPosition:CGPointMake(centerPoint.x - 12.62 + _node1.size.width/2,
                                    self.size.height - (centerPoint.y - 154.97 + _node1.size.height/2))];
    _node1.name = @"1";
    [self addChild:_node1];
    
    self.node2 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_2"];
    [_node2 setPosition:CGPointMake(centerPoint.x - 111.21 + _node2.size.width/2,
                                    self.size.height - (centerPoint.y - 118.07 + _node2.size.height/2))];
//    _node2.alpha = 0.3;
    _node2.name = @"2";
    [self addChild:_node2];
    
    self.node3 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_3"];
    [_node3 setPosition:CGPointMake(centerPoint.x - 2.46 + _node3.size.width/2,
                                    self.size.height - (centerPoint.y - 36.99 + _node3.size.height/2))];
    _node3.alpha = 0.3;
    _node3.name = @"3";
    [self addChild:_node3];
    
    self.node4 = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_4"];
    [_node4 setPosition:CGPointMake(centerPoint.x - 98.3 + _node4.size.width/2,
                                    self.size.height - (centerPoint.y + 12.25 + _node4.size.height/2))];
    _node4.alpha = 0.3;
    _node4.name = @"4";
    [self addChild:_node4];
    
    self.titleNode = [SKSpriteNode spriteNodeWithImageNamed:@"pulse_logo"];
    [_titleNode setPosition:CGPointMake(self.size.width/2, self.size.height/1.2)];
    [self addChild:_titleNode];
    
    self.loadingNode = [SKSpriteNode spriteNodeWithImageNamed:@"message_loading"];
    [_loadingNode setPosition:CGPointMake(self.size.width/2, self.size.height/15)];
    _loadingNode.alpha = 0;
    _loadingNode.userInteractionEnabled = NO;
    [self addChild:_loadingNode];
    
    SKSpriteNode *demoReset = [SKSpriteNode spriteNodeWithImageNamed:@"demo_reset"];
    [demoReset setPosition:CGPointMake(demoReset.size.width/2 + 10, self.size.height-demoReset.size.height/2 - 10)];
    demoReset.name = @"demoReset";
    [self addChild:demoReset];
    
    _nodesAdded = true;
}

- (void)addGestureRecognizers {
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapFrom:)];
    tapRecognizer.delegate = self;
    [[self view] addGestureRecognizer:tapRecognizer];
    
}

- (void)unlockRelevantScapes
{
    int scapesBeaten = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"soundscapesCompleted"];
    if(scapesBeaten >=1)
        _node2.alpha = 1;
    if(scapesBeaten >=2)
        _node3.alpha = 1;
    if(scapesBeaten >=3)
        _node4.alpha = 1;
}

- (void)handleTapFrom:(UITapGestureRecognizer *)recognizer
{
    CGPoint touchLocation = [recognizer locationInView:recognizer.view];
    touchLocation = [self convertPointFromView:touchLocation];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode isEqualToNode:_node1]) {
        [_loadingNode runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
        [_node1 runAction:[SKAction colorizeWithColor:[UIColor blueColor] colorBlendFactor:1.0 duration:0.05] completion:^{
            [_node1 runAction:[SKAction colorizeWithColorBlendFactor:0.0 duration:0.5] completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadSoundscape" object:self userInfo:[NSDictionary dictionaryWithObjects:@[@"relaxation"] forKeys:@[@"name"]]];
            }];
        }];
    } else if([touchedNode isEqualToNode:_node2]){
        if(_node2.alpha != 1) return;
        [_loadingNode runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
        [_node2 runAction:[SKAction colorizeWithColor:[UIColor orangeColor] colorBlendFactor:1.0 duration:0.05] completion:^{
            [_node2 runAction:[SKAction colorizeWithColorBlendFactor:0.0 duration:0.5] completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadSoundscape" object:self userInfo:[NSDictionary dictionaryWithObjects:@[@"relaxation"] forKeys:@[@"name"]]]; // TODO CHANGE RELAXATION TO APPROPRIATE NAME
            }];
        }];
    } else if([touchedNode isEqualToNode:_node3]){
        if(_node3.alpha != 1) return;
        [_loadingNode runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
        [_node3 runAction:[SKAction colorizeWithColor:[UIColor yellowColor] colorBlendFactor:1.0 duration:0.05] completion:^{
            [_node3 runAction:[SKAction colorizeWithColorBlendFactor:0.0 duration:0.5] completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadSoundscape" object:self userInfo:[NSDictionary dictionaryWithObjects:@[@"relaxation"] forKeys:@[@"name"]]]; // TODO CHANGE RELAXATION TO APPROPRIATE NAME
            }];
        }];
    } else if([touchedNode isEqualToNode:_node4]){
        if(_node4.alpha != 1) return;
        [_loadingNode runAction:[SKAction fadeAlphaTo:1.0 duration:0.5]];
        [_node4 runAction:[SKAction colorizeWithColor:[UIColor purpleColor] colorBlendFactor:1.0 duration:0.05] completion:^{
            [_node4 runAction:[SKAction colorizeWithColorBlendFactor:0.0 duration:0.5] completion:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadSoundscape" object:self userInfo:[NSDictionary dictionaryWithObjects:@[@"relaxation"] forKeys:@[@"name"]]]; // TODO CHANGE RELAXATION TO APPROPRIATE NAME
            }];
        }];
    } else if ([touchedNode.name isEqualToString:@"demoReset"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenSoundscape"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesBeatenTrainGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesBeatenTapGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesBeatenPulseGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"soundscapesCompleted"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"relaxationUnlockedNodes"];
        // TODO remove for later scenes when we name them
//         _node2.alpha = 0.3;
         _node3.alpha = 0.3;
         _node4.alpha = 0.3;
    }
}

@end
