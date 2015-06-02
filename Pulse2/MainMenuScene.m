//
//  MainMenuScene.m
//  Pulse2
//
//  Created by Henry Thiemann on 5/4/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "MainMenuScene.h"

@implementation MainMenuScene

- (void)didMoveToView:(SKView *)view {
    
    SKSpriteNode *node = [SKSpriteNode spriteNodeWithImageNamed:@"menu_button_1"];
    [self addChild:node];
}

@end
