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
#import "SoundscapeScene.h"
#import "SongTapScene.h"
#import "SongTrainScene.h"
#import "SongSwipeScene.h"
#import "OrbGameScene.h"

#import "GraphicsController.h"
#import "Conductor.h"
#import "LoopData.h"

@interface ViewController ()

@property MainMenuScene *mainMenuScene;
@property GraphicsController *graphics;
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnFromGameScene:) name:@"ReturnFromGameScene" object:nil];
    
    // create a global conductor
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.conductor = [[Conductor alloc] initWithAudioController:delegate.audioController];
    
    self.graphics = [[GraphicsController alloc] init];
    
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
    [_graphics loadSoundscapeWithPlistNamed:soundscapeName];
    
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
    
//    if ([soundscapeName isEqualToString:@"relaxation"]) {
        self.soundscapeScene = [[SoundscapeScene alloc] initWithSize:screenSize];
        _soundscapeScene.conductor = _conductor;
        _soundscapeScene.graphics = _graphics;
        [_soundScapeView presentScene: _soundscapeScene transition:[SKTransition crossFadeWithDuration:.1]];
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenMessage1"]) {
            [_soundscapeScene displayMessage1];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenMessage1"];
        }
//    } else if ([soundscapeName isEqualToString:@"jam"]) {
//        self.soundscapeScene = [[SoundscapeScene alloc] initWithSize:screenSize];
//        _soundscapeScene.conductor = _conductor;
//        _soundscapeScene.graphics = _graphics;
//        [_soundScapeView presentScene: _soundscapeScene transition:[SKTransition crossFadeWithDuration:.1]];
//        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasSeenMessage1"]) {
//            [_soundscapeScene displayMessage1];
//            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasSeenMessage1"];
//        }
//    }
}

- (void)returnToMainMenu:(NSNotification *)notification {
//    [(SKView *)self.view presentScene:_mainMenuScene transition:[SKTransition crossFadeWithDuration:1]];
//    _conductor.shouldCheckLevels = false;
    
    [_mainMenuView presentScene:_mainMenuScene];
    _mainMenuView.userInteractionEnabled = YES;
    [_conductor releaseSoundscape];
    [UIView animateWithDuration:1.0 animations:^{
        _soundScapeView.alpha = 0;
        _mainMenuView.transform = CGAffineTransformMakeScale(1, 1);
        _mainMenuView.center = self.view.center;
    } completion:^(BOOL finished){
        [_soundScapeView presentScene:nil];
        [_soundScapeView removeFromSuperview];
        _soundScapeView = nil;
    }];
}

- (void)loadMinigame:(NSNotification *)notification {
    NSDictionary *info = notification.userInfo;
    
    NSString *loopName = [info objectForKey:@"loopName"];
    NSLog(@"entering loop: %@",loopName);
    LoopData *loopData = [[LoopData alloc] initWithPlist:[_conductor getSoundscapeName] loop:loopName];
    NSString *minigameName = [loopData getMinigameName];
    
    CGPoint pointToZoomTo = [(NSValue *)[info objectForKey:@"nodeCoordinates"] CGPointValue];
    CGSize nodeSize = [(NSValue *)[info objectForKey:@"nodeSize"] CGSizeValue];
    
    _miniScapeView = [[SKView alloc] initWithFrame:self.view.frame];
    
    if ([minigameName isEqualToString:@"SongTapScene"]) {
        [_miniScapeView presentScene: [[SongTapScene alloc] initWithLoopData:loopData graphics:_graphics conductor:_conductor size:self.view.frame.size]];
    } else if ([minigameName isEqualToString:@"SongTrainScene"]) {
        [_miniScapeView presentScene:[[SongTrainScene alloc] initWithLoopData:loopData graphics:_graphics conductor:_conductor size:self.view.frame.size]];
    } else if ([minigameName isEqualToString:@"SongSwipeScene"]) {
        [_miniScapeView presentScene: [[SongSwipeScene alloc] initWithLoopData:loopData graphics:_graphics conductor:_conductor size:self.view.frame.size]];
    } else if ([minigameName isEqualToString:@"OrbGameScene"]) {
        [_miniScapeView presentScene: [[OrbGameScene alloc] initWithLoopData:loopData graphics:_graphics conductor:_conductor size:self.view.frame.size]];
    }
    
    [_conductor setMinigameLoop:loopName];
    
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
        _soundScapeView.alpha = 0;
        _miniScapeView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
    
    if([_miniScapeView.scene isKindOfClass:[SongTapScene class]] && [[NSUserDefaults standardUserDefaults] integerForKey:@"timeSeenTapGame"] <2)
        [(SongTapScene *)_miniScapeView.scene displayDirections];
    else if([_miniScapeView.scene isKindOfClass:[SongTrainScene class]] && [[NSUserDefaults standardUserDefaults] integerForKey:@"timesSeenTrainGame"] <2)
        [(SongTrainScene *)_miniScapeView.scene displayDirections];
    else if([_miniScapeView.scene isKindOfClass:[OrbGameScene class]] && [[NSUserDefaults standardUserDefaults] integerForKey:@"timesSeenOrbGame"] <2)
        [(OrbGameScene *)_miniScapeView.scene displayDirections];
    
}

- (void)returnFromGameScene:(NSNotification *)notification {
    [_soundScapeView.scene setPaused:NO];
    [_conductor setMinigameLoop:nil];
    [UIView animateWithDuration:.4 animations:^{
        _miniScapeView.alpha = 0;
        _soundScapeView.alpha = 1;
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
