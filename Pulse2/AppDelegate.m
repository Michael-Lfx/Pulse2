//
//  AppDelegate.m
//  Pulse2
//
//  Created by Henry Thiemann on 4/21/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.audioController = [[AEAudioController alloc] initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]];
    NSError *error = NULL;
    BOOL result = [_audioController start:&error];
    if (!result) {
        // Report error
    }
    
    _audioController.allowMixingWithOtherApps = NO;
    _audioController.useMeasurementMode = YES;
    
    if(![[NSUserDefaults standardUserDefaults] objectForKey:@"firstTime"]){
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"firstTime"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenMessage1"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenMessage2"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasSeenMessage3"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesSeenTrainGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timeSeenTapGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"timesSeenOrbGame"];
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"soundscapesCompleted"];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
