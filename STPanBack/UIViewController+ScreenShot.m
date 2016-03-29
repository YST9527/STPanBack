//
//  UIViewController+ScreenShot.m
//  SunGuide
//
//  Created by jryghq on 16/3/28.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import "UIViewController+ScreenShot.h"
#import <objc/runtime.h>
static const char PrefixShotKey;
static const char CurrentShotKey;
@implementation UIViewController (ScreenShot)

- (void)setPrefixShot:(UIImage *)prefixShot {
    objc_setAssociatedObject(self, &PrefixShotKey, prefixShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)prefixShot {
    return objc_getAssociatedObject(self, &PrefixShotKey);
}

- (void)setCurrentShot:(UIImage *)currentShot {
    objc_setAssociatedObject(self, &CurrentShotKey, currentShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)currentShot {
    return objc_getAssociatedObject(self, &CurrentShotKey);
}

@end
