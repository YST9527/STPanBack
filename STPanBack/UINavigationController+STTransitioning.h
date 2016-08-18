//
//  UINavigationController+STTransitioning.h
//  STPanBack
//
//  Created by jryghq on 16/8/16.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol STInitializeSetDelegate <NSObject>

//stEdgePanGestureRecognizer should Receive Touch.

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch;

@end

@interface STInitializeSet : NSObject

@property (nonatomic, assign) CGFloat shadowAlpha; // View the shadow of transparency, default is 0.4.

@property (nonatomic, assign) CGFloat offsetFactor; // Screen sliding, the underlying view of sliding coefficient, default is 0.6.

@property (nonatomic, assign) CGFloat minOffset; // Screen began to slip, the underlying view the minimum offset, default is Half of the UINavigationController view.

@property (nonatomic, assign) CGFloat scale; // View at the bottom of the scale coefficient, default is 0.07;

@property (nonatomic, assign) NSTimeInterval animationTime; // Stop touching the screen, the view automatically reset time, default is 0.23.

@property (nonatomic, weak) UIViewController *shotController; // Screenshots of the view controller, default is UINavigationController.

@property (nonatomic, weak) id <STInitializeSetDelegate>delegate; // If you want to temporarily disable the custom slide back method, you can set the agent, and in the method `gestureRecognizer:shouldReceiveTouch:` returns NO.

@end

@interface UINavigationController (STTransitioning)

@property (nonatomic, strong, readonly) STInitializeSet *st_default; // default setting.

- (void)st_addEdgePanGestureRecognizer; // Add custom return gesture.

//Call this method When call `pushViewController:animated:` method, and do other operations in the block 'completionHandler'.Please refer to the demo specific usage.
/*
 - (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
     [self st_pushViewController:viewController animated:animated completionHandler:^{
         [super pushViewController:viewController animated:animated];
         //do other things
     }];
 }

 */
- (void)st_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler;

//Call this method When call `pushViewController:animated:` method, and do other operations in the block 'completionHandler'.Please refer to the demo specific usage.
/*
 - (UIViewController *)popViewControllerAnimated:(BOOL)animated {
     if (!animated) {
         return [super popViewControllerAnimated:NO];
     }
     [self st_popViewControllerAnimated:animated completionHandler:^{
         [super popViewControllerAnimated:NO];
         //do other things
     }];
     return nil;
 }
 */
- (void)st_popViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler;

//Call this method When call `pushViewController:animated:` method, and do other operations in the block 'completionHandler'.Please refer to the demo specific usage.
/*
 - (nullable NSArray<__kindof UIViewController *> *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated {
     if (!animated) {
         return [super popToViewController:viewController animated:NO];
     }
     [self st_popToViewController:viewController animated:animated completionHandler:^{
         [super popToViewController:viewController animated:NO];
         //do other things
     }];
     return nil;
 }
 */
- (void)st_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler;

//Call this method When call `pushViewController:animated:` method, and do other operations in the block 'completionHandler'.Please refer to the demo specific usage.
/*
 - (nullable NSArray<__kindof UIViewController *> *)popToRootViewControllerAnimated:(BOOL)animated {
     if (!animated) {
         return [super popToRootViewControllerAnimated:NO];
     }
     [self st_popToRootViewControllerAnimated:animated completionHandler:^{
         [super popToRootViewControllerAnimated:NO];
         //do other things
     }];
     return nil;
 }
 */
- (void)st_popToRootViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler;

// To enable a custom return gesture.
- (void)st_enableEdgePan;

// Disable the custom return gesture.
- (void)st_unableEdgePan;

@end

@interface UIViewController (STScreenShot)

@property (nonatomic, strong) UIImage *st_prefixShot; // prefix screenshot.

@property (nonatomic, strong) UIImage *st_currentShot; // current screenshot.

@end
