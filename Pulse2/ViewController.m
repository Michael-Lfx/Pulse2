//
//  ViewController.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/21/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import "MainMenuScene.h"
#import "GameScene.h"
#import "SongSliderScene.h"
#import "SongTrainScene.h"
#import "SongSwipeScene.h"

#import "Conductor.h"
#import "LoopData.h"

@interface ViewController ()

@property MainMenuScene *mainMenuScene;
@property Conductor *conductor;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.shouldHideStatusBar = YES;
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadSoundscape:) name:@"LoadSoundscape" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToMainMenu:) name:@"ReturnToMainMenu" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadMinigame:) name:@"LoadMinigame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToGameScene:) name:@"ReturnToGameScene" object:nil];
    
    // create a global conductor
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.conductor = [[Conductor alloc] initWithAudioController:delegate.audioController];
    
    // configure the views
    self.mainMenuView = [[SKView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:_mainMenuView];
    
    
//    SKView *skView = (SKView *)self.view;
//    skView.showsFPS = NO;
//    skView.showsNodeCount = NO;
//    skView.ignoresSiblingOrder = YES;
//    skView.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.95 alpha:1.0];
    
    CGSize screenSize = self.view.frame.size;
    self.mainMenuScene = [[MainMenuScene alloc] initWithSize:screenSize];
    [_mainMenuView presentScene:_mainMenuScene];
}

- (void)loadSoundscape:(NSNotification *)notification {
    
    NSDictionary *info = notification.userInfo;
    NSString *soundscapeName = [info objectForKey:@"name"];
    
    [_conductor loadSoundscapeWithPlistNamed:soundscapeName];
    
    self.soundScapeView = [[SKView alloc] initWithFrame:self.view.frame];
    
    CGSize screenSize = self.view.frame.size;
    CGPoint pointToZoomTo;
    pointToZoomTo = CGPointMake(_mainMenuView.center.x - 400, _mainMenuView.center.y + 300); // make this legit center for sections
    _soundScapeView.alpha = 0;
    [self.view addSubview:_soundScapeView];
    _mainMenuView.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:1.0 animations:^{
        _mainMenuView.transform = CGAffineTransformMakeScale(10, 10);
        _mainMenuView.center = pointToZoomTo;
        _soundScapeView.alpha = 1;
    } completion:^(BOOL completed){
        [_mainMenuScene removeFromParent];
        [_conductor start];
    }];
    
    if ([soundscapeName isEqualToString:@"relaxation"]) {
        GameScene *relaxation = [[GameScene alloc] initWithSize:screenSize];
        relaxation.conductor = _conductor;
        [_soundScapeView presentScene: relaxation transition:[SKTransition crossFadeWithDuration:.1]];
    }
}

- (void)returnToMainMenu:(NSNotification *)notification {
//    [(SKView *)self.view presentScene:_mainMenuScene transition:[SKTransition crossFadeWithDuration:1]];
//    _conductor.shouldCheckLevels = false;
    
    [_mainMenuView presentScene:_mainMenuScene];
    _mainMenuView.userInteractionEnabled = YES;
    [UIView animateWithDuration:1.0 animations:^{
        _soundScapeView.alpha = 0;
        _mainMenuView.transform = CGAffineTransformMakeScale(1, 1);
        _mainMenuView.center = self.view.center;
    } completion:^(BOOL finished){
        [_conductor stop];
        [_conductor releaseSoundscape];
        [_soundScapeView presentScene:nil];
        [_soundScapeView removeFromSuperview];
        _soundScapeView = nil;
    }];
}

- (void)loadMinigame:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    
    NSString *loopName = [info objectForKey:@"loopName"];
    Conductor *conductor = [info objectForKey:@"conductor"];
    CGPoint pointToZoomTo = [(NSValue *)[info objectForKey:@"nodeCoordinates"] CGPointValue];
    CGSize nodeSize = [(NSValue *)[info objectForKey:@"nodeSize"] CGSizeValue];
    
    LoopData *loopData = [[LoopData alloc] initWithPlist:@"relaxation" loop:loopName];
    NSString *minigameName = [loopData getMinigameName];
    _miniScapeView = [[SKView alloc] initWithFrame:self.view.frame];
    if ([minigameName isEqualToString:@"SongSliderScene"]) {
        [_miniScapeView presentScene: [[SongSliderScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size]];
    } else if ([minigameName isEqualToString:@"SongTrainScene"]) {
        [_miniScapeView presentScene:[[SongTrainScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size]];
    } else {
        [_miniScapeView presentScene: [[SongSwipeScene alloc] initWithLoopData:loopData conductor:conductor size:self.view.frame.size]];
    }
    [conductor fadeVolumeForLoop:loopName withDuration:1 fadeIn:YES];
    _miniScapeView.alpha = 0;
    [self.view addSubview:_miniScapeView];
    [_soundScapeView.scene setPaused:YES];
    
    CGFloat s = 2 * self.view.frame.size.height/nodeSize.height;
    CGAffineTransform tr = CGAffineTransformScale(self.view.transform, s, s);
    CGFloat h = self.view.frame.size.height;
    CGFloat w = self.view.frame.size.width;
    [UIView animateWithDuration:1.2 delay:0 options:0 animations:^{
        _soundScapeView.transform = tr;
        _soundScapeView.center = CGPointMake(w-w*s/2 + (w - pointToZoomTo.x)*s, h*s/2 - (h - pointToZoomTo.y)*s);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            _miniScapeView.alpha = 1;
        }];
        if([_miniScapeView.scene isKindOfClass:[SongSliderScene class]])
            [(SongSliderScene *)_miniScapeView.scene displayDirections];
    }];
    
}

- (void)returnToGameScene:(NSNotification *)notification {
    [_soundScapeView.scene setPaused:NO];
    [UIView animateWithDuration:.4 animations:^{
        _miniScapeView.alpha=0;
    }];
    [UIView animateWithDuration:1.0 animations:^{
        _soundScapeView.transform = CGAffineTransformMakeScale(1, 1);
        _soundScapeView.center = self.view.center;
    } completion:^(BOOL finished){
        [_miniScapeView removeFromSuperview];
        _miniScapeView = nil;
    }];
}

- (BOOL)prefersStatusBarHidden {
    return _shouldHideStatusBar;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
