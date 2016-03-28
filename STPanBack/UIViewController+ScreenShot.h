//
//  UIViewController+ScreenShot.h
//  SunGuide
//
//  Created by jryghq on 16/3/28.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ScreenShot)
/**
 *  prefix screenshot
 */
@property (nonatomic, strong) UIImage *prefixShot;
/**
 *  current screenshot
 */
@property (nonatomic, strong) UIImage *currentShot;
@end
