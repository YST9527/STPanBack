//
//  UINavigationController+STTransitioning.m
//  STPanBack
//
//  Created by jryghq on 16/8/16.
//  Copyright © 2016年 jryghq. All rights reserved.
//

#import "UINavigationController+STTransitioning.h"
#import <objc/runtime.h>

@interface STInitializeSet ()

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, strong) UIView *bgView;

@property (nonatomic, assign) BOOL isMoving;

@end

@implementation STInitializeSet

- (instancetype)init {
    if (self = [super init]) {
        _shadowColor = [UIColor blackColor];
        _shadowAlpha = 0.4;
        _offsetFactor = 0.6;
        _scale = 0.07;
        _animationTime = 0.23;
        _startPoint = CGPointZero;
        _isMoving = NO;
    }
    return self;
}

@end

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

static const char st_PanGestureKey;
static const char st_InitializeSetKey;
static const char st_SceenShotKey;

@interface UINavigationController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *st_panGesture;

@property (nonatomic, strong) STLastScreenShot *screenShot;

@end



@implementation UINavigationController (STTransitioning)

- (void)setSt_panGesture:(UIScreenEdgePanGestureRecognizer *)st_panGesture {
    objc_setAssociatedObject(self, &st_PanGestureKey, st_panGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIScreenEdgePanGestureRecognizer *)st_panGesture {
    return objc_getAssociatedObject(self, &st_PanGestureKey);
}

- (void)setScreenShot:(STLastScreenShot *)screenShot {
    objc_setAssociatedObject(self, &st_SceenShotKey, screenShot, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (STLastScreenShot *)screenShot {
    STLastScreenShot *screenShot = objc_getAssociatedObject(self, &st_SceenShotKey);
    if (screenShot == nil) {
        screenShot = [[STLastScreenShot alloc]initWithFrame:self.view.bounds];
        self.screenShot = screenShot;
    }
    return screenShot;
}

- (STInitializeSet *)st_default {
    STInitializeSet *set = objc_getAssociatedObject(self, &st_InitializeSetKey);
    if (set == nil) {
        set = [[STInitializeSet alloc]init];
        set.minOffset = CGRectGetWidth(self.view.frame)/2;
        set.shotController = self;
        set.bgView = [[UIView alloc]initWithFrame:self.view.bounds];
        set.bgView.backgroundColor = [UIColor blackColor];
        objc_setAssociatedObject(self, &st_InitializeSetKey, set, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return set;
}

- (void)st_addEdgePanGestureRecognizer {
    if (self.st_panGesture == nil) {
        self.st_panGesture = [[UIScreenEdgePanGestureRecognizer alloc]initWithTarget:self action:@selector(st_edgePanGestureRecognizer:)];
        self.st_panGesture.edges = UIRectEdgeLeft;
        [self.st_panGesture delaysTouchesBegan];
        self.st_panGesture.delegate = self;
    }else {
        [self.view removeGestureRecognizer:self.st_panGesture];
    }
    [self.view.superview insertSubview:self.st_default.bgView belowSubview:self.view];
    [self.st_default.bgView addSubview:self.screenShot];
    self.st_default.bgView.hidden = YES;
    [self.view addGestureRecognizer:self.st_panGesture];
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
                self.screenShot.shadowView.alpha = 0;
            } completion:^(BOOL finished) {
                [self popViewControllerAnimated:NO];
                [self completionPanBackAnimation];
            }];
        } else {
            CGFloat time = offsetX/CGRectGetWidth(self.view.frame)*self.st_default.animationTime;
            [UIView animateWithDuration:time animations:^{
                [self moveViewWithLength:0];
                self.screenShot.shadowView.alpha = self.st_default.shadowAlpha;
            } completion:^(BOOL finished) {
                self.st_default.isMoving = NO;
                self.st_default.bgView.hidden = YES;
            }];
        }
        self.st_default.isMoving = NO;
    }
    if (panGesture.state == UIGestureRecognizerStateCancelled) {
        CGFloat time = offsetX/CGRectGetWidth(self.view.frame)*self.st_default.animationTime;
        [UIView animateWithDuration:time animations:^{
            [self moveViewWithLength:0];
            self.screenShot.shadowView.alpha = self.st_default.shadowAlpha;
        } completion:^(BOOL finished) {
            self.st_default.isMoving = NO;
            self.st_default.bgView.hidden = YES;
        }];
        self.st_default.isMoving = NO;
    }
    if (self.st_default.isMoving) {
        [self moveViewWithLength:offsetX];
        self.screenShot.shadowView.alpha = self.st_default.shadowAlpha*(1-offsetX/CGRectGetWidth(self.view.frame));
    }
}

-(void)initViewsWithImage:(UIImage *)image {
    self.st_default.bgView.hidden = NO;
    self.screenShot.imageView.image = image;
    self.screenShot.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(self.view.frame)*self.st_default.offsetFactor, 0);
}

-(void)moveViewWithLength:(CGFloat)length {
    length = length > CGRectGetWidth(self.view.frame)?CGRectGetWidth(self.view.frame):length;
    length = length < 0?0:length;
    self.view.transform = CGAffineTransformMakeTranslation(length, 0);
    self.screenShot.transform = CGAffineTransformMakeTranslation(-(CGRectGetWidth(self.view.frame)*self.st_default.offsetFactor)+length*self.st_default.offsetFactor, 0);
}

-(void)completionPanBackAnimation {
    self.view.transform = CGAffineTransformIdentity;
    self.st_default.bgView.hidden = YES;
}

- (void)st_enableEdgePan {
    [self.view.superview insertSubview:self.st_default.bgView belowSubview:self.view];
    self.st_panGesture.enabled = YES;
}

- (void)st_unableEdgePan {
    [self.st_default.bgView removeFromSuperview];
    self.st_panGesture.enabled = NO;
}

- (void)st_popViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:self.viewControllers[0].st_currentShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }
}

- (void)st_popToViewController:(UIViewController *)viewController animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:viewController.st_currentShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }
}

- (void)st_popToRootViewControllerAnimated:(BOOL)animated completionHandler:(void(^)(void))completionHandler {
    if (animated) {
        [self initViewsWithImage:self.topViewController.st_prefixShot];
        [UIView animateWithDuration:self.st_default.animationTime animations:^{
            [self moveViewWithLength:CGRectGetWidth(self.view.frame)];
            self.screenShot.shadowView.alpha = 0;
        } completion:^(BOOL finished) {
            completionHandler();
            [self completionPanBackAnimation];
        }];
    }
}


- (UIImage *)captureScreenShot {
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
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
