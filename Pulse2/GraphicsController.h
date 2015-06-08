//
//  GraphicsController.h
//  Pulse2
//
//  Created by Henry Thiemann on 6/7/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

@interface GraphicsController : NSObject

- (void)loadSoundscapeWithPlistNamed:(NSString *)plist;

- (SKTexture *)getTextureForInteractor:(NSString *)name;
- (UIColor *)getBackgroundColor;
- (UIColor *)getInteracterOnColor;
- (UIColor *)getInteractorOffColor;

@end
