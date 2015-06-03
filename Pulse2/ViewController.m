//
//  ViewController.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/21/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "MainMenuScene.h"
#import "LoopData.h"
#import "SongSliderScene.h"
#import "SongTrainScene.h"
#import "SongSwipeScene.h"

@interface ViewController ()

@property GameScene *gameScene;
@property MainMenuScene *mainMenuScene;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSoundscape:) name:@"LoadSoundscape" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMinigame:) name:@"LoadMinigame" object:nil];
    
    // configure the view
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.ignoresSiblingOrder = YES;
    skView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.95 alpha:1.0];
    
    CGSize screenSize = self.view.frame.size;
//    self.gameScene = [[GameScene alloc] initWithSize:screenSize];
//    [skView presentScene:_gameScene];
    
    self.mainMenuScene = [[MainMenuScene alloc] initWithSize:screenSize];
    [skView presentScene:_mainMenuScene];
}

- (void)loadSoundscape:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    
    NSString *soundscapeName = [info objectForKey:@"name"];
    
    CGSize screenSize = self.view.frame.size;
    
    if ([soundscapeName isEqualToString:@"relaxation"]) {
        self.gameScene = [[GameScene alloc] initWithSize:screenSize];
        [_mainMenuScene removeFromParent];
        SKView *skView = (SKView *)self.view;
        [skView presentScene:_gameScene];
    }
}

- (void)loadMinigame:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    
    NSString *loopName = [info objectForKey:@"loopName"];
    Conductor *conductor = [info objectForKey:@"conductor"];
    
    LoopData *loopData = [[LoopData alloc] initWithPlist:@"relaxation" loop:loopName];
    NSString *minigameName = [loopData getMinigameName];
    SKScene *sceneToPresent;
    if ([minigameName isEqualToString:@"SongSliderScene"]) {
        SongSliderScene *sliderScene = [[SongSliderScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size];
        sceneToPresent = sliderScene;
    } else if ([minigameName isEqualToString:@"SongTrainScene"]) {
        SongTrainScene *trainScene = [[SongTrainScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size];
        sceneToPresent = trainScene;
    } else {
        SongSwipeScene *swipeScene = [[SongSwipeScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size];
        sceneToPresent = swipeScene;
    }
    SKTransition *transition = [SKTransition doorsOpenHorizontalWithDuration:1.0];
    transition.pausesOutgoingScene = TRUE;
    [conductor fadeVolumeForLoop:loopName withDuration:1 fadeIn:YES];
    SKView *skView = (SKView *)self.view;
    [skView presentScene:sceneToPresent transition:transition];
    [_gameScene removeFromParent];
}

- (BOOL)prefersStatusBarHidden {
    return _shouldHideStatusBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
