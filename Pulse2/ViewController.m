//
//  ViewController.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/21/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "LoopData.h"
#import "SongSliderScene.h"
#import "SongTrainScene.h"
#import "SongSwipeScene.h"

@interface ViewController ()

@property GameScene *gameScene;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.shouldHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMinigame:) name:@"LoadMinigame" object:nil];
    
    // configure the view
    SKView *skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    skView.ignoresSiblingOrder = YES;
    skView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.95 alpha:1.0];
    
    CGSize screenSize = self.view.frame.size;
    self.gameScene = [[GameScene alloc] initWithSize:screenSize];
    [skView presentScene:_gameScene];
}

- (void)loadMinigame:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    
    NSString *minigameName = [info objectForKey:@"minigameName"];
    NSString *loopName = [info objectForKey:@"loopName"];
    Conductor *conductor = [info objectForKey:@"conductor"];
    
    LoopData *loopData = [[LoopData alloc] initWithPlist:@"relaxation" loop:loopName];
    
    if ([minigameName isEqualToString:@"SongSlider"]) {
        SongSliderScene *sliderScene = [[SongSliderScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size];
        SKTransition *transition = [SKTransition fadeWithDuration:1.0];
        [conductor fadeVolumeForLoop:loopName withDuration:1 fadeIn:YES];
        SKView *skView = (SKView *)self.view;
        [skView presentScene:sliderScene transition:transition];
        [_gameScene removeFromParent];
    }
}

- (BOOL)prefersStatusBarHidden {
    return _shouldHideStatusBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
