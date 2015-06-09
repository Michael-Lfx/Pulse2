//
//  GraphicsController.m
//  Pulse2
//
//  Created by Henry Thiemann on 6/7/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GraphicsController.h"

@interface GraphicsController ()

@property UIColor *backgroundColor;
@property UIColor *interactorColorOn;
@property UIColor *interactorColorOff;

@property NSMutableDictionary *interactorTextures;

@end

@implementation GraphicsController

- (void)loadSoundscapeWithPlistNamed:(NSString *)plist {
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:plist ofType:@"plist"];
    NSDictionary *data = [[NSDictionary alloc] initWithContentsOfFile:pathToPlist];
    
    NSArray *interactorNames = [[data objectForKey:@"audio files"] allKeys];
    self.interactorTextures = [[NSMutableDictionary alloc] init];
    
    int num = 0;
    for (NSString *name in interactorNames) {
        SKTexture *texture = [SKTexture textureWithImageNamed:[NSString stringWithFormat:@"interactor_%i", num]];
        [_interactorTextures setObject:texture forKey:name];
        num++;
    }
    
    if ([plist isEqualToString:@"relaxation"]) {
        _backgroundColor = [UIColor colorWithRed:0.125f green:0.314f blue:0.502f alpha:1.00f];
        _interactorColorOn = [UIColor colorWithRed:0.431f green:0.651f blue:0.871f alpha:1.00f];
        _interactorColorOff = [UIColor colorWithRed:0.663f green:0.706f blue:0.753f alpha:1.00f];
    } else if ([plist isEqualToString:@"jam"]) {
        _backgroundColor = [UIColor colorWithRed:0.678f green:0.388f blue:0.153f alpha:1.00f];
        _interactorColorOn = [UIColor colorWithRed:1.000f green:0.784f blue:0.612f alpha:1.00f];
        _interactorColorOff = [UIColor colorWithRed:1.000f green:0.784f blue:0.612f alpha:1.00f];
    } else if ([plist isEqualToString:@"three"]) {
        _backgroundColor = [UIColor colorWithRed:0.659f green:0.753f blue:0.188f alpha:1.00f];
        _interactorColorOn = [UIColor colorWithRed:0.855f green:0.910f blue:0.592f alpha:1.00f];
        _interactorColorOff = [UIColor colorWithRed:0.510f green:0.510f blue:0.510f alpha:1.00f];
    } else if ([plist isEqualToString:@"four"]) {
        _backgroundColor = [UIColor colorWithRed:0.518f green:0.231f blue:0.702f alpha:1.00f];
        _interactorColorOn = [UIColor colorWithRed:0.824f green:0.725f blue:0.890f alpha:1.00f];
        _interactorColorOff = [UIColor colorWithRed:0.255f green:0.188f blue:0.298f alpha:1.00f];
    }
}

- (SKTexture *)getTextureForInteractor:(NSString *)name {
    return [_interactorTextures objectForKey:name];
}

- (UIColor *)getBackgroundColor {
    return _backgroundColor;
}

- (UIColor *)getInteractorOnColor {
    return _interactorColorOn;
}

- (UIColor *)getInteractorOffColor {
    return _interactorColorOff;
}

@end
