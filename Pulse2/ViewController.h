//
//  ViewController.h
//  Pulse2
//
//  Created by Henry Thiemann on 4/21/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "SoundscapeScene.h"

@interface ViewController : UIViewController

@property BOOL shouldHideStatusBar;
@property SKView *mainMenuView;
@property SKView *soundScapeView;
@property SKView *miniScapeView;

@property SoundscapeScene *soundscapeScene;

@end

