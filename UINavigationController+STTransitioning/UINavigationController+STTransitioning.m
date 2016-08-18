//
//  UINavigationController+STTransitioning.m
//  STPanBack
//
//  Created by jryghq on 16/8/16.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import "UINavigationController+STTransitioning.h"
#import <objc/runtime.h>

@interface STLastScreenShot : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UIView *shadowView;

@end

@implementation STLastScreenShot

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc]initWithFrame:self.bounds];
        [self addSubview:_imageView];
        _shadowView = [[UIView alloc]initWithFrame:self.bounds];
        _shadowView.backgroundColor = [UIColor blackColor];
        [self addSubview:_shadowView];
    }
    return self;
}

@end

@interface STInitializeSet ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *st_panGesture;

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, strong) STLastScreenShot *screenShot;

@property (nonatomic, assign) BOOL isMoving;

@property (nonatomic, weak) UINavigationController *navigationController;

@end

@implementation STInitializeSet

- (instancetype)init {
    if (self = [super init]) {
        _shadowAlpha = 0.4;
        _offsetFactor = 0.6;
        _scale = 0.07;
        _animationTime = 0.23;
        _startPoint = CGPointZero;
        _st_panGesture = [[UIScreenEdgePanGestureRecognizer alloc]init];
        _st_panGesture.edges = UIRectEdgeLeft;
        [_st_panGesture delaysTouchesBegan];
        _st_panGesture.delegate = self;
        _isMoving = NO;
    }
    return self;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([self.delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)]) {
        return [self.delegate gestureRecognizer:gestureRecognizer shouldReceiveTouch:touch];
    }
    return self.navigationController.viewControllers.count != 1;
}

@end


static const char st_InitializeSetKey;

@interface UINavigationController ()

@end

@implementation UINavigationController (STTransitioning)

- (STInitializeSet *)st_default {
    STInitializeSet *set = objc_getAssociatedObject(self, &st_InitializeSetKey);
    if (set == nil) {
        set = [[STInitializeSet alloc]init];
        set.minOffset = CGRectGetWidth(self.view.frame)/2;
        set.shotController = self;
        set.bgView = [[UIView alloc]initWithFrame:self.view.frame];
        set.bgView.backgroundColor = [UIColor blackColor];
        set.screenShot = [[STLastScreenShot alloc]initWithFrame:set.bgView.bounds];
        [set.bgView addSubview:set.screenShot];
        set.navigationController = self;
        [set.st_panGesture addTarget:self action:@selector(st_edgePanGestureRecognizer:)];
        objc_setAssociatedObject(self, &st_InitializeSetKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}

- (void)st_addEdgePanGestureRecognizer {
    [self.view removeGestureRecognizer:self.st_default.st_panGesture];
    [self.view addGestureRecognizer:self.st_default.st_panGesture];
}

- (void)st_edgePanGestureRecognizer:(UIScreenEdgePanGestureRecognizer *)panGesture {
    CGPoint touchPoint = [panGesture locationInView:[[UIApplication sharedApplication]keyWindow]];
    CGFloat offsetX = touchPoint.x - self.st_default.startPoint.x;
    if (panGesture.state == UIGestureRecognizerStateBegan) {
        [self initViewsWithImage:self.topViewController.st_prefixShot];
        self.st_default.isMoving = YES;
        self.st_default.startPoint = touchPoint;
        offsetX = 0;
    }
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGesture velocityInView:self.view];
        if (offsetX > self.st_default.minOffset || velocity.x > 600) {
            CGFloat time = (1-offsetX/CGRectGetWidth(self.view.frame))*self.st_default.animationTime;
            [UIView animateWithDuration:time animations:^{
                [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
                self.st_default.screenShot.shadowView.alpha = 0;
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                [self completionPanBackAnimation];
            }];
        } else {
            CGFloat time = offsetX/CGRectGetWidth(self.view.frame)*self.st_default.animationTime;
            [UIView animateWithDuration:time animations:^{
                [self moveViewWithLength:0];
                self.st_default.screenShot.shadowView.alpha = self.st_default.shadowAlpha;
            } completion:^(BOOL finished) {
                self.st_default.isMoving = NO;
            }];
        }
        self.st_default.isMoving = NO;
    }
    if (panGesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat time = offsetX/CGRectGetWidth(self.view.frame)*self.st_default.animationTime;
        [UIView animateWithDuration:time animations:^{
            [self moveViewWithLength:0];
            self.st_default.screenShot.shadowView.alpha = self.st_default.shadowAlpha;
        } completion:^(BOOL finished) {
            self.st_default.isMoving = NO;
            [self.st_default.bgView removeFromSuperview];
        }];
        self.st_default.isMoving = NO;
    }
    if (self.st_default.isMoving) {
        [self moveViewWithLength:offsetX];
        self.st_default.screenShot.shadowView.alpha = self.st_default.shadowAlpha*(1-offsetX/CGRectGetWidth(self.view.frame));
    }
}

- (void)initViewsWithImage:(UIImage *)image {
    [self.st_default.bgView removeFromSuperview];
    [self.view.superview insertSubview:self.st_default.bgView belowSubview:self.view];
    self.st_default.screenShot.imageView.image = image;
    self.st_default.screenShot.transform = CGAffineTransformMakeTranslation(-CGRectGetWidth(self.view.frame)*self.st_default.offsetFactor, 0);
}

- (void)moveViewWithLength:(CGFloat)length {
    length = length > CGRectGetWidth(self.view.frame)?CGRectGetWidth(self.view.frame):length;
    length = length < 0?0:length;
    self.view.transform = CGAffineTransformMakeTranslation(length, 0);
    self.st_default.screenShot.transform = CGAffineTransformMakeTranslation(-(CGRectGetWidth(self.view.frame)*self.st_default.offsetFactor)+length*self.st_default.offsetFactor, 0);
}

- (void)completionPanBackAnimation {
    self.view.transform = CGAffineTransformIdentity;
    [self.st_default.bgView removeFromSuperview];
}

- (void)st_enableEdgePan {
    self.st_default.st_panGesture.enabled = YES;
}

- (void)st_unableEdgePan {
    [self.st_default.bgView removeFromSuperview];
    self.st_default.st_panGesture.enabled = NO;
}

- (void)st_pushViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (self.viewControllers.count != 0) {
        viewController.st_prefixShot = [self captureScreenShot];
        self.topViewController.st_currentShot = viewController.st_prefixShot;
    }
    completionHandler();
}

- (void)st_popViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:self.topViewController.st_prefixShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.st_default.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }else {
        completionHandler();
    }
}

- (void)st_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:viewController.st_currentShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.st_default.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }else {
        completionHandler();
    }
}

- (void)st_popToRootViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:self.viewControllers[0].st_currentShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.st_default.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }else {
        completionHandler();
    }
}

- (UIImage *)captureScreenShot {
    if (self.st_default.shotController == nil) {
        self.st_default.shotController = self;
    }
    UIGraphicsBeginImageContextWithOptions(self.st_default.shotController.view.bounds.size, self.st_default.shotController.view.opaque, 0.0);
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


@end


static const char st_PrefixShotKey;
static const char st_CurrentShotKey;

@implementation UIViewController (STScreenShot)

- (void)setSt_prefixShot:(UIImage *)st_prefixShot {
    objc_setAssociatedObject(self, &st_PrefixShotKey, st_prefixShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)st_prefixShot {
    return objc_getAssociatedObject(self, &st_PrefixShotKey);
}

- (void)setSt_currentShot:(UIImage *)st_currentShot {
    objc_setAssociatedObject(self, &st_CurrentShotKey, st_currentShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIImage *)st_currentShot {
    return objc_getAssociatedObject(self, &st_CurrentShotKey);
}

@end
