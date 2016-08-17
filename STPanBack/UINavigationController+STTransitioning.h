//
//  UINavigationController+STTransitioning.h
//  STPanBack
//
//  Created by jryghq on 16/8/16.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STInitializeSet : NSObject

@property (nonatomic, strong) UIColor *shadowColor; // View shadow color, default is black.

@property (nonatomic, assign) CGFloat shadowAlpha; // View the shadow of transparency, default is 0.4.

@property (nonatomic, assign) CGFloat offsetFactor; // Screen sliding, the underlying view of sliding coefficient, default is 0.6.

@property (nonatomic, assign) CGFloat minOffset; // Screen began to slip, the underlying view the minimum offset, default is Half of the UINavigationController view.

@property (nonatomic, assign) CGFloat scale; // View at the bottom of the scale coefficient, default is 0.07;

@property (nonatomic, assign) NSTimeInterval animationTime; // Stop touching the screen, the view automatically reset time, default is 0.23.

@property (nonatomic, strong) UIViewController *shotController; // Screenshots of the view controller, default is UINavigationController.

@end

@interface UINavigationController (STTransitioning)

@property (nonatomic, strong, readonly) STInitializeSet *st_default; // default setting.

- (void)st_addEdgePanGestureRecognizer; // Add custom return gesture.

- (void)st_popViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler; //

- (void)st_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler; //

- (void)st_popToRootViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler; //

- (void)st_enableEdgePan; // To enable a custom return gesture.

- (void)st_unableEdgePan; // Disable the custom return gesture.

@end

@interface UIViewController (STScreenShot)

@property (nonatomic, strong) UIImage *st_prefixShot; // prefix screenshot.

@property (nonatomic, strong) UIImage *st_currentShot; // current screenshot.

@end
